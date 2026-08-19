get_protocols <- function(pool_obj) {
  result <- dplyr::tbl(pool_obj, dbplyr::in_schema("schema_seazit", "seazit_protocol")) %>% dplyr::collect()
  result <- result %>% dplyr::rename(protocol_id = seazit_protocol_id)
  return(result)
}


get_substances <- function(pool_obj) {

  sub <- dplyr::tbl(pool_obj, dbplyr::in_schema("schema_seazit", "seazit_substance"))
  sub_map <- dplyr::tbl(pool_obj, dbplyr::in_schema("schema_seazit", "seazit_substance_mapping"))
  result <- sub %>% dplyr::left_join(sub_map, by = "substance_code") %>% dplyr::collect()
  result <- result %>% dplyr::rename(substance_id = seazit_substance_id)

  return(result)
}


get_incidence_by_protocol <- function(pool_obj, id) {

  deselect_cols <- c("dose_id", "plate_map_name")

  dosed <- dplyr::tbl(pool_obj, dbplyr::in_schema("schema_seazit", "seazit_dose")) %>% dplyr::select(-tidyselect::any_of(c("protocol_source")))
  inputd <- dplyr::tbl(pool_obj, dbplyr::in_schema("schema_seazit", "analysis_bmc_input")) %>% dplyr::rename(hour_post_fertilization = screen_hours)
  plated <- dplyr::tbl(pool_obj, dbplyr::in_schema("schema_seazit", "seazit_plate_screen"))

  result <- inputd %>%
    dplyr::filter(protocol_id == id) %>%
    dplyr::left_join(dosed, by = "dose_id") %>%
    dplyr::left_join(plated, by = c("plate_name", "hour_post_fertilization")) %>%
    dplyr::collect()

  result <- result %>%
    dplyr::left_join(
      get_substances(pool_obj) %>% dplyr::select(c("substance_id", "substance_code")),
      by = "substance_id") %>%
    #dplyr::filter(substance_code == code) %>%
    dplyr::select(-tidyselect::any_of(deselect_cols))

  return(result)

}


get_bmc_by_protocol <- function(pool_obj, id) {
  outputd <- dplyr::tbl(pool_obj, dbplyr::in_schema("schema_seazit", "analysis_bmc_output")) %>%
    dplyr::rename(hour_post_fertilization = screen_hours) %>%
    dplyr::select(-tidyselect::any_of(c("endpoint_name_only")))

  result <- outputd %>%
    dplyr::filter(protocol_id == id) %>%
    dplyr::collect()

  result <- result %>%
    dplyr::left_join(
      get_substances(pool_obj) %>% dplyr::select(c("substance_id", "substance_code")),
      by = "substance_id")

  return(result)
}



duplicate_codes <- function() {
  list(
    DTXSID0039223 = c(1200, 1794),
    DTXSID6023733 = c(1728, 1989),
    DTXSID7020182 = c(1323, 1956)
  )
}



duplicate_code_2_dup <- function(code) {
  s <- switch(
    code,
    "1200" = "Duplicate#1",
    "1794" = "Duplicate#2",
    "1728" = "Duplicate#1",
    "1989" = "Duplicate#2",
    "1323" = "Duplicate#1",
    "1956" = "Duplicate#2",
    NA_character_
  )
  return(s)
}
