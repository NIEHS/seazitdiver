output$ontologyPlotWrapper <- renderUI({
  
  datasets <- vars$dataset$map %>% 
    filter(
      phase     %in% input$phaseCheckGroup,
      lab       %in% input$labCheckGroup,
      condition %in% input$conditionCheckGroup
    )
  
  if (nrow(datasets) == 0) {
    
    p("No datasets selected")
    
  } else {
    
    output$ontologyPlot <- renderPlotly({
      makeOntologyPlot(
        datasets,
        vars$endpoints[["all"]],
        vars$endpoints[["general"]],
        vars$endpoints[["granular"]]
      )
    })
    
    plotlyOutput("ontologyPlot", height = 800)
    
  }
})
