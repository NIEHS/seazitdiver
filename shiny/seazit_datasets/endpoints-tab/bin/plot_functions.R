# Color for any group not found in "substance_colors" or "dataset_colors"
nomatch_color <- "#000000"

# Substance colors
# From gitlab: seazit_app/project/seazit/assets/seazit/shared.js
substance_colors <- setNames(as.data.frame(rbind(
  c("#3182bd", "Drug"),
  c("#e7ba52", "Flame Retardant"),
  c("#f9d70b", "Fungicide"),
  c("#3BD6C6", "Herbicide"),
  c("#31a354", "Industrial Compound"),
  c("#d62976", "Insecticide"),
  c("#756bb1", "PAH"),
  c("#ee7621", "Positive Control"),
  c("#c89f73", "Preservative"),
  c("#ee7621", "Vehicle Control")
)), c("color", "group"))

# Dataset colors
dataset_colors <- setNames(as.data.frame(rbind(
  # scales::col_numeric("Greys", domain = c(1, 8))(4:5)
  c("#ACACAC", "Dose Range Finding"),
  c("#828282", "Definitive"),
  # First 3 colors from RColorBrewer Dark2 palette
  # RColorBrewer::brewer.pal(3, "Dark2")
  c("#1b9e77", "Lab A"), # biobide
  c("#d95f02", "Lab B"), # osu
  c("#7570b3", "Lab C"), # zeclinics
  # From gitlab: seazit-shiny/dataset_tab/www/test_condition_class.css
  # Convert hsl to rgb: https://www.rapidtables.com/convert/color/hsl-to-rgb.html
  c("#F7D4DA", "Static Renewal-Chorion (SR-C)"),
  c("#F7E9D4", "Static Renewal-Dechorion (SR-DC)"),
  c("#D4DAF7", "Static-Chorion (S-C)"),
  c("#D8F5D6", "Static-Dechorion (S-DC)")
)), c("color", "group"))

# Colorscales

createColorscale <- function(color_df) {
  color_df %>% 
    mutate(value = row_number() / nrow(.)) %>% 
    select(value, color) %>% 
    slice(rep(1:n(), each = 2)) %>% 
    mutate(value = lag(value, default = 0))
}

createColorLegend <- function(n, title_text = "Title") {
  count_0 <- "#CCCCCC"
  if (n == 0) {
    colorscale <- data.frame(
      value = c(0, 1),
      color = rep(count_0, 2)
    )
    colorbar <- list(
      tickvals = 0.5,
      ticktext = 0,
      title = list(text = title_text)
    )
  } else {
    colorscale <- createColorscale(
      data.frame(
        color = c(
          count_0,
          scales::col_numeric("Blues", domain = c(1, n + 1))(1 + (1:n))
        )
      )
    )
    if (n < 7) {
      idx <- c(1, n + 1)
    } else {
      idx <- seq(1, n + 1, by = ceiling(sqrt(n)))
    }
    colorbar <- list(
      tickvals = seq(0.5, n - 0.5, length = n + 1)[idx],
      ticktext = idx - 1,
      title = list(text = title_text)
    )
  }
  list(colorscale = colorscale, colorbar = colorbar)
}

substance_colorscale <- createColorscale(substance_colors)
dataset_colorscale   <- createColorscale(dataset_colors)

# Basic shapes

vline <- function(x = 0, color = "black") {
  list(
    x0 = x, x1 = x,
    y0 = 0, y1 = 1, yref = "paper",
    type = "line", line = list(color = color)
  )
}

makePlot <- function(substances, datasets, ontologies, counts = NULL) {
  
  ##############################
  # Rows
  #####
  
  # Add row index and color
  df_row <- mutate(
    substances,
    row = rev(row_number()),
    color = match(group, substance_colors$group, nomatch = 0)
  )
  
  # Create figure
  fig_row <- plot_ly(
    df_row,
    x = rep("Group", nrow(df_row)),
    y = ~row,
    z = ~color,
    zmin = 1,
    zmax = nrow(substance_colors),
    colorscale = substance_colorscale,
    customdata = ~group,
    hovertemplate = 'Substance: %{y}<br>Group: %{customdata}<extra></extra>',
    type = "heatmap"
  ) %>%
    layout(
      xaxis = list(
        fixedrange = TRUE
      ),
      yaxis = list(
        title = list(text = "Substance"),
        tickmode = "array",
        tickvals = ~row,
        ticktext = ~name,
        fixedrange = TRUE
      )
    ) %>% 
    hide_colorbar()
  
  ##############################
  # Cols
  #####
  
  # Cross-join datasets and ontologies
  df_col <- cross_join(
    datasets,
    ontologies
  ) %>% 
    # Add col index
    mutate(
      col = row_number()
    )
  
  # Add row index and colors
  df_col_stacked <- rbind(
    mutate(df_col, row = 3, color = match(    phase, dataset_colors$group, nomatch = 0)),
    mutate(df_col, row = 2, color = match(      lab, dataset_colors$group, nomatch = 0)),
    mutate(df_col, row = 1, color = match(condition, dataset_colors$group, nomatch = 0))
  )
  
  # Create figure
  fig_col <- plot_ly(
    df_col_stacked,
    x = ~col,
    y = ~row,
    z = ~color,
    zmin = 1,
    zmax = nrow(dataset_colors),
    colorscale = dataset_colorscale,
    customdata = lapply(
      1:nrow(df_col_stacked),
      function(idx) list(
        df_col_stacked$phase[idx],
        df_col_stacked$lab[idx],
        df_col_stacked$condition[idx]
      )
    ),
    hovertemplate = paste0(
      paste(
        'Phase: %{customdata[0]}',
        'Lab: %{customdata[1]}',
        'Condition: %{customdata[2]}',
        sep = '<br>'
      ),
      '<extra></extra>'
    ),
    type = "heatmap"
  ) %>%
    layout(
      xaxis = list(
        title = list(text = ""),
        ticks = "",
        showticklabels = FALSE,
        fixedrange = TRUE
      ),
      yaxis = list(
        title = list(text = "Dataset"),
        tickmode = "array",
        tickvals = 3:1,
        ticktext = c("Phase", "Lab", "Condition"),
        fixedrange = TRUE
      )
    ) %>% 
    hide_colorbar()
  
  ##############################
  # Count
  #####
  
  df_full <- cross_join(
    df_row %>% select(-color),
    df_col
  )
  if (!is.null(counts)) {
    df_full <- left_join(
      df_full,
      counts,
      by = c("name", "phase", "lab", "condition", "ontology")
    ) %>% 
      mutate(
        n = replace(n, is.na(n), 0)
      )
  } else {
    df_full <- mutate(df_full, n = round(runif(1:nrow(df_full))*10))
  }
  
  # Create colorscale
  max_n <- max(df_full$n)
  if (max_n == 0) {
    # No data found
    df_full_colorscale <- data.frame(
      value = c(0, 1),
      color = rep("#BBBBBB", 2)
    )
  } else {
    df_full_colorscale <- data.frame(
      value = (0:max_n)/max_n,
      color = c("#BBBBBB", scales::col_numeric("Blues", domain = c(1, max_n + 1))(1 + (1:max_n)))
    )
  }
  
  # Create figure
  fig_full <- plot_ly(
    df_full,
    x = ~col,
    y = ~row,
    z = ~n,
    zmin = 0,
    zmax = nrow(df_full_colorscale) - 1,
    colorscale = df_full_colorscale,
    colorbar = list(title = list(text = "#Endpoints")),
    customdata = lapply(
      1:nrow(df_full),
      function(idx) list(
        df_full$name[idx],
        df_full$group[idx],
        df_full$phase[idx],
        df_full$lab[idx],
        df_full$condition[idx],
        df_full$ontology[idx]
      )
    ),
    hovertemplate = paste0(
      paste(
        'Substance: %{customdata[0]}',
        'Group: %{customdata[1]}',
        'Phase: %{customdata[2]}',
        'Lab: %{customdata[3]}',
        'Condition: %{customdata[4]}',
        'Ontology: %{customdata[5]}',
        'Endpoints: %{z}',
        sep = '<br>'),
      '<extra></extra>'
    ),
    type = "heatmap"
  ) %>% 
    layout(
      xaxis = list(
        title = list(
          text = "Endpoint Ontology Categories",
          standoff = 15
        ),
        ticks = "",
        showticklabels = FALSE,
        fixedrange = TRUE
      ),
      yaxis = list(
        fixedrange = TRUE
      ),
      shapes = if (nrow(ontologies) > 1 && nrow(datasets) > 1) {
        lapply(nrow(ontologies)*(1:(nrow(datasets) - 1)) + 0.5, vline)
      } else {
        list()
      }
    )
  
  ##############################
  # Combine figures
  #####
  
  header_height = 4 / (4 + nrow(df_row))
  
  fig_corner <- plot_ly(
    x = "Group",
    y = 1:3,
    z = 0,
    colors = "#FFFFFF",
    alpha = 0,
    type = "heatmap"
  ) %>% 
    layout(
      xaxis = list(
        showgrid = FALSE,
        fixedrange = TRUE
      ),
      yaxis = list(
        showgrid = FALSE,
        fixedrange = TRUE
      )
    ) %>% 
    style(hoverinfo = 'none') %>% 
    hide_colorbar()

  fig <- subplot(
    fig_corner, fig_col,
    fig_row, fig_full,
    nrows = 2,
    widths = c(0.1, 0.9),
    heights = c(header_height, 1 - header_height),
    margin = 0.01,
    shareY = TRUE,
    shareX = TRUE
  )

  return(fig)
}

makeOntologyPlot <- function(
    datasets, endpoints_all, endpoints_general, endpoints_granular
) {
  
  dataset_colors     <- dataset_colors[nrow(dataset_colors):1,]
  dataset_colorscale <- createColorscale(dataset_colors)

  ##############################
  # Datasets
  #####
  
  # Add column index
  df_datasets <- datasets %>% 
    mutate(column = row_number())
  
  # Add row index and colors
  df_datasets_stacked <- rbind(
    mutate(df_datasets, row = 3, color = match(    phase, dataset_colors$group, nomatch = 0)),
    mutate(df_datasets, row = 2, color = match(      lab, dataset_colors$group, nomatch = 0)),
    mutate(df_datasets, row = 1, color = match(condition, dataset_colors$group, nomatch = 0))
  )
  
  # Dataset colorbar
  n <- nrow(dataset_colors)
  dataset_colorbar <- list(
    tickvals = seq(1 + 0.5, n - 0.5, length = n),
    ticktext = dataset_colors$group,
    title = list(text = "Dataset")
  )

  # Create figure
  fig_datasets <- plot_ly(
    df_datasets_stacked,
    x = ~column,
    y = ~row,
    z = ~color,
    zmin = 1,
    zmax = nrow(dataset_colors),
    colorscale = dataset_colorscale,
    colorbar = dataset_colorbar,
    customdata = lapply(
      1:nrow(df_datasets_stacked),
      function(idx) list(
        df_datasets_stacked$phase[idx],
        df_datasets_stacked$lab[idx],
        df_datasets_stacked$condition[idx]
      )
    ),
    hovertemplate = paste0(
      paste(
        'Phase: %{customdata[0]}',
        'Lab: %{customdata[1]}',
        'Condition: %{customdata[2]}',
        sep = '<br>'
      ),
      '<extra></extra>'
    ),
    type = "heatmap"
  ) %>%
    layout(
      xaxis = list(
        title = list(text = ""),
        ticks = "",
        showticklabels = FALSE,
        fixedrange = TRUE
      ),
      yaxis = list(
        title = list(text = "Dataset"),
        tickmode = "array",
        tickvals = 3:1,
        ticktext = c("Phase", "Lab", "Condition"),
        fixedrange = TRUE
      )
    )
  
  ##############################
  # All endpoints
  #####
  
  df_all <- df_datasets %>% 
    left_join(endpoints_all, join_by(phase, lab, condition)) %>% 
    mutate(
      n = replace(n, is.na(n), 0)
    ) %>% 
    rowwise() %>% 
    mutate(
      endpoints = stringr::str_flatten(sort(endpoints), collapse = "\n"),
      endpoints = replace(endpoints, endpoints == "", "None")
    ) %>% 
    ungroup()
  
  
  # Create colorscale
  max_n <- max(df_all$n)
  legend <- createColorLegend(max_n, "# All Endpoints")

  # Create figure
  fig_all <- plot_ly(
    df_all,
    x = ~column,
    y = rep(1, nrow(df_all)),
    z = ~n,
    zmin = 0,
    zmax = max_n,
    colorscale = legend$colorscale,
    colorbar = legend$colorbar,
    customdata = lapply(
      1:nrow(df_all),
      function(idx) list(
        df_all$endpoints[[idx]]
      )
    ),
    hovertemplate = 'Endpoints (%{z}):\n%{customdata[0]}<extra></extra>',
    type = "heatmap"
  ) %>% 
    layout(
      xaxis = list(
        title = list(text = ""),
        ticks = "",
        showticklabels = FALSE,
        fixedrange = TRUE
      ),
      yaxis = list(
        title = list(
          text = "All",
          standoff = 15
        ),
        ticks = "",
        showticklabels = FALSE,
        fixedrange = TRUE
      )
    )
  
  ##############################
  # General endpoints
  #####
  
  ontologies_general <- endpoints_general %>% 
    select(ontology) %>% 
    distinct() %>% 
    arrange(ontology != "NA", desc(ontology)) %>% 
    mutate(row = row_number())
  
  df_general <- df_datasets %>% 
    cross_join(ontologies_general) %>% 
    left_join(endpoints_general, join_by(phase, lab, condition, ontology)) %>% 
    mutate(n = if_else(is.na(n), 0, n)) %>% 
    rowwise() %>% 
    mutate(
      endpoints = stringr::str_flatten(sort(endpoints), collapse = "\n"),
      endpoints = if_else(endpoints == "", "None", endpoints)
    ) %>% 
    ungroup()
  
  # Create colorscale
  max_n <- max(df_general$n)
  legend <- createColorLegend(max_n, "# General Endpoints")
  
  # Create figure
  fig_general <- plot_ly(
    df_general,
    x = ~column,
    y = ~row,
    z = ~n,
    zmin = 0,
    zmax = max_n,
    colorscale = legend$colorscale,
    colorbar = legend$colorbar,
    customdata = lapply(
      1:nrow(df_general),
      function(idx) list(
        df_general$endpoints[[idx]]
      )
    ),
    hovertemplate = 'Endpoints (%{z}):\n%{customdata[0]}<extra></extra>',
    type = "heatmap"
  ) %>% 
    layout(
      xaxis = list(
        title = list(text = ""),
        ticks = "",
        showticklabels = FALSE,
        fixedrange = TRUE
      ),
      yaxis = list(
        title = list(
          text = "General Phenotype Terms",
          standoff = 15
        ),
        tickmode = "array",
        tickvals = ~row,
        ticktext = ~ontology,
        fixedrange = TRUE
      )
    )
  
  ##############################
  # Granular endpoints
  #####
  
  ontologies_granular <- endpoints_granular %>% 
    select(ontology) %>% 
    distinct() %>% 
    arrange(ontology != "NA", desc(ontology)) %>% 
    mutate(row = row_number())
  
  df_granular <- df_datasets %>% 
    cross_join(ontologies_granular) %>% 
    left_join(endpoints_granular, join_by(phase, lab, condition, ontology)) %>% 
    mutate(n = if_else(is.na(n), 0, n)) %>% 
    rowwise() %>% 
    mutate(
      endpoints = stringr::str_flatten(sort(endpoints), collapse = "\n"),
      endpoints = if_else(endpoints == "", "None", endpoints)
    ) %>% 
    ungroup()
  
  # Create colorscale
  max_n <- max(df_granular$n)
  legend <- createColorLegend(max_n, "# Granular Endpoints")

  # Create figure
  fig_granular <- plot_ly(
    df_granular,
    x = ~column,
    y = ~row,
    z = ~n,
    zmin = 0,
    zmax = max_n,
    colorscale = legend$colorscale,
    colorbar = legend$colorbar,
    customdata = lapply(
      1:nrow(df_granular),
      function(idx) list(
        df_granular$endpoints[[idx]]
      )
    ),
    hovertemplate = 'Endpoints (%{z}):\n%{customdata[0]}<extra></extra>',
    type = "heatmap"
  ) %>% 
    layout(
      xaxis = list(
        title = list(text = ""),
        ticks = "",
        showticklabels = FALSE,
        fixedrange = TRUE
      ),
      yaxis = list(
        title = list(
          text = "Granular Phenotype Terms",
          standoff = 15
        ),
        tickmode = "array",
        tickvals = ~row,
        ticktext = ~ontology,
        fixedrange = TRUE
      )
    )
  
  ##############################
  # Combine figures
  #####
  
  total_height = 4 + 2 + nrow(ontologies_general) + nrow(ontologies_granular)
  
  fig <- subplot(
    fig_datasets,
    fig_all,
    fig_general,
    fig_granular,
    nrows = 4,
    heights = c(4, 2, nrow(ontologies_general), nrow(ontologies_granular)) / total_height,
    margin = 0.01,
    shareX = TRUE,
    shareY = TRUE
  )
  
  fig
}
