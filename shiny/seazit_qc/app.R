

library(tidyverse)
library(crosstalk)
library(bsplus)
library(bsicons)
#library(bslib)
#library(fontawesome)
library(tippy)
library(reactable)
library(plotly)
library(shiny)

#source(file.path("./global.R"))
source(file.path("./R/db_queries.R"), local = TRUE) # to query directly to the database
source(file.path("./R/tb_change.R"), local = TRUE) # funcs for datasets modifications
source(file.path("./R/plot_funcs.R"), local = TRUE) # plotly functions
source(file.path("./R/select_module.R"), local = TRUE) # shiny module
source(file.path("./R/helpers.R"), local = TRUE) # smaller helper functions

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




# Get the protocols in the database
protocols <- get_protocols(pobj) # api_base in global.r
#protocols <- add_protocol_filters(protocols) #already update the protocol table


substances <- get_substances(pobj)
substances1 <- substances %>% distinct(substance_code, preferred_name, dtxsid, casrn)



## intead of click used selected

ui <- fluidPage(

    #theme =  bs_theme(version = "5", preset = "litera"), not compatible at this point
    #titlePanel("Quality Check"),
    h4("Use Study Phase, Laboratory, and Test Condition to select datasets of interest", style = "display:inline",  a(bs_icon("info-circle", "1em", title = "Use panels below to select datasets"), href = "#") %>%
         bs_attach_collapse("ds_help_bs")), # this is written below
    bs_collapse(
      id = "ds_help_bs",
      content = tags$div(class = "alert alert-info", selection_help_text())
    ),
    hr(),

    # for notifications
    tags$head(tags$style(".shiny-notification {position: fixed; top: 90% ;left: 1%")),

    sidebarLayout(
        sidebarPanel(

          # print the selections
          #p(tags$label("Selected Datasets"), style = "display:inline",  a(bs_icon("info-circle", "1em", title = "Use panels below to select datasets"), href = "#") %>%
          #    bs_attach_collapse("ds_help_bs")),
          tags$label("Selected Datasets"),
          # bs_collapse(
          #   id = "ds_help_bs",
          #   content = tags$div(class = "alert alert-info", selection_help_text())
          # ),
          verbatimTextOutput(outputId = "out_t1", placeholder = TRUE),

            # hierarchical filter
            selectInput(inputId = "in1", label = "Study Phase", choices = unique(protocols$study_phase), multiple = TRUE),
            selectInput(inputId = "in2", label = "Laboratory", choices = NULL, multiple = TRUE),
            selectInput(inputId = "in3", label = "Test Condition", choices = NULL, multiple = TRUE),

            # show the action button
            conditionalPanel(
                condition = "input.in3.length > 0",
                actionButton(inputId = "bu1", label = "Get Data"),
            ),

            width = 2

        ),

        mainPanel(
            tabsetPanel(id = "qctabs",
                tabPanel(
                  "Vehicle Control",
                  p("Tab", style = "display:inline", a(bs_icon("info-circle", "1em", title = "More information on Vehicle Controls"), href = "#") %>%
                      bs_attach_collapse(id = "vc_help_bs")
                  ),
                  br(),
                  bs_collapse(
                    id = "vc_help_bs",
                    content = tags$div(class = "alert alert-info", vc_help_text())
                  ),
                  hr(),
                  # two selections: chorion_status and exposure scenario
                  uiOutput('filter_help_text_VC'),
                  fluidRow(
                    column(6, selectInputColumnUI(id = "out_vc_sel1")),
                    column(6, selectInputColumnUI(id = "out_vc_sel2"))
                  ),

                    # plotly plot
                    plotlyOutput(outputId = "out_dmso_box",  width = "100%"),


                    tabsetPanel(id = "vc_subtabs",
                        tabPanel("response by time/dataset", value = "RespTime",
                            # selection of the endpoints
                            uiOutput(outputId = "out_vc_sel3"),
                            # plotly plot
                            plotlyOutput(outputId = "out_dmso_click", width = "100%")
                        ),
                        tabPanel("response table", value = "RespTable",
                            br(),
                            downloadButton("vc_resp_dl", label = "Download Table"),
                            reactableOutput(outputId = "out_resptbl")
                        )

                    )
                ),
                tabPanel(
                  "Positive Control",
                  p("Tab", style = "display:inline", a(bs_icon("info-circle", "1em", title = "More information on positive control tab"), href = "#") %>%
                      bs_attach_collapse(id = "pc_help_bs")
                  ),
                  br(),
                  bs_collapse(
                    id = "pc_help_bs",
                    content = tags$div(class = "alert alert-info", pc_help_text())
                  ),
                  hr(),
                  uiOutput('filter_help_text_PC'),
                  fluidRow(
                    column(6, selectInputColumnUI(id = "out_pc_sel1"),),
                    column(6, selectInputColumnUI(id = "out_pc_sel2"),)
                  ),

                    #plotly plot
                    plotlyOutput(outputId = "out_pc_box",  width = "100%"),

                    tabsetPanel(id = "pc_subtabs",
                        tabPanel("activity table", value = "PCActTable",
                            br(),
                            downloadButton("pc_bmc_dl", label = "Download Table"),
                            reactableOutput(outputId = "out_pcbmc_tbl")
                        )

                    )

                ),
                tabPanel(
                  title = "Duplicates",
                  p("Tab", style = "display:inline", a(bs_icon("info-circle", "1em", title = "More information on duplicates tab"), href = "#") %>%
                      bs_attach_collapse(id = "dup_help_bs")
                  ),
                  br(),
                  bs_collapse(
                    id = "dup_help_bs",
                    content = tags$div(class = "alert alert-info", dup_help_text())
                  ),
                  hr(),
                  uiOutput('filter_help_text_Dup'),
                    fluidRow(
                        column(4, selectInputColumnUI(id = "out_dup_sel1"),),
                        column(4, selectInputColumnUI(id = "out_dup_sel2"),),
                        column(4, selectInputColumnUI(id = "out_dup_sel3"),)
                    ),
                    plotly::plotlyOutput("out_dup_box", width = "100%", height = "100%"),

                    tabsetPanel(id = "dup_subtabs",
                        tabPanel("activity table", value = "DupActTable",
                            br(),
                            downloadButton("dup_bmc_dl", label = "Download Table"),
                            reactableOutput(outputId = "out_dupbmc_tbl")
                        )

                    )
                )

            )

        )
    )
)

server <- function(input, output, session) {


    # filter protocol by study phase
    f_in1 <- reactive({
        filter(protocols, study_phase %in% input$in1)
    })

    # update the selectinput by lab
    observeEvent(f_in1(), {
        freezeReactiveValue(input, "in2")
        #print(f_in1())
        choices <- unique(f_in1()$lab_anonymous_code)
        updateSelectInput(inputId = "in2", choices = choices)
    })

    # filter protocol (after first selection) by lab
    f_in1_in2 <- reactive({
        req(input$in2)
        filter(f_in1(), lab_anonymous_code %in% input$in2)
    })



    # update the selectinput by test condition
    observeEvent(f_in1_in2(), {
        freezeReactiveValue(input, "in3")
        choices <- unique(f_in1_in2()$test_condition)
        updateSelectInput(inputId = "in3", choices = choices, selected = choices)
    })

    # filter protocol (after 1+2 selection) by test condition
    f_in1_in2_in3 <- reactive({
        req(input$in3)
        filter(f_in1_in2(), test_condition %in% input$in3)
    })




    # print the protocol (after 1+2+3 selection)
    output$out_t1 <- renderPrint({
        f_in1_in2_in3() %>% pull(protocol_name_plot) %>% cat(., sep = "\n")
    })

    # get the database DMSO data after action 1
    incidence_r <- eventReactive(input$bu1, {
        sel_protocol_ids <- f_in1_in2_in3() %>% pull(protocol_id)
        withProgress(message = "Downloading incidence data...", detail = NULL, {
            incProgress(message = NULL)
            map_df(sel_protocol_ids, get_incidence_by_protocol, pool_obj = pobj) %>%
                left_join(f_in1_in2_in3() %>% select(protocol_id, protocol_name_plot,  test_condition, study_phase), by = "protocol_id")
        })

    })

    dmso_incidence_r <- reactive({
        incidence_r() %>% filter(substance_code == "DMSO")
    })



    # get the database bmc data after action 1
    bmc_r <- eventReactive(input$bu1, {
        sel_protocol_ids <- f_in1_in2_in3() %>% pull(protocol_id)
        withProgress(message = "Downloading potency data...", detail = NULL, {
            incProgress(message = NULL)
            map_df(sel_protocol_ids, get_bmc_by_protocol, pool_obj = pobj) %>%
                left_join(f_in1_in2_in3() %>% select(protocol_id, protocol_name_plot, test_condition, study_phase), by = "protocol_id")
        })

    })


    # filter the bmc data (PC and 3 endpoints)
    bmc_r_pc_3only <- reactive({
        endpoint_used <- c("Mortality@24", "Mortality@120", "MalformedAny+Mort@120")
        add_bmc_pc_box_filters(
            bmc_r() %>% filter(endpoint_name %in% endpoint_used, substance_code == "PC")
        )
    })


############## DMSO start here ##############


    # filter the DMSO incidence data (3 endpoints)
    dmso_incidence_r_3only <- reactive({
        endpoint_used <- c("Mortality@24", "Mortality@120", "MalformedAny+Mort@120")
        add_dmso_boxplot_filters(
            dmso_incidence_r() %>% filter(endpoint_name %in% endpoint_used)
        )
    })

    dmso_incidence_r_3only_f1 <- selectInputColumnServer(
        id = "out_vc_sel1",
        data = reactive(dmso_incidence_r_3only()),
        col_name = "Exposure_Scenario",
        label_name = "Exposure Scenario",
        multiple = TRUE
    )

    dmso_incidence_r_3only_f2 <- selectInputColumnServer(
        id = "out_vc_sel2",
        data = reactive(dmso_incidence_r_3only_f1()),
        col_name = "Chorion_Status",
        label_name = "Chorion Status",
        multiple = TRUE
    )

    output$filter_help_text_VC <- renderUI({
      req(dmso_incidence_r_3only_f2())
      h4("Filter the data using Exposure Scenario and Chorion Status", style="text-align: center;")
    })


    # plotly plot (endpoint x response)
    #https://stackoverflow.com/questions/67466248/r-plotly-subplot-warning-layout-objects-dont-have-these-attributes-na
    output$out_dmso_box <- renderPlotly({
        #boxmode unnessary warnings
        dmso_boxplot(dmso_incidence_r_3only_f2(), "Perecent Responses of Endpoints", sourceId = "dmso_box") %>% toWebGL()

    })


    # a selectinput UI (endpoint) based on the selected data from dmso plotly
    output$out_vc_sel3 <- renderUI({

        ### this part of code does not know how to put into a "reactive" ###

        clickData <- event_data("plotly_click", source = "dmso_box")
        if (is.null(clickData)) return(NULL)

        click_data <- clickData %>% separate(customdata, c("plate_name", "protocol_id"), sep = "@")

        d <- dmso_incidence_r_3only_f1() %>% filter(protocol_id == click_data$protocol_id)

        ##################################################################

        choices <- unique(d$endpoint_name)
        selectInput(inputId = "render_in3", label = "Endpoint", width = '100%', selected = choices, choices = choices, multiple = TRUE)
    })


    # plotly plot (time vs response)
    output$out_dmso_click <- renderPlotly({
        req(input$render_in3)
        clickData <- event_data("plotly_click", source = "dmso_box")
        if (is.null(clickData)) return(NULL)

        click_data <- clickData %>% separate(customdata, c("plate_name", "protocol_id"), sep = "@")

        d <- dmso_incidence_r_3only_f1() %>% filter(protocol_id == click_data$protocol_id)

        d1 <- add_dmso_click_dotplot_filters(d, clicked_plate = click_data$plate_name) %>%
            filter(endpoint_name %in% input$render_in3)

        dmso_click_dotplot(d1)
    })

############### pc start here ###############

    bmc_r_pc_3only_f1 <- selectInputColumnServer(
        id = "out_pc_sel1",
        data = reactive(bmc_r_pc_3only()),
        col_name = "Exposure_Scenario",
        label_name = "Exposure Scenario",
        multiple = TRUE
    )



    bmc_r_pc_3only_f2 <- selectInputColumnServer(
        id = "out_pc_sel2",
        data = reactive(bmc_r_pc_3only_f1()),
        col_name = "Chorion_Status",
        label_name = "Chorion Status",
        multiple = TRUE
    )

    output$filter_help_text_PC <- renderUI({
      req(bmc_r_pc_3only_f2())
      h4("Filter the data using Exposure Scenario and Chorion Status", style="text-align: center;")
    })

    output$out_pc_box <- renderPlotly({
        pc_boxplot(bmc_r_pc_3only_f2(), "Activity of Endpoints", sourceId = "pc_box") %>% toWebGL()

    })

############## duplicate start here  ###########

    bmc_r_dup_3only <- reactive({
        endpoint_used <- c("Mortality@24", "Mortality@120", "MalformedAny+Mort@120")
        dups <- flatten_dbl(duplicate_codes())
        add_bmc_dup_box_filters(
            bmc_r() %>% filter(endpoint_name %in% endpoint_used, substance_code %in% dups) %>%
                left_join(substances1, by = "substance_code")
        )
    })

    bmc_r_dup_3only_f1 <- selectInputColumnServer(
        id = "out_dup_sel1",
        data = reactive(bmc_r_dup_3only()),
        col_name = "Exposure_Scenario",
        label_name = "Exposure Scenario",
        multiple = TRUE
    )



    bmc_r_dup_3only_f2 <- selectInputColumnServer(
        id = "out_dup_sel2",
        data = reactive(bmc_r_dup_3only_f1()),
        col_name = "Chorion_Status",
        label_name = "Chorion Status",
        multiple = TRUE
    )

    bmc_r_dup_3only_f3 <- selectInputColumnServer(
        id = "out_dup_sel3",
        data = reactive(bmc_r_dup_3only_f2()),
        col_name = "endpoint_name",
        label_name = "Endpoint",
        multiple = FALSE
    )

    output$filter_help_text_Dup <- renderUI({
      req(bmc_r_dup_3only_f3())
      h4("Filter the data using Exposure Scenario, Chorion Status, and Endpoint", style="text-align: center;")
    })


    output$out_dup_box <- renderPlotly({
        dup_dotplot(bmc_r_dup_3only_f3(), "Benchmark concentration (BMC) μM per Endpoint", sourceId = "dup_box")

    })


########## duplicate end here ################

    output$out_resptbl <- renderReactable({

        reactable(
            adjust_incidence_tbl_cols(dmso_incidence_r_3only_f1()),
            defaultColDef = colDef(
                align = "center",
                headerStyle = list(background = "#dfe3ee")
            ),
            columns = list(
                `Percent Resp` = colDef(
                    format = colFormat(percent = TRUE, digits = 1),
                    style = function(value) {
                        if (value > 0.2) {
                            color <- "red"
                        } else {
                            color <- "blue"
                        }
                        list(color = color)
                    }
            )),
            defaultSorted = list(`Percent Resp` = "desc"),
            sortable = TRUE,
            filterable = TRUE,
            searchable = TRUE,
            bordered = TRUE,
            highlight = TRUE,
            showPageSizeOptions = TRUE,
            defaultPageSize = 5
        )


    })


    output$out_pcbmc_tbl <- renderReactable({
        t1 <- adjust_bmc_pctbl_cols(bmc_r_pc_3only_f1())
        reactable(
            t1,
            defaultColDef = colDef(
                align = "center",
                headerStyle = list(background = "#dfe3ee")
            ),
            columns = list(
              BMC = colDef(
                  name = "Benchmark Concentration (BMC)",
                  format = colFormat(digits = 2),
                  header = function(value) {
                    units <- div(style = "color: #999", "µM")
                    div(title = value, value, units)
                  },
                  cell = function(value, index) {
                    hit_conf <- t1[index, "Activity Confidence"]
                    if (hit_conf < 0.5) {
                      str_c("\u274c", round(value, 2))
                    } else {
                      round(value, 2)
                    }
                  }
              ),
              `Activity Confidence` = colDef(
                header = with_tooltip("Activity Confidence", "1=highest confidence, 0=inactive")
              )
            ),
            sortable = TRUE,
            filterable = TRUE,
            searchable = TRUE,
            bordered = TRUE,
            highlight = TRUE,
            showPageSizeOptions = TRUE,
            defaultPageSize = 5
        )
    })


    output$out_dupbmc_tbl <- renderReactable({
        t1 <- adjust_bmc_duptbl_cols(bmc_r_dup_3only_f3())
        reactable(
            t1,
            defaultColDef = colDef(
                align = "center",
                headerStyle = list(background = "#dfe3ee")
            ),
            columns = list(
                BMC = colDef(
                    name = "Benchmark Concentration (BMC)",
                    header = function(value) {
                        units <- div(style = "color: #999", "µM")
                        div(title = value, value, units)
                    },
                    cell = function(value, index) {
                        hit_conf <- t1[index, "Activity Confidence"]
                        if (hit_conf < 0.5) {
                            str_c("\u274c", round(value, 2))
                        } else {
                            round(value, 2)
                        }
                    }
                ),
                `Activity Confidence` = colDef(
                  header = with_tooltip("Activity Confidence", "1=highest confidence, 0=inactive")
                )
            ),
            sortable = TRUE,
            filterable = TRUE,
            searchable = TRUE,
            bordered = TRUE,
            highlight = TRUE,
            showPageSizeOptions = TRUE,
            defaultPageSize = 5
        )
    })

    # seems not working well
    #shared_dmso_in <- highlight_key(dmso_incidence_r_3only, ~Exposure_Scenario)

    ## download handler

    output$vc_resp_dl <- downloadHandler(
      filename = function() {
        paste0(input$vc_subtabs, ".csv")
      },
      content = function(file) {
        write_excel_csv(adjust_incidence_tbl_cols(dmso_incidence_r_3only_f1()), file)
      }
    )

    output$pc_bmc_dl <- downloadHandler(
      filename = function() {
        paste0(input$pc_subtabs, ".csv")
      },
      content = function(file) {
        write_excel_csv(adjust_bmc_pctbl_cols(bmc_r_pc_3only_f1()), file)
      }
    )

    output$dup_bmc_dl <- downloadHandler(
      filename = function() {
        paste0(input$dup_subtabs, ".csv")
      },
      content = function(file) {
        write_excel_csv(adjust_bmc_duptbl_cols(bmc_r_dup_3only_f3()), file)
      }
    )


}

# Run the application
shinyApp(ui = ui, server = server)
