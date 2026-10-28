## vertical line
vline <- function(x = 0, color = "magenta") {
  list(
    type = "line",
    y0 = 0,
    y1 = 1,
    yref = "paper",
    x0 = x,
    x1 = x,
    opacity = 0.7,
    line = list(color = color, dash = "dot")
  )
}


hline <- function(y = 0, color = "magenta") {
  list(
    type = "line",
    x0 = 0,
    x1 = 1,
    xref = "paper",
    y0 = y,
    y1 = y,
    opacity = 0.7,
    line = list(color = color, dash = "dot")
  )
}

gg_title <- function(title_name) {
  list(
    text = title_name,
    font = list(size = 18),
    xref = "paper",
    yref = "paper",
    yanchor = "bottom",
    xanchor = "center",
    align = "center",
    x = 0.5,
    y = 1,
    showarrow = FALSE
  )
}


dmso_boxplot <- function(d, title_name, sourceId) {

  d1 <- d %>% unite(plate_protocol, c("plate_name", "protocol_id"), remove = FALSE, sep = "@")

  p1 <- d1 %>%
    #highlight_key(~plate_name) %>%
    plot_ly(
      source = sourceId,
      y = ~percent, x = ~endpoint_name, color = ~protocol_name_plot, customdata = ~plate_protocol,
      text = ~text,
      type = "box",
      boxpoints = "all",
      jitter = 0.3,
      pointpos = 0,
      marker = list(size = 7, opacity = 0.7 )
    ) %>%
    config(
      toImageButtonOptions = list(
      format = "svg",
      filename = "VC_boxplot"
    )) %>%
    #highlight(on = "plotly_hover", off = "plotly_doubleclick") %>%
    #highlight(selected = attrs_selected(showlegend = FALSE)) %>%
    plotly::layout(
      yaxis = list(range = c(0, 100), title = "percentage", hoverformat = ".2f"),
      xaxis = list(title = ""),
      title = title_name,
      boxmode = 'group',
      plot_bgcolor = "rgba(245, 245, 220, 0.7)",
      shapes = list(hline(20)),
      legend = list(orientation = "h",   # show entries horizontally
                    xanchor = "center",  # use center of legend as anchor
                    x = 0.5)             # put legend in center of x-axis
    ) %>%
    event_register("plotly_click")

  return(p1)
}


dmso_click_dotplot <- function(d) {
  #clickData <- event_data("plotly_click", source = click_sourceId)

  #if (is.null(clickData)) return(NULL)

  title_name <- str_c("Selected dataset: ", unique(d$protocol_name_plot))

  plot_ly(
    d,  x = ~plate_screen_time_end, y = ~percent, color = ~new_color, colors = c("clicked plate" = "red", "others" = "black"),
    text = ~text,
    type = "scatter",
    mode = "markers",
    marker = list(size = 10, opacity = 0.4)
  ) %>%
    config(
      toImageButtonOptions = list(
        format = "svg",
        filename = "VS_response_by_time"
      )) %>%
    plotly::layout(
      yaxis = list(range = c(0, 100), title = "percentage", hoverformat = ".2f"),
      xaxis = list(title = ""),
      showlegend = TRUE,
      annotations = gg_title(title_name),
      shapes = list(hline(20)),
      plot_bgcolor = "rgba(245, 245, 220, 0.7)",
      legend = list(orientation = "h",   # show entries horizontally
                    xanchor = "center",  # use center of legend as anchor
                    x = 0.5)             # put legend in center of x-axis
    )


}


pc_boxplot <- function(d, title_name, sourceId) {

  d1 <- d %>%
    mutate(protocol_name_plot = factor(protocol_name_plot)) %>%
    filter(hit_confidence > 0.5)

  d1 %>%
    #highlight_key(~plates_time, group = "endpoint") %>% # group is necessary
    plot_ly(
      source = sourceId,
      y = ~POD, x = ~endpoint_name, color = ~protocol_name_plot, text = ~text, type = "box",
      boxpoints = "all",
      jitter = 0.3,
      pointpos = 0,
      #hoverinfo = "x+text", # this does not work very well
      marker = list(size = 10, opacity = 0.7 )
      #don't know why I("black") does not work "rgba(100, 100, 100, 0.7)"
    ) %>%
    config(
      toImageButtonOptions = list(
        format = "svg",
        filename = "PC_BMC_boxplot"
      )) %>%
    #highlight(on = "plotly_click", off = "plotly_relayout") %>%  # need to click home to back to normal
    plotly::layout(
      yaxis = list(type = "log",  title = "Benchmark concentration (BMC) μM",  hoverformat = ".2f", range = c(0, 2) ),
      xaxis = list(title = ""),
      #showlegend = FALSE,
      title = title_name,
      boxmode = 'group',
      plot_bgcolor = "rgba(245, 245, 220, 0.7)",
      legend = list(orientation = "h",   # show entries horizontally
                    xanchor = "center",  # use center of legend as anchor
                    x = 0.5)
    )
}




dup_dotplot <- function(d, title_name, sourceId) {



  # Calculate unique offsets for each protocol_name_plot
  #n_protocol <-   unique(d$protocol_name_plot) %>% length()
  protocol_offsets <- d %>%
    distinct(protocol_name_plot) %>%
    mutate(offset = seq(-0.3, 0.3, length.out = n()))
    #mutate(offset = seq(-0.1*n_protocol, 0.1*n_protocol, length.out = n()))  # Adjust the range as needed, ex: -0.2, 0.2
  # Merge offsets into the dataset
  d <- d %>%
    left_join(protocol_offsets, by = "protocol_name_plot") %>%
    mutate(y_adjusted = as.numeric(factor(name_w_code)) + offset)  # Adjust y-coordinate

  d %>%
    group_by(name_w_code) %>% #necessary for the lines
    highlight_key(~protocol_name_plot) %>%
    plot_ly(
      x = ~POD,
      #y = ~name_w_code,
      y = ~y_adjusted,  # Use the adjusted y
      text = ~text
    ) %>%
    config(
      toImageButtonOptions = list(
        format = "svg",
        filename = "duplicate_BMC_dotplot"
      )) %>%
    add_trace(
      color = ~protocol_name_plot,
      type = "scatter",
      mode = "markers+lines",  # Add "lines" to connect markers within the same group
      marker = list(
        size = 10,
        opacity = 0.9,
        symbol = "circle",
        line = list(
          color = 'rgb(0, 0, 0, 0.7)',  # Outline color for markers
          width = 1                # Outline width
        )
      ),
      line = list(
        dash = 'dot',         # Dash style: change this to 'solid', 'dot', 'dash', etc.
        width = 2                 # Line width
      ),
      showlegend = TRUE
    )  %>%
    add_trace(
      data = d %>% filter(is_hit == "inactive"),
      name = "inactive",
      type = "scatter",
      mode = "markers",
      #symbol = ~factor(is_hit), symbols = c('x-thin'),
      marker = list(size = 12, color = "rgba(100, 100, 100, 0.7)", symbol = "x-thin", line = list(width = 2)),
      showlegend = TRUE
    ) %>%
    highlight(on = "plotly_click", off = "plotly_doubleclick") %>%  # need to click home to back to normal
    plotly::layout(
      xaxis = list(type = "log",  title = "",  hoverformat = ".2f"),
      yaxis = list(
        title = "",
        tickvals = as.numeric(factor(unique(d$name_w_code))),  # Unique tick positions
        ticktext = unique(d$name_w_code),  # Original y labels
        autorange = "reversed"),
      showlegend = TRUE,
      #annotations = list(gg_title(title_name)),
      title = title_name,
      plot_bgcolor = "rgba(245, 245, 220, 0.7)",
      legend = list(
        orientation = "h",   # show entries horizontally
        xanchor = "center",  # use center of legend as anchor
        x = 0.5,
        itemclick = FALSE, itemdoubleclick = FALSE) # disable legend click
    )

}
