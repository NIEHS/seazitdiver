protocol_help_text <- function() {

  div(
    p("By default, protocol parameters of all datasets are shown.", br(),
      "Table can be filtered based on three panels: ",
      strong("Study Phase", .noWS = c("before", "after")), ", ",
      strong("Laboratory", .noWS = c("before", "after")), ", and ",
      strong("Test Condition", .noWS = c("before", "after")), ".", br(),
    "Unique cell values are highlighted as", span("red", style = "color:red", .noWS = "after"), ".", br(),
    "Column explanations are provided for certain columns when hovering over the column name.",
    style="display:inline"
    )
  )
}

substance_help_text <- function() {

  div(
    p("The pie chart summarizes the composition of test substances based on", em("Use Category (Level 1)", .noWS = c("after")), ".", br(),
      "Click on the individual pie slice to view the information in the table for that category.", br(),
      "Click", strong("See All Substances"), "on the top to include all test substances in the table."),
      p("By default, all substances are listed in the table, including 39 unique substances plus three duplicated substances (aldicarb, bisphenol A, valproic acid).", br(),
      "A summary of molecular weight, octanol-water partition coefficient (logP), and data availability are provided for each category.", br(),
      "Click on each category to expand the rows. Click", strong("Collapse Rows/Expand Rows"), "to collapse/expand rows for each category.",
    style="display:inline")
  )

}


ontology_help_text <- function() {

  div(
    h5("This tab includes three sub-tabs:"),
      p("In the", strong("Table"), "tab, the ontology term mapping of laboratory specific recording term is provided.", br(),
      "By default, the terms are collapsed based on", em("Body Part", .noWS = "after" ), ". Click on each body part to expand the rows.", br(),
      "The availability of ontology mapping is highlighted with", span("lightyellow", style = "background:yellow"), "background.", br(),
      "Click", strong("Collapse Rows/Expand Rows"), "to collapse/expand rows for each body part."),

     p("In the", strong("Sankey Diagram"), "tab, additional mapping using granular and general phenotype terms is included.", br(),
      "A Sankey Diagram is created for each laboratory which can be selected using the drop-down pane.", br(),
      "Different colors in the Sankey Diagram represents different general phenotype terms."),

     p("In the", strong("Data Density"), "tab, a heatmap with the number of endpoints is shown for all datasets (x-axis).", br(),
      "Data can be filtered by", strong("Phase", .noWS = "after"), ",", strong("Lab", .noWS = "after"), ", and", strong("Condition", .noWS = "after"), ".", br(),
      "Endpoints are grouped in three categories:", em("All", .noWS = "after"), ",", em("General Phenotype Terms", .noWS = "after"), ", and", em("Granular Phenotype Terms", .noWS = "after"), ".", br(),
      "The endpoints in a certain category can be viewed by hovering over each cell", br(),
      span("Lightgray", style = "background:darkgray", .noWS = "before"), "color indicates that the phenotype group is not evaluated in a certain dataset.",
      style="display:inline"
    )
  )
}
