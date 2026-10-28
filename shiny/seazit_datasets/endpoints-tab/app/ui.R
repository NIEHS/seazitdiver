div(
  wellPanel(
    style = "margin-top: 15px; padding-bottom: 0px; padding-top: 5px;",
    fluidRow(
      column(
        4,
        fluidRow(
          h4("Substances", style="margin: 5px;")
        ),
        fluidRow(
          column(
            6,
            pickerInput(
              inputId  = "substance_group",
              label    = "By Group",
              choices  = names(vars$substance$choices),
              selected = names(vars$substance$choices),
              multiple = TRUE,
              options  = pickerOptions(
                actionsBox = TRUE,
                style = "btn-default toggleIcons" # Extra class is used in "script.js"
              )
            )
          ),
          column(
            6,
            pickerInput(
              inputId  = "substance",
              label    = "By Name",
              choices  = vars$substance$choices,
              selected = vars$substance$map$name,
              multiple = TRUE,
              options  = pickerOptions(
                actionsBox = TRUE,
                liveSearch = TRUE,
                selectedTextFormat = "count > 3"
              )
            )
          )
        )
      ),
      column(
        3,
        offset = 1,
        fluidRow(
          h4("Datasets", style="margin: 5px;")
        ),
        fluidRow(
          column(
            12,
            pickerInput(
              inputId  = "dataset",
              label    = NULL,
              choices  = vars$dataset$choices,
              selected = unlist(vars$dataset$choices, use.names = FALSE),
              multiple = TRUE
            )
          )
        )
      ),
      column(
        3,
        offset = 1,
        fluidRow(
          h4("Endpoint Ontology Categories", style="margin: 5px; padding-bottom: 10px;")
        ),
        fluidRow(
          column(
            12,
            awesomeRadio(
              inputId  = "grouping",
              label    = NULL,
              choices  = c("All", "General", "Granular"),
              selected = "All"
            )
          )
        )
      )
    )
  ),
  fluidRow(
    # uiOutput("numbers"),
    uiOutput("plotWrapper")
  ),
  tags$script(src = file.path("endpoints-tab", "script.js"))
)
