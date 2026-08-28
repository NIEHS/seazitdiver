adjust_chemical_tbl_cols <- function(d) {
  d %>%
    select(substance_type, substance_code, casrn:use_category2) %>%
    distinct() %>%
    mutate(
      substance_type = case_when(
        dtxsid %in% names(duplicate_codes()) ~ "Blinded Duplicate",
        substance_type == "PC" ~ "Positive Control",
        substance_type == "VC" ~ "Vehicle Control",
        TRUE ~ "Blinded Substance"
      )
    ) %>%
    select(use_category2,  use_category1, preferred_name, dtxsid, casrn, substance_type, substance_code ) %>%
    arrange(dtxsid)
}


add_protocol_cols <- function(d1, d2) {

  db_cols <- c("protocol_id", "protocol_name_long", "protocol_name_plot", "test_condition",
               "lab_anonymous_code", "study_phase" )
  d1 %>%
    select(all_of(db_cols)) %>%
    left_join(d2 %>% mutate(protocol_id  = as.integer(protocol_id)), by = "protocol_id") %>%
    select(-protocol_id)
}

pivot_assay_tbl <- function(d) {
  d %>%
    select(Display_Protocol, `Zebrafish Strain`:`Screening Compounds`) %>%
    pivot_longer(cols = -Display_Protocol) %>%
    pivot_wider(names_from = "Display_Protocol") %>%
    column_to_rownames("name")
}



filter_sankey_nodes <- function(nodetb, lab_name, filtered_onto) {

  # Mortality needs to be treated special
  sel_quo <- switch(
    lab_name,
    "biobide" = quo((node_name == "Mortality" & node_color == "#1b9e77") | (node_name != "Mortality")),
    "osu" =  quo((node_name == "Mortality" & node_color == "#d95f02") | (node_name != "Mortality")),
    "zeclinics" = quo((node_name == "Mortality" & node_color == "#7570b3") | (node_name != "Mortality"))
  )

  # filter the nodes and create new_node_id
  nodetb %>%
    filter(
      node_name %in% c(filtered_onto$proposed_ontology_label, filtered_onto$developmental_defect_grouping_granular,
                       filtered_onto$developmental_defect_grouping_general, filtered_onto$recording_name)) %>%
    filter(
      !!sel_quo
    ) %>%
    mutate(
      new_node_id = seq(0, nrow(.)-1)
    )
}

filter_sankey_flows <- function(flowtb,  filtered_onto) {

  # collect flows
  flows3 <- bind_rows(
    flowtb %>%
      filter(target_name %in% filtered_onto$proposed_ontology_label, source_name %in% filtered_onto$recording_name),
    flowtb %>%
      filter(target_name %in% filtered_onto$developmental_defect_grouping_granular, source_name %in% filtered_onto$proposed_ontology_label),
    flowtb %>%
      filter(target_name %in% filtered_onto$developmental_defect_grouping_general, source_name %in% filtered_onto$developmental_defect_grouping_granular)
  )
}

change_sankey_flows <- function(new_flowtb, new_nodetb) {

  # need to create new ids and flow size
  result <- new_flowtb %>%
    left_join(
      new_nodetb %>% rename(new_source_id = new_node_id) %>% select(node_id, new_source_id), by = c("source_id" = "node_id")
    ) %>%
    left_join(
      new_nodetb %>% rename(new_target_id = new_node_id) %>% select(node_id, new_target_id), by = c("target_id" = "node_id")
    ) %>%
    filter(
      !is.na(new_source_id)
    ) %>%
    left_join(
      new_flowtb %>% count(target_id, name = "flow_size"), by = c("source_id" = "target_id")
    ) %>%
    mutate(
      flow_size = ifelse(is.na(flow_size), 1, flow_size),
      flow_size = case_when(
        source_name == "whole organism dead, abnormal" ~ 1,
        target_name == "scoliosis" ~ 1, # still not right , needs to be fixed
        TRUE ~ flow_size
      )
    )

  return(result)
}


