selectInputColumnUI <- function(id) {
  ns <- NS(id)
  uiOutput(ns("controls"))
}


selectInputColumnServer <- function(id, data, col_name, label_name, multiple = TRUE) {
  moduleServer(
    id,
    function(input, output, session) {
      output$controls <- renderUI({
        ns <- session$ns
        choices <- unique(unlist(data()[, col_name]))
        selectInput(ns("inp"), label = label_name, selected = choices, choices = choices, multiple = multiple)
      })

      return(reactive({
        validate(need(input$inp, message = FALSE))
        data() %>% filter(!!as.symbol(col_name) %in% input$inp)
      }))
    }
  )
}
