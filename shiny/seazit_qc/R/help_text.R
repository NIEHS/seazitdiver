selection_help_text <- function() {
  div(
    p("Fields will populate in sequential order.", br(),
      "First,", strong("Study Phase"), "will need to be selected followed by", strong("Laboratory"), "and", strong("Test Condition", .noWS = "after"), ".", br(),
      "Selections can be edited by clicking each label.","Results will appear after", strong("Get Data"), "is clicked.", br(),
      em("Note that this will need to be clicked every time the selection pane is edited."),
      "More information can be found on the ", a("Data page", href="https://ods.ntp.niehs.nih.gov/seazit/dataset/", target="_blank"),
      style="display:inline"
      )
  )
  # if using in the sidebar panel
  # div(
  #   p("Fields will populate in sequential order.",
  #     "First, Study Phase will need to be selected followed by Laboratory and Test Condition.",
  #     "Selections can be edited by clicking each label.",
  #     "Results will appear after", strong("Get Data"), "is clicked.",
  #     em("Note that this will need to be clicked every time the selection pane is edited."),
  #     "More information can be found on the ", a("Data page", href="https://ods.ntp.niehs.nih.gov/seazit/dataset/", target="_blank"),
  #     style="display:inline"
  #   )
  # )
}

vc_help_text <- function() {

  div(
    p(
      "Vehicle control (DMSO) endpoints to view can be filtered using", strong("Exposure Scenario"), "and",
      strong("Chorion Status", .noWS = "after"), ".", br(),
      "Each data point represents one 96-well plate.", br(),
      span("Magenta", style = "color:magenta"), "line indicates the response threshold we set for acceptable performance: a plate should have vehicle control response < 20% for mortality only endpoints.", br(),
      "Those that exceed this value are", span("red", style = "color:red"), "text in", em("response table", .noWS = "after"), ".", br(),
      "Hover over each data point for more information.", br(),
      "Double clicking a data point will show response over time underneath Precent Responses of Endpoints figure:", em("response by time/dataset"), ".",
      style="display:inline"
    )
  )
}

pc_help_text <- function() {
  div(
    p("Positive control (PC) benchmark concentration (BMC)  endpoints to view can be filtered using the", strong("Exposure Scenario"), "and", strong("Chorion Status", .noWS = "after"), ".", br(),
      "A boxplot is constructed using the distribution of BMC of PC tested on plates within a week.", br(),
      "Hover over each data point for more information.", br(),
      "The background data of the boxplot are presented as the table below (", strong("activity table", .noWS = c("before", "after")), ")", "and can be downloaded.",
      style="display:inline"
      )
  )
}

dup_help_text <- function() {
  div(
    p("Test substance duplicates to view can be filtered using the", strong("Exposure Scenario"), "and", strong("Chorion Status", .noWS = "after"), ".", br(),
      "Benchmark concentration (BMC) endpoints can be selected using the drop-down pane,", strong("Endpoint", .noWS = "after"), ".", br(),
      "Top concentration with a", "☓", "is shown if test substance is inactive.", br(),
      "Only one endpoint can be viewed at a time.", "Each data point represents one 96-well plate (three points per laboratory but could be overlayed).", br(),
      "Hover over each data point for more information.", br(),
      "The background data of the plot are presented as the table below (", strong("activity table", .noWS = c("before", "after")), ")", "and can be downloaded.",
      style="display:inline"
      )
  )
}
