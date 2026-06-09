# nolint start
update_filters_server <- function(input, output, session, data, db) {
  
  # Columns that can contain multiple comma-separated items
  array_cols <- c(
    "location_country", "location_state_province", "location_waterbody",
    "climate_zone", "sav_species", "sav_type", "sav_metric_category",
    "sav_function_category", "specific_sav_function", "methods"
  )
  
  # Map the UI input IDs to the exact database column names
  filter_specs <- list(
    sav_species = list(input_id = "sav_species", column = "sav_species"),
    sav_type = list(input_id = "sav_type", column = "sav_type"),
    climate_zone = list(input_id = "climate_zone", column = "climate_zone"),
    article_type = list(input_id = "article_type", column = "article_type"),
    sav_metric_category = list(input_id = "sav_metric_category", column = "sav_metric_category"),
    specific_sav_metric = list(input_id = "specific_sav_metric", column = "specific_sav_metric"),
    sav_function_category = list(input_id = "sav_function_category", column = "sav_function_category"),
    specific_sav_function = list(input_id = "specific_sav_function", column = "specific_sav_function"),
    direction_of_relationship = list(input_id = "direction_of_relationship", column = "direction_of_relationship"),
    methods = list(input_id = "methods", column = "methods"),
    location_country = list(input_id = "location_country", column = "location_country"),
    location_state_province = list(input_id = "location_state_province", column = "location_state_province"),
    location_waterbody = list(input_id = "location_waterbody", column = "location_waterbody")
  )
  
  # Apply one filter to a dataframe, safely handling list vs plain character formats
  apply_filter <- function(df, vals, col) {
    if (is.null(vals) || length(vals) == 0 || nrow(df) == 0) return(df)
    
    raw_col <- df[[col]]
    
    if (col %in% array_cols) {
      if (is.list(raw_col)) {
        # Defensive fallback: If Postgres returned a list/array object
        keep <- vapply(raw_col, function(cell) {
          if (is.null(cell) || all(is.na(cell))) return(FALSE)
          any(as.character(cell) %in% vals)
        }, logical(1))
      } else {
        # Standard text string with comma separation (Old Salmon Database Style)
        keep <- vapply(as.character(raw_col), function(cell) {
          if (is.na(cell) || !nzchar(cell) || cell == "NA") return(FALSE)
          cell_parts <- strsplit(cell, split = "\\s*,\\s*")[[1]]
          any(cell_parts %in% vals)
        }, logical(1))
      }
    } else {
      keep <- as.character(raw_col) %in% vals
    }
    
    df[keep, , drop = FALSE]
  }
  
  # Get distinct values from a column for dropdown choices safely
  get_dynamic_vals <- function(df, col) {
    if (nrow(df) == 0) return(character(0))
    
    raw_col <- df[[col]]
    
    if (col %in% array_cols) {
      if (is.list(raw_col)) {
        # If it arrives as a list array object, flatten it directly
        vals <- unique(unlist(raw_col))
      } else {
        # Standard character vector of comma-separated strings
        clean_cells <- as.character(raw_col[!is.na(raw_col) & raw_col != "NA" & raw_col != ""])
        if (length(clean_cells) == 0) {
          vals <- character(0)
        } else {
          vals <- unique(unlist(strsplit(clean_cells, split = "\\s*,\\s*")))
        }
      }
    } else {
      vals <- unique(raw_col)
    }
    
    # Filter out NAs and blank characters, convert to character vector, and sort
    clean_vals <- as.character(vals[!is.na(vals) & vals != "NA" & nzchar(trimws(vals))])
    return(sort(unique(trimws(clean_vals))))
  }
  
  observe({
    for (name in names(filter_specs)) {
      spec <- filter_specs[[name]]
      
      # Filter data using all OTHER active filters
      df_sub <- data
      for (other in filter_specs[names(filter_specs) != name]) {
        df_sub <- apply_filter(df_sub, input[[other$input_id]], other$column)
      }
      
      # Full universe of choices from the pre-loaded dataframe
      lookup_vals <- get_dynamic_vals(data, spec$column)
      
      # Dynamic subset from currently filtered data
      dynamic_vals <- get_dynamic_vals(df_sub, spec$column)
      
      # Only show choices that exist in both the DB universe and the filtered subset
      valid_choices <- lookup_vals[lookup_vals %in% dynamic_vals]
      
      updatePickerInput(session, spec$input_id,
                        choices  = valid_choices,
                        selected = intersect(input[[spec$input_id]], valid_choices)
      )
    }
  })
}
# nolint end