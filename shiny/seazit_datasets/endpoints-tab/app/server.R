##############################
# Initialize variables

updatePlot <- reactiveVal(0)

# These should match the pickerInput selected values in the ui. They are
# used to track changes in the pickerInput values.
session$userData$substance <- list(
  selectedGroups = names(vars$substance$choices),
  selected       = vars$substance$map$name
)

##############################
# Observers

###############
# Substance change
#####

observeEvent(input$substance, {
  
  selected <- if (is.null(input$substance)) character(0) else input$substance
  selectedGroups <- vars$substance$map %>%
    filter(name %in% selected) %>%
    distinct(group) %>%
    pull()
  updateUI <- !setequal(selectedGroups, session$userData$substance$selectedGroups)
  
  # Update tracking values
  session$userData$substance$selectedGroups <- selectedGroups
  session$userData$substance$selected       <- selected
  
  # Update UI
  if (updateUI) {
    updatePickerInput(
      session,
      inputId = "substance_group",
      selected = selectedGroups
    )
  }
  
  updatePlot(updatePlot() + 1)
  
}, ignoreInit = TRUE, ignoreNULL = FALSE)

###############
# Substance group change
#####

observeEvent(input$substance_group, {
  
  if (is.null(input$substance_group)) {
    
    # If the input is NULL, then no groups are selected
    selectedGroups <- character(0)
    selected       <- character(0)
    updateUI       <- length(input$substance) > 0
    
  } else {
    
    selectedGroups <- input$substance_group
    selected       <- input$substance
    
    # Groups to remove
    rmGroups <- setdiff(session$userData$substance$selectedGroups, selectedGroups)
    if (length(rmGroups) > 0) {
      selected <- intersect(
        selected,
        unlist(vars$substance$choices[selectedGroups], use.names = FALSE)
      )
    }
    
    # Groups to add
    addGroups <- setdiff(selectedGroups, session$userData$substance$selectedGroups)
    if (length(addGroups) > 0) {
      selected <- union(
        selected,
        unlist(vars$substance$choices[addGroups], use.names = FALSE)
      )
    }
    
    updateUI <- !setequal(selected, session$userData$substance$selected)
    
  }
  
  # Update tracking values
  session$userData$substance$selectedGroups <- selectedGroups
  session$userData$substance$selected       <- selected
  
  # Update UI
  if (updateUI) {
    updatePickerInput(
      session,
      inputId = "substance",
      selected = selected
    )
  }
  
}, ignoreInit = TRUE, ignoreNULL = FALSE)

###############
# Update plot
#####

observeEvent({updatePlot(); input$dataset; input$grouping}, {
  
  substances <- vars$substance$map %>% 
    filter(
      name %in% session$userData$substance$selected
    )
  
  datasets <- vars$dataset$map %>% 
    filter(
      phase     %in% input$dataset,
      lab       %in% input$dataset,
      condition %in% input$dataset
    )
  
  counts <- vars$counts[[tolower(input$grouping)]]
  
  ontologies <- data.frame(ontology = sort(unique(counts$ontology)))
  
  if (nrow(substances) == 0 || nrow(datasets) == 0) {
    output$plot <- NULL
    output$plotWrapper <- renderUI({
      p("No data found")
    })
  } else {
    output$plot <- renderPlotly({
      makePlot(substances, datasets, ontologies, counts)
    })
    output$plotWrapper <- renderUI({
      plotlyOutput("plot", height = 200 + 15*nrow(substances))
    })
  }
  
  # output$numbers <- renderUI({
  #   nSel <- nrow(vars$substance$map)
  #   mSel <- nrow(substances)
  #   nDat <- nrow(vars$dataset$map)
  #   mDat <- nrow(datasets)
  #   nGrp <- nrow(ontologies)
  #   div(
  #     p(paste("update ", updatePlot()), style = "margin-bottom: 0;"),
  #     p(paste0(mSel, "/", nSel, " substances"), style = "margin-bottom: 0;"),
  #     p(paste0(mDat, "/", nDat, " datasets"), style = "margin-bottom: 0;"),
  #     p(paste0(nGrp, " endpoint ontology categor", if (nGrp != 1) "ies" else "y"))
  #   )
  # })
  
})
