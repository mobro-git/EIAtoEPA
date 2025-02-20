
if (FALSE) {
  
  map = read_csv("mapping/aeo_mapping_combo_test.csv")
  ids = unique(map$seriesId)
  
  debugonce(eia_data_big)
  data_eia = eia_data_big(
    dir = "aeo/2023",
    data = "value",
    facets = list(
      scenario = c("ref2023","highogs"),
      seriesId = c("trad_imp_ten_NA_cr_NA_usa_qbtu","trad_imp_ten_NA_lfl_NA_usa_qbtu" ))
  )
  
  debugonce(.eia_data_big_the_rest)
  data_big = eia_data_big(
    dir = "aeo/2023",
    data = "value",
    facets = list(
      scenario = c("ref2023","highogs"),
      tableId = 1:8)
  )
  
  data_big2 = eia_data_big(
    dir = "aeo/2023",
    data = "value",
    facets = list(
      scenario = c("ref2023","highogs"),
      seriesId = unique(map$seriesId))
  )
  
  dir = "aeo/2023"
  data = "value"
  facets = list(
    scenario = c("ref2023","highogs","lowogs"),
    seriesId = unique(map$seriesId)
  )
  
}

eia_data_big = function (dir, data = NULL, facets = NULL,
                           freq = NULL, start = NULL, end = NULL,
                           sort = NULL, length = NULL, offset = NULL,
                           tidy = TRUE, check_metadata = FALSE, 
                           key = eia_get_key()){
  eia:::.key_check(key)
  if (check_metadata) {eia:::.eia_metadata_check(dir, data, facets, freq, start, end, key)} # TODO: check why check fails
  else {eia_data_handle_big(dir,data,facets,freq,start,end,sort,length,offset,tidy,key)}
  
}

eia_data_handle_big <- function (dir, data, facets, freq, start, end, sort, length, offset, tidy, key) {
  
  # build and perform API call
  r <- eia:::.eia_get(eia:::.eia_data_url(dir, data, facets, freq, start, end, sort, length, offset, key))
  
  # return raw API character string
  if (is.na(tidy)) {return(r)}
  
  # response processing
  r <- jsonlite::fromJSON(r)
  
  # return raw API response
  if (!tidy) {return(r)}
  
  # returning data
  response_total = as.numeric(r$response$total)
  
  # TODO: need to handle if there are no warnings, "Error in if (!is.null(r$response$warnings) & r$response$warnings[[1]] !=  : argument is of length zero
  if (!is.null(r$response$warnings) && r$response$warnings[[1]] != "incomplete return" && is.null(length)) {
    wrngs <- paste0(r$response$warnings[[1]], "\n", r$response$warnings[[2]])
    warning(wrngs, "\nTotal available rows: ", response_total, 
            call. = FALSE)
  } else {
    # no data available handling
    if (response_total == 0) 
      stop("No data available - check temporal inputs.", 
           call. = FALSE)
    # handling for 5000 or fewer responses (API return limit)
    if(response_total <= 5000) {
      response_data = tibble::as_tibble(r$response$data)}
    # handling for over 5000 responses
    if (nrow(r$response$data) != response_total) 
      message("Rows returned: ", nrow(r$response$data), 
              "\nRows available: ", response_total)
    response_data = eia_data_multiple_calls(dir, data, facets, freq, start, end, sort, length, tidy, key, total = response_total)
  }
  
  return(response_data)
  
}

eia_data_multiple_calls <- function(dir, data, facets, freq, start, end, sort, length, tidy, key, total) {
  
  total_length <- min(total, length)
  num_requests <- ceiling(total_length / 5000)
  
  stopifnot(num_requests > 0)
  if(num_requests > 10) {} # TODO: do the thing where we ask the user
  message("Proceeding to request all available data", "\nRequests Needed: ", num_requests)
  
  list_data <- list()
  
  for (i in 1:num_requests) {
    
    # build and do api call
    offset_i <- (i-1) * 5000
    length_i <- min(total_length - offset_i, 5000)
    r <- eia:::.eia_get(eia:::.eia_data_url(dir, data, facets, freq, start, end, sort, length = length_i, offset = offset_i, key))
    Sys.sleep(.3) # so max 4 / second
    
    # response processing
    if(is.na(tidy)) return(r)
    r <- jsonlite::fromJSON(r)
    list_data[[i]] <- tibble::as_tibble(r$response$data)
  }
  
  # TODO: seems like wrap-up isn't working
  
  # put them all together
  all_data <- data.table::rbindlist(list_data)
  return(all_data)
  
}


