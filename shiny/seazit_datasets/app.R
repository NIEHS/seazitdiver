library(tidyverse)
library(RColorBrewer)
library(reactablefmtr)
library(readxl)
library(bsplus)
library(bsicons)
library(shiny)
library(pool)
library(tippy)
library(plotly)
library(reactable)

## potential useful packages
#library(crosstalk)
#library(shinyWidgets)
#library(shinythemes)

source("./global.R")
source(file.path("./R/tb_change.R"), local = TRUE) # funcs for datasets modification
source(file.path("./R/helpers.R"), local = TRUE)
source(file.path("./R/db_queries.R"), local = TRUE) # to query directly to the database
source(file.path("./R/plot_funcs.R"), local = TRUE)
source(file.path("./R/help_text.R"), local = TRUE)


# needs to set R_CONFIG_ACTIVE in .Renviron
dw <- config::get("seazit", file = "config.yml")

# RPostgres don't have the issue of client encoding
pobj <- pool::dbPool(
  RPostgres::Postgres(),
  host = dw$server,
  user    = dw$uid,
  password    = dw$pwd,
  port   = dw$port,
  dbname = dw$database
)


# prepare the tables
# substances
substances <- get_substances(pobj)
substances1 <- adjust_chemical_tbl_cols(substances) %>% filter(!substance_type == "Vehicle Control")
chem_cols <- read_excel(file.path("./data/chemical_add_cols.xlsx"))
substances1 <- substances1 %>% left_join(chem_cols, by = "casrn")

# protocols
protocols <- get_protocols(pobj) # api_base in global.r
new_protocols <- read_excel(file.path("./data/protocol_parameters.xlsx"), sheet = "clean")
protocols <- add_protocol_cols(protocols, new_protocols)

# ontology
ontos <- get_ontologies(pobj)
onto <- read_excel(file.path("./data/ontology.xlsx"))
sankeyd <- readRDS(file.path("./data/ontology_sankey_bg.rds"))

# data density
source(file.path("endpoints-tab", "bin", "plot_functions.R"), local = TRUE)
vars <- readRDS(file.path("endpoints-tab", "data", "seazit.rds"))

ui <- fluidPage(

  tags$style(
    ".sankey-node text { text-shadow: none !important; font-weight: bold;}"
  ),
  includeCSS("www/test_condition_class.css"),
  #theme = shinytheme("sandstone"),


  tabsetPanel(id = "datatabs",
      tabPanel(
            "Protocols",
             p("Tab", style = "display:inline", a(bs_icon("info-circle", "1em", title = "More information on lab-specific experimental protocols"), href = "#") %>%
                 bs_attach_collapse(id = "p_help_bs")
              ),
             # tooltip is not needed because title will do
             #shiny_iconlink() %>% bs_embed_tooltip(title = "More information on lab-specific experimental protocols") %>% bs_attach_collapse(id = "p_help_bs"),
             value = "SEAZIT_Protocols",
             br(),
             bs_collapse(
               id = "p_help_bs",
               content = tags$div(class = "alert alert-info", protocol_help_text())
             ),
             br(),
             h4("Filter the table using Study Phase, Laboratory, and Test Condition"),
             downloadButton("protocol_dl", label = "Download Table"),
             hr(),
             fluidRow(
               column(4, uiOutput(outputId = "sel1")),
               column(4, uiOutput(outputId = "sel2")),
               column(4, uiOutput(outputId = "sel3"))
             ),
             reactableOutput(outputId = "out_settbl")

    ),
    tabPanel(
             "Test Substances", value = "SEAZIT_TestSubstances",
             p("Tab", style = "display:inline", a(bs_icon("info-circle", "1em", title = "More information on test substances"), href = "#") %>%
                 bs_attach_collapse("sub_help_bs")
              ),
             br(),
             bs_collapse(
               id = "sub_help_bs",
               content = tags$div(class = "alert alert-info", substance_help_text())
             ),
             br(),
             h4("Click the pie to filter the table based on the selected substances"),
             downloadButton("substance_dl", label = "Download Table"),
             hr(),
             actionButton("all_sub_btn", "See All Substances"),
             plotlyOutput(outputId = "out_pie",  width = "100%"),
             actionButton("expand_btn", "Expand Rows"),
             actionButton("collapse_btn", "Collapse Rows"),
             reactableOutput(outputId = "out_subtbl")
    ),

    tabPanel("Phenotype Ontology",
             p("Tab", style = "display:inline", a(bs_icon("info-circle", "1em", title = "More information on phenotype ontology"), href = "#") %>%
                 bs_attach_collapse("onto_help_bs")),
             br(),
             bs_collapse(
               id = "onto_help_bs",
               content = tags$div(class = "alert alert-info", ontology_help_text())
             ),
             br(),
             tabsetPanel(id = "ontotabs",
               br(),
               div(
                 style = "display: flex; justify-content: center; align-items: center;",
                 tags$img(src = "larva_image/larva_seazit.png", width = "70%", height = "100%")

               ),

               tabPanel("Table", value = "SEAZIT_OntologyMap",
                        br(),
                        h4("Click the Body Part column of the table to show the ontology mapping"),
                        downloadButton("ontology_dl", label = "Download Table"),
                        hr(),
                        actionButton("expand_btn1", "Expand Rows"),
                        actionButton("collapse_btn1", "Collapse Rows"),
                        reactableOutput(outputId = "out_ontotbl")
               ),
               tabPanel("Sankey Diagram",
                        br(),
                        h4("Select a Laboratory to see the Sankey diagram of ontology mapping"),
                        hr(),
                        selectInput(
                          'sank_sel', 'Select Laboratory',
                          choices = list('Lab A' = "biobide", "Lab B" = "osu", "Lab C" = "zeclinics"),
                          selected = "biobide",
                          multiple = FALSE
                        ),
                        br(),
                        plotlyOutput(outputId = "out_sankey",  width = "100%", height = "700px")
               ),
               tabPanel(
                 "Data Density",
                 source(
                   file.path("endpoints-tab", "app", "ui2.R"),
                   local = TRUE
                 )$value
               )
             )
    )#,

    # tabPanel(
    #   "Number of Endpoints",
    #   source(file.path("endpoints-tab", "app", "ui.R"), local = TRUE)$value
    # )
  ),

  # activate tooltips, popovers, and MathJax
  use_bs_tooltip(),
  use_bs_popover(),
  withMathJax()

)

server <- function(input, output, session) {


########## dataset tab start ###############

  datasettb <- reactive({
    if (is.null(input$render_sel1) | is.null(input$render_sel2) | is.null(input$render_sel3)) return(protocols)

    protocols %>%
      filter(
        study_phase %in% input$render_sel1,
        lab_anonymous_code %in% input$render_sel2,
        test_condition %in% input$render_sel3,
      )
  })

  # get the low occurence values for every column
  datasettb_unique <- reactive({
    dd <- datasettb()
    list_low_freq_tb(dd)
  })


  # selection options
  output$sel1 <- renderUI({
    choices <- unique(datasettb()$study_phase)
    selectInput(inputId = "render_sel1", label = "Study Phase", selected = choices, choices = choices, multiple = TRUE)
  })
  output$sel2 <- renderUI({
    choices <- unique(datasettb()$lab_anonymous_code)
    selectInput(inputId = "render_sel2", label = "Laboratory", selected = choices, choices = choices, multiple = TRUE)
  })
  output$sel3 <- renderUI({
    choices <- unique(datasettb()$test_condition)
    selectInput(inputId = "render_sel3", label = "Test Condition", selected = choices, choices = choices, multiple = TRUE)
  })

  # download table (all rows, no matter the selection)
  output$protocol_dl <- downloadHandler(
    filename = function() {
      paste0(input$datatabs, ".csv") # use write_excel_csv can solve the special characters issue
    },
    content = function(file) {
      write_excel_csv(protocols, file)
    }
  )


  # reactable
  output$out_settbl <- renderReactable({
    reactable(
      datasettb(),
      defaultColDef = colDef(
        align = "center",
        minWidth = 200
        #headerStyle = list(background = "#dfe3ee")
        #will show the original
        #footer = function(values, name) htmltools::div(name, style = list(fontWeight = 600))
      ),
      columns = list(
        protocol_name_long = colDef(
          name = "Dataset Name / (abbreviated name)",
          headerStyle = list(background = "#f0fff0"),
          minWidth = 200,
          cell = function(value, index) {
            plot_name <- datasettb()$protocol_name_plot[index]
            div(
              div(style = list(fontWeight = 600), value),
              div(style = list(fontSize = 12), plot_name)
            )
          },
          sticky = "left",
          style = list(background = "#f0fff0")
        ),
        test_condition = colDef(
          name = "Test Condition",
          headerStyle = list(background = "#f0fff0", borderRight = "2px solid rgba(0, 0, 0, 0.1)"),
          minWidth = 200,
          cell = function(value) {
            value_type <- str_extract(value, "(S-C|S-DC|SR-C|SR-DC)")
            class <- paste0("tag status-", tolower(value_type))
            div(class = class, value)
          },
          sticky = "left",
          style = list(background = "#f0fff0", borderRight = "2px solid rgba(0, 0, 0, 0.1)")
        ),
        protocol_name_plot = colDef(show = FALSE),
        study_phase = colDef(show = FALSE),
        lab_anonymous_code = colDef(show = FALSE),
        `Embryo Dechorination` = colDef(
          name = "Embryo Dechorination",
          style = function(value) {color <- if_else(value %in% datasettb_unique()$`Embryo Dechorination` , "red", "black"); list(color = color)}
        ),
        time_24hpf = colDef(
          name = "24hpf",
          header = with_tooltip("24hpf", "hours post fertilization"),
          style = function(value) {color <- if_else(value %in% datasettb_unique()$time_24hpf , "red", "black"); list(color = color)}
        ),
        time_120hpf = colDef(
          name = "120hpf",
          header = with_tooltip("120hpf", "hours post fertilization"),
          headerStyle = list(borderRight = "2px solid rgba(0, 0, 0, 0.1)"),
          style = list(borderRight = "2px solid rgba(0, 0, 0, 0.1)")
        ),
        plate_format = colDef(
          name = "Format",
          style = function(value) {color <- if_else(value %in% datasettb_unique()$`plate_format` , "red", "black"); list(color = color)}
        ),
        plate_n_embryo_well = colDef(
          name = "N embryo/well",
          headerStyle = list(borderRight = "2px solid rgba(0, 0, 0, 0.1)"),
          style = function(value) {color <- if_else(value %in% datasettb_unique()$plate_n_embryo_well , "red", "black"); list(color = color, borderRight = "2px solid rgba(0, 0, 0, 0.1)")}
        ),
        exposure_volume = colDef(
          name = "Volume",
          style = function(value) {color <- if_else(value %in% datasettb_unique()$`exposure_volume` , "red", "black"); list(color = color)}
        ),
        exposure_scenario = colDef(
          name = "Scenario",
          headerStyle = list(borderRight = "2px solid rgba(0, 0, 0, 0.1)"),
          style = function(value) {color <- if_else(value %in% datasettb_unique()$plate_n_embryo_well , "red", "black"); list(color = color, borderRight = "2px solid rgba(0, 0, 0, 0.1)")}
        ),
        VC_name = colDef(name = "Name"),
        VC_n_embryo_plate = colDef(
          name = "N embryo/plate",
          headerStyle = list(borderRight = "2px solid rgba(0, 0, 0, 0.1)"),
          style = function(value) {color <- if_else(value %in% datasettb_unique()$VC_n_embryo_plate , "red", "black"); list(color = color, borderRight = "2px solid rgba(0, 0, 0, 0.1)")}
        ),
        PC_name = colDef(name = "Name"),
        PC_conc = colDef(name = "Concentrations"),
        PC_n_embryo_concentration_plate = colDef(
          name = "N embryo/conc/plate",
          headerStyle = list(borderRight = "2px solid rgba(0, 0, 0, 0.1)"),
          style = function(value) {color <- if_else(value %in% datasettb_unique()$PC_n_embryo_concentration_plate , "red", "black"); list(color = color, borderRight = "2px solid rgba(0, 0, 0, 0.1)")}
        ),
        TS_n_ts_plate = colDef(name = "N substance/plate"),
        TS_conc = colDef(
          name = "Concentrations",
          header = with_tooltip("Concentrations", "a fixed test range was used in the Dose Range Finding (DRF) phase; exceptions for compounds with enhanced potency or limited solubility")
          ),
        TS_n_embryo_conc_plate = colDef(
          name = "N embryo/conc/plate",
          style = function(value) {color <- if_else(value %in% datasettb_unique()$TS_n_embryo_conc_plate , "red", "black"); list(color = color)}
        ),
        TS_test_freq = colDef(name = "Test Frequency"),
        `Zebrafish Strain` = colDef(
          name = "Zebrafish Strain",
          style = function(value) {color <- if_else(value %in% datasettb_unique()$`Zebrafish Strain` , "red", "black"); list(color = color)}
        ),
        `Incubation Temperature` = colDef(
          name = "Incubation Temperature",
          headerStyle = list(borderRight = "2px solid rgba(0, 0, 0, 0.1)"),
          style = function(value) {color <- if_else(value %in% datasettb_unique()$`Incubation Temperature` , "red", "black"); list(color = color, borderRight = "2px solid rgba(0, 0, 0, 0.1)")}
        )

      ),
      columnGroups = list(
        colGroup(name = "Assessment Timepoint", columns = c("time_24hpf", "time_120hpf"), headerStyle = list(background = "#E0EEE0")),
        colGroup(name = "Plate Setting", columns = c("plate_format", "plate_n_embryo_well"),  headerStyle = list(background = "#E0EEE0")),
        colGroup(name = "Exposure", columns = c("exposure_volume", "exposure_scenario"), headerStyle = list(background = "#E0EEE0")),
        colGroup(name = "Vehicle Control",
                 header = with_tooltip("Vehicle Control", "1% (0.64% in Lab B) dimethylsulfoxide (DMSO) in select cases to match scenarios where compounds were dissolved in 1% DMSO"),
                 columns = c("VC_name", "VC_n_embryo_plate"), headerStyle = list(background = "#E0EEE0")),
        colGroup(name = "Positive Control", columns = c("PC_name", "PC_conc", "PC_n_embryo_concentration_plate"), headerStyle = list(background = "#E0EEE0")),
        colGroup(name = "Test Substance", columns = c("TS_conc", "TS_n_ts_plate", "TS_n_embryo_conc_plate", "TS_test_freq"), headerStyle = list(background = "#E0EEE0")),
        colGroup(name = "Embryo Setting", columns = c("Zebrafish Strain", "Embryo Dechorination", "Incubation Temperature"), headerStyle = list(background = "#E0EEE0")),
        colGroup(name = "Dataset Information", columns = c("protocol_name_long", "test_condition"),
                 headerStyle = list(background = "#E0EEE0"))


      ),
      sortable = TRUE,
      filterable = TRUE,
      searchable = TRUE,
      bordered = TRUE,
      highlight = TRUE,
      defaultPageSize = 15,
      #showPageSizeOptions = TRUE
      showPagination = TRUE
    )
  })

################### dataset tab end ###################

################## substances tab start ###############################


  output$out_pie <- renderPlotly({
    pied <- substances1  %>% distinct(dtxsid, use_category1) %>% count(use_category1)
    #customdata needs to be set in the plotly function
    use_category_pie_plot(pied, sourceId = "cate_pie")
  })


  # set an reactive data in order to reset it
  # this is the only way to make reactable index work otherwise updateReactable will mess up the index
  reactive_data <- reactiveValues(e = NULL)
  observe({
    reactive_data$e <- event_data("plotly_click", source = "cate_pie")
  })
  observeEvent(input$all_sub_btn, {
    reactive_data$e <- NULL
  })

  observeEvent(input$expand_btn, {
    # Expand all rows
    updateReactable("out_subtbl", expanded = TRUE)
  })

  observeEvent(input$collapse_btn, {
    # Collapse all rows
    updateReactable("out_subtbl", expanded = FALSE)
  })

  # download table (all rows, no matter the selection)
  output$substance_dl <- downloadHandler(

    filename = function() {
      paste0(input$datatabs, ".csv")
    },
    content = function(file) {
      write_excel_csv(substances1, file)
    }
  )


  output$out_subtbl <- renderReactable({

    # this is the reactive_data object linked to plotly event_reactive
    if(is.null(reactive_data$e)) {
      t1 <- substances1
    } else {
      t1 <- substances1 %>% filter(use_category1 == reactive_data$e$customdata[[1]])
    }

    reactable(
      t1,
      groupBy = c( "use_category2"),
      defaultColDef = colDef(
        align = "center",
        style = function(value) {
          if (value == "-" | is.na(value) | value == "NA") {
            color <- "grey"
          } else {
            color <- "black"
          }
          list(color = color)}
        #headerStyle = list(background = "#f0fff0")
      ),
      columns = list(
        dtxsid = colDef(
          name = "DTXSID in EPA Chemical Dashboard",
          cell = function(value) {
            url <- str_glue("https://comptox.epa.gov/dashboard/chemical/details/", value)
            htmltools::tags$a(href = url, target = "_blank", value)
          }
        ),
        preferred_name = colDef(
            name = "Substance Name",
            width = 210,
            cell = function(value, index) {
              #image <- img(src = str_c(chemdash_img_api_link(), t1[index, "dtxsid"]), height = "200px", alt = value)
              image <- img(src = str_c("structure/", t1[index, "dtxsid"], ".png"), height = "200px", alt = value)
              tagList(
                div(style = list(display = "inline-block", width = "200px"), image),
                value
              )
            },
            aggregate = "unique"
          ),
        casrn = colDef(
          name = "CAS Registry Number",
          style = list(borderRight = "2px solid rgba(0, 0, 0, 0.1)"),
          headerStyle = list(borderRight = "2px solid rgba(0, 0, 0, 0.1)")
        ),
        use_category1 = colDef(
          name = "Use Category (Level 1)",
          style = list(background = "#f0fff0", borderRight = "2px solid rgba(0, 0, 0, 0.1)"),
          headerStyle = list(background = "#f0fff0", borderRight = "2px solid rgba(0, 0, 0, 0.1)"),
          aggregate = "unique"
        ),
        substance_code = colDef(
          name = "Substance Code",
          style = list(borderRight = "2px solid rgba(0, 0, 0, 0.1)"),
          headerStyle = list(borderRight = "2px solid rgba(0, 0, 0, 0.1)")
          ),
        substance_type = colDef(
          name = "Substance Type",
          style = function(value) {
            if (value == "Blinded Duplicate") {
              color <- "red"
            } else {
              color <- "black"
            }
            list(color = color)}
        ),
        use_category2 = colDef(
          name = "Use Cateogry (Level 2)",
          headerStyle = list(background = "#f0fff0"),
          style = list(background = "#f0fff0"),
          aggregate = "unique"
        ),
        `Molecular Weight` = colDef(
          name = "Molecular Weight",
          header = with_tooltip("Molecular Weight", "visualized by length of bar after expanding rows"),
          aggregate = min_max_aggregate(),
          cell = data_bars(t1,
                           bar_height = 3,
                           text_position = "above",
                           background = "transparent"
                           ),
          format = list(
            aggregated = colFormat(prefix = "range: ")
          )
        ),
        logP = colDef(
          name = "Octanol-Water Partition Coefficient",
          header = with_tooltip("Octanol-Water Partition Coefficient", "logP, higher logP/hydrophobic -> warmer color after expanding rows"),
          cell = color_tiles(t1),
          aggregate = min_max_aggregate(),
          format = list(
            aggregated = colFormat(prefix = "range: ")
          ),
          style = list(borderRight = "2px solid rgba(0, 0, 0, 0.1)"),
          headerStyle = list(borderRight = "2px solid rgba(0, 0, 0, 0.1)")
        ),
        toxcast_zebrafish = colDef(name = "ToxCast Zebrafish Data Available?", aggregate = "frequency"),
        invivo_rodent = colDef("In Vivo Rodent Data Available?", aggregate = "frequency"),
        ntp_zebrafish = colDef(
          name = "NTP Published Data Available?",
          style = list(borderRight = "2px solid rgba(0, 0, 0, 0.1)"),
          headerStyle = list(borderRight = "2px solid rgba(0, 0, 0, 0.1)")
        ),
        recommend_by_information_group = colDef("Recommended by the Information Group?"),
        additional_rationale = colDef("Additional Rationale for Inclusion")
      ),

      columnGroups = list(
        colGroup(name = "Use Category", columns = c("use_category1", "use_category2"), headerStyle = list(background = "#E0EEE0")),
        colGroup(name = "Public Identification", columns = c("preferred_name", "dtxsid", "casrn"),  headerStyle = list(background = "#E0EEE0")),
        colGroup(name = "Internal Identification", columns = c("substance_code", "substance_type"), headerStyle = list(background = "#E0EEE0")),
        colGroup(name = "Physico-Chemical Properties",
                 header = with_tooltip("Physico-Chemical Properties", "from ChemSpider"),
                 columns = c("Molecular Weight", "logP"), headerStyle = list(background = "#E0EEE0")),
        colGroup(name = "In Vivo Data Availability",
                 header = with_tooltip("In Vivo Data Availability", "from either ToxRefDB, internal NTP studies, or in ECHA; more details in the Resources Page"),
                 columns = c("toxcast_zebrafish", "invivo_rodent", "ntp_zebrafish"), headerStyle = list(background = "#E0EEE0")),
        colGroup(name = "Others", columns = c("recommend_by_information_group", "additional_rationale"), headerStyle = list(background = "#E0EEE0"))
      ),

      #defaultExpanded = TRUE,
      sortable = TRUE,
      filterable = TRUE,
      searchable = TRUE,
      bordered = TRUE,
      highlight = TRUE,
      showPageSizeOptions = TRUE,
      defaultPageSize = 15,
      showPagination = TRUE
    )

  })

########### substance tab end ######################

############## ontology tab start #############################

  # Download the whole ontology table
  output$ontology_dl <- downloadHandler(

    filename = function() {
      paste0(input$ontotabs, ".csv")
    },
    content = function(file) {
      write_excel_csv(onto, file)
    }
  )

  observeEvent(input$expand_btn1, {
    # Expand all rows
    updateReactable("out_ontotbl", expanded = TRUE)
  })

  observeEvent(input$collapse_btn1, {
    # Collapse all rows
    updateReactable("out_ontotbl", expanded = FALSE)
  })

  output$out_ontotbl <- renderReactable({
    reactable(
      onto,
      groupBy = c( "body_part"),
      defaultColDef = colDef(
        align = "center"
      ),
      columns = list(
        ontology_id = colDef(
          name = "Ontology Identification (ID)",
          cell = function(value) {
            value1 <- str_replace(value, ":", "_")
            url <- str_glue("https://www.ebi.ac.uk/ols/ontologies/zp/terms?iri=http%3A%2F%2Fpurl.obolibrary.org%2Fobo%2F", value1)
            htmltools::tags$a(href = url, target = "_blank", value)
          }),
        lab_a = colDef(
          name = "Lab A",
          #aggregate = "unique", # JS background not working
          #style = function(value) { background <- if_else(!is.na(value), "yellow", "white"); list(background = background)} # not working on aggregated
          style = color_ontolgy_table("lab_a")
        ),
        lab_b = colDef(
          name = "Lab B",
          style = color_ontolgy_table("lab_b")
        ),
        lab_c = colDef(
          name = "Lab C",
          headerStyle = list(borderRight = "2px solid rgba(0, 0, 0, 0.1)"),
          style = color_ontolgy_table("lab_c", border = "yes")
        ),
        body_part = colDef(
          name = "Body Part",
          headerStyle = list(background = "#f0fff0", borderRight = "2px solid rgba(0, 0, 0, 0.1)"),
          style = list(background = "#f0fff0", borderRight = "2px solid rgba(0, 0, 0, 0.1)")
        ),
        proposed_ontology_label = colDef(
          name = "Proposed Ontology Term",
          style = color_ontolgy_table("proposed_ontology_label")
        )
      ),
      columnGroups = list(
        colGroup(name = "Laboratory Specific Recording Term", columns = c("lab_a", "lab_b", "lab_c"), headerStyle = list(background = "#E0EEE0")),
        colGroup(name = "Ontology", columns = c("proposed_ontology_label", "ontology_id"),  headerStyle = list(background = "#E0EEE0")),
        colGroup(name = "Altered Phenotype Location", columns = c("body_part"), headerStyle = list(background = "#E0EEE0"))
      ),
      sortable = FALSE,
      filterable = TRUE,
      searchable = TRUE,
      bordered = TRUE,
      #highlight = TRUE, not working when set the background
      showPageSizeOptions = TRUE,
      defaultPageSize = 20
    )
  })



  # collect data for Sankey
  sankey_input <- reactive({
    req(input$sank_sel)
    ex1 <- ontos %>% filter(protocol_source %in% input$sank_sel)
    new_nodes <- filter_sankey_nodes(sankeyd$nodes, input$sank_sel, ex1)
    new_flows <- filter_sankey_flows(sankeyd$flows, ex1)
    new_flows <- change_sankey_flows(new_flows, new_nodes)
    list(nodes = new_nodes, flows = new_flows)
  })


  # Sankey plot
  output$out_sankey <- renderPlotly({
    ontology_sankey_plot(sankey_input())
  })



####################### ontology tab end ##################

  # Number of endpoints tab
  # source(file.path("endpoints-tab", "app", "server.R"), local = TRUE)
  source(file.path("endpoints-tab", "app", "server2.R"), local = TRUE)


}

# Run the application
shinyApp(ui = ui, server = server)
