div(
  # tags$head(
  #   tags$link(
  #     rel = "stylesheet",
  #     type = "text/css",
  #     href = file.path("endpoints-tab", "style.css"))
  # ),
  sidebarLayout(
    sidebarPanel(
      width = 3,
      # class = "compact-checkgroup",
      checkboxGroupInput(
        "phaseCheckGroup",
        label = h4("Phase"),
        choices = vars$dataset$choices$Phases,
        selected = vars$dataset$choices$Phases
      ),
      checkboxGroupInput(
        "labCheckGroup",
        label = h4("Lab"),
        choices = vars$dataset$choices$Labs,
        selected = vars$dataset$choices$Labs
      ),
      checkboxGroupInput(
        "conditionCheckGroup",
        label = h4("Condition"),
        choices = vars$dataset$choices$Conditions,
        selected = vars$dataset$choices$Conditions
      )
    ),
    mainPanel(
      width = 9,
      uiOutput("ontologyPlotWrapper")
    )
  )
)
