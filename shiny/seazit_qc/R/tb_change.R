add_protocol_filters <- function(d) {
  d %>%
    mutate(
      Study_Phase = case_when(
        protocol_type == "DRF" ~ "dose ranging finding",
        TRUE ~ "definitive"
      ),
      Lab = case_when(
        protocol_source == "biobide" ~ "lab-A",
        protocol_source == "osu" ~ "lab-B",
        protocol_source == "zeclinics" ~ "lab-C",
        TRUE ~ protocol_source
      ),
      Test_Condition = case_when(
        str_detect(protocol_name, "R-C") ~ "repeated exposure, chorion-on (R-C)",
        str_detect(protocol_name, "S-C") ~ "single exposure, chorion-on (S-C)",
        str_detect(protocol_name, "R-DC") ~ "repeated exposure, chorion-off (R-DC)",
        str_detect(protocol_name, "S-DC") ~ "single exposure, chorion-off (S-DC)"

      ),
      Embryo_Type = str_extract(Test_Condition, "(R-C|S-C|R-DC|S-DC)"),
      Display_Protocol = str_glue("{Lab}|{Study_Phase}|{Embryo_Type}")
    )
}

add_dmso_boxplot_filters <- function(d) {
  d %>%
    mutate(percent = n_in/n*100) %>%
    mutate(
      protocol_id = as.character(protocol_id)
    ) %>%
    mutate(
      text = str_glue("plate name:{plate_name}"),
      Exposure_Scenario = ifelse(str_detect(embryo_type, "R"), "Static Renewal", "Static"),
      Chorion_Status = ifelse(str_detect(embryo_type, "DC"), "Dechorion", "Chorion")
    )
}


add_dmso_click_dotplot_filters <- function(d, clicked_plate) {
  d %>%
    mutate(
      new_color = case_when(
        plate_name == clicked_plate ~ "clicked plate",
        TRUE ~ "others"),
      text = str_glue("plate name:{plate_name}")
    )

}


add_bmc_pc_box_filters <- function(d) {
  d %>%
    select(endpoint_name, substance_code, embryo_type, pod_med, hit_confidence, protocol_id, input_chembase, protocol_name_plot,
           study_phase, test_condition
           ) %>%
    mutate(plates_time = str_replace(input_chembase, ".*@(.*$)", "\\1")) %>%
    mutate(POD = 10^pod_med*1000000) %>%
    mutate(
      protocol_id = as.character(protocol_id),
      text = str_glue("plates date end:{plates_time}"),
      Exposure_Scenario = ifelse(str_detect(embryo_type, "R"), "Static Renewal", "Static"),
      Chorion_Status = ifelse(str_detect(embryo_type, "DC"), "Dechorion", "Chorion")
    )
}


add_bmc_dup_box_filters <- function(d) {
  d %>%
    mutate(
      is_hit = ifelse(hit_confidence > 0.5, "active", "inactive"),
      POD = ifelse(is_hit == "inactive", highest_conc, pod_med),
      POD = 10^POD*1000000
    ) %>%
    select(protocol_name_plot, endpoint_name, substance_code, embryo_type, POD, is_hit, hit_confidence, protocol_id,plate_name, preferred_name,
           study_phase, test_condition
           ) %>%
    nest(d = -c(substance_code, endpoint_name, protocol_id)) %>%
    mutate(max_pod = map_dbl(d, ~ max(.x$POD)), min_pod = map_dbl(d, ~ min(.x$POD))) %>%
    unnest(cols = "d") %>%
    mutate(dup_test = map(substance_code, duplicate_code_2_dup)) %>%
    mutate(name_w_code = str_glue("{preferred_name}|{dup_test}|{substance_code}")) %>% select(-dup_test) %>%
    mutate(
      protocol_id = as.character(protocol_id),
      text = str_glue("plate_name:{plate_name}"),
      Exposure_Scenario = ifelse(str_detect(embryo_type, "R"), "Static Renewal", "Static"),
      Chorion_Status = ifelse(str_detect(embryo_type, "DC"), "Dechorion", "Chorion")
    ) %>%
    arrange(name_w_code)

  #result <- result %>% split(.$endpoint_name)
  #return(result[[1]])

}


adjust_incidence_tbl_cols <- function(d) {

  sel_cols <- c("protocol_name_plot", "test_condition", "study_phase",
                "endpoint_name", "substance_code", "plate_name", "plate_screen_time_end", "n", "n_in")
  new_cols <- c("Dataset", "Test Condition", "Study Phase",
                "Endpoint", "Substance", "Plate", "Experiment Time", "N embryos", "N incidences")
  d %>%
    select(all_of(sel_cols)) %>%
    mutate(percent_resp = n_in/n) %>%
    filter(!is.na(percent_resp)) %>%  # this is for the issue plate https://gitlab.niehs.nih.gov/hsiehj2/seazit/-/issues/30
    rename_with(~ c(new_cols, "Percent Resp"), all_of(c(sel_cols, "percent_resp")))

}

adjust_bmc_pctbl_cols <- function(d) {
  sel_cols <- c("protocol_name_plot", "test_condition", "study_phase",
                "endpoint_name", "substance_code", "text", "POD", "hit_confidence")
  new_cols <- c("Dataset", "Test Condition", "Study Phase",
                "Endpoint", "Substance", "Data Aggregation", "BMC", "Activity Confidence")
  d %>%
    select(all_of(sel_cols)) %>%
    rename_with(~ c(new_cols), all_of(c(sel_cols)))

}




adjust_bmc_duptbl_cols <- function(d) {
  sel_cols <- c("protocol_name_plot", "test_condition", "study_phase",
                "endpoint_name", "substance_code", "preferred_name", "POD", "hit_confidence")
  new_cols <- c("Dataset", "Test Condition", "Study Phase",
                "Endpoint", "Duplicate Name", "Substance", "BMC", "Activity Confidence")
  d %>%
    select(all_of(sel_cols)) %>%
    mutate(dup_test = map(substance_code, duplicate_code_2_dup)) %>%
    mutate(substance_code = str_glue("{substance_code}({dup_test})")) %>% select(-dup_test) %>%
    rename_with(~ c(new_cols), all_of(c(sel_cols)))

}
