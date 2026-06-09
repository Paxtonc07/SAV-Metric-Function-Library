# nolint start

# Helper: checks if any element of a comma-separated string matches selected values
match_array_col <- function(col, selected) {
  vapply(col, function(cell) {
    if (is.na(cell) || !nzchar(cell)) return(FALSE)
    # Split the string back into individual items using the comma-space
    cell_parts <- strsplit(as.character(cell), ", ")[[1]]
    any(cell_parts %in% selected)
  }, logical(1), USE.NAMES = FALSE)
}

# Helper: checks if a comma-separated string matches a search term
search_array_col <- function(col, search_term) {
  # Since col is now a standard character vector, we can just use vectorized grepl!
  grepl(search_term, tolower(as.character(col)), ignore.case = TRUE)
}

filter_data_server <- function(input, data, session) {
  filtered_data <- reactive({
    req(!is.null(data), nrow(data) > 0)
    data_filtered <- data
    
    # --- Array (text[]) columns ---
    if (!is.null(input$sav_species) && length(input$sav_species) > 0)
      data_filtered <- data_filtered[match_array_col(data_filtered$sav_species, input$sav_species), ]
    
    if (!is.null(input$sav_type) && length(input$sav_type) > 0)
      data_filtered <- data_filtered[match_array_col(data_filtered$sav_type, input$sav_type), ]
    
    if (!is.null(input$climate_zone) && length(input$climate_zone) > 0)
      data_filtered <- data_filtered[match_array_col(data_filtered$climate_zone, input$climate_zone), ]
    
    if (!is.null(input$sav_metric_category) && length(input$sav_metric_category) > 0)
      data_filtered <- data_filtered[match_array_col(data_filtered$sav_metric_category, input$sav_metric_category), ]
    
    if (!is.null(input$sav_function_category) && length(input$sav_function_category) > 0)
      data_filtered <- data_filtered[match_array_col(data_filtered$sav_function_category, input$sav_function_category), ]
    
    if (!is.null(input$specific_sav_function) && length(input$specific_sav_function) > 0)
      data_filtered <- data_filtered[match_array_col(data_filtered$specific_sav_function, input$specific_sav_function), ]
    
    if (!is.null(input$methods) && length(input$methods) > 0)
      data_filtered <- data_filtered[match_array_col(data_filtered$methods, input$methods), ]
    
    if (!is.null(input$location_country) && length(input$location_country) > 0)
      data_filtered <- data_filtered[match_array_col(data_filtered$location_country, input$location_country), ]
    
    if (!is.null(input$location_state_province) && length(input$location_state_province) > 0)
      data_filtered <- data_filtered[match_array_col(data_filtered$location_state_province, input$location_state_province), ]
    
    if (!is.null(input$location_waterbody) && length(input$location_waterbody) > 0)
      data_filtered <- data_filtered[match_array_col(data_filtered$location_waterbody, input$location_waterbody), ]
    
    # --- Plain text columns ---
    if (!is.null(input$article_type) && length(input$article_type) > 0)
      data_filtered <- data_filtered[data_filtered$article_type %in% input$article_type, ]
    
    if (!is.null(input$specific_sav_metric) && length(input$specific_sav_metric) > 0)
      data_filtered <- data_filtered[data_filtered$specific_sav_metric %in% input$specific_sav_metric, ]
    
    if (!is.null(input$direction_of_relationship) && length(input$direction_of_relationship) > 0)
      data_filtered <- data_filtered[data_filtered$direction_of_relationship %in% input$direction_of_relationship, ]
    
    # --- Search Bar Logic ---
    if (!is.null(input$search) && input$search != "") {
      search_term <- tolower(input$search)
      
      plain_cols <- c(
        "article_id", "article_type", "title", "authors", "specific_sav_metric",
        "direction_of_relationship", "main_finding", "quotes_and_notes"
      )
      
      array_cols <- c(
        "location_country", "location_state_province", "location_waterbody",
        "climate_zone", "sav_species", "sav_type", "sav_metric_category",
        "sav_function_category", "specific_sav_function", "methods"
      )
      
      if (nrow(data_filtered) > 0) {
        plain_matches <- Reduce(`|`, lapply(plain_cols, function(col) {
          grepl(search_term, tolower(as.character(data_filtered[[col]])), ignore.case = TRUE)
        }))
        array_matches <- Reduce(`|`, lapply(array_cols, function(col) {
          search_array_col(data_filtered[[col]], search_term)
        }))
        data_filtered <- data_filtered[plain_matches | array_matches, ]
      }
    }
    
    data_filtered
  })
  
  return(filtered_data)
}
# nolint end