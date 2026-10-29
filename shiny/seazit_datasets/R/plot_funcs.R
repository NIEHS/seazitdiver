use_category_pie_plot <- function(d, sourceId) {

  colors <- use_category1_hexcolor()

  fig <- plot_ly(d,
                 source = sourceId,
                 labels = ~use_category1, values = ~n, type = 'pie', customdata = ~use_category1,
                 textposition = 'inside',
                 textinfo = 'label+percent',
                 insidetextfont = list(color = '#FFFFFF'),
                 hoverinfo = 'text',
                 text = ~n,
                 marker = list(colors = colors,
                               line = list(color = '#FFFFFF', width = 1)),
                 #The 'pull' attribute can also be used to create space between the sectors
                 showlegend = FALSE)
  fig <- fig %>% layout(title = 'SEAZIT Compound Use Category (Level 1) Summary',
                        xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
                        yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
  return(fig)
}




ontology_sankey_plot <- function(l_sankey) {


  fig <- plot_ly(

    type = "sankey",
    orientation = "h",
    node = list(
      label = l_sankey$nodes$node_name,
      color = l_sankey$nodes$node_color,
      pad = 10,
      thickness = 50,
      line = list(
        color = "black",
        width = 0.5
      ),
      customdata = map2(l_sankey$nodes$node_level, l_sankey$nodes$node_name, function(x, y) {
        level <- switch(
          x,
          "recording" = "Laboratory Specific Recording Term",
          "term" = "Phenotype Ontology Term",
          "granular" = "Granular Phenotype Term",
          "general" = "General Phenotype Term"
        )
        return(list(level, y))
      }),
      hovertemplate = paste0(
        paste(
          '<b>%{customdata[0]}</b>:
           %{customdata[1]}',
          sep = '<br>'
        ),
        '<extra></extra>'
      )
    ),

    link = list(
      source = l_sankey$flows$new_source_id,
      target = l_sankey$flows$new_target_id,
      value = l_sankey$flows$flow_size,
      color = l_sankey$flows$flow_color
    )

  )

  fig <- fig %>% layout(

    #title = "Sankey Diagram of Zebrafish Altered Phenotype",
    font = list(
      size = 15
    ),
    heights = "100%"

  )

  return(fig)

}


