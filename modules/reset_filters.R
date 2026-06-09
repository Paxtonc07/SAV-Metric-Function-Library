# nolint start
reset_filters_server <- function(input, session) {
  observeEvent(input$reset_filters, {
    # Reset the text search bar
    updateTextInput(session, "search", value = "")
    
    # Reset all SAV picker inputs
    updatePickerInput(session, "sav_species", selected = character(0))
    updatePickerInput(session, "sav_type", selected = character(0))
    updatePickerInput(session, "climate_zone", selected = character(0))
    updatePickerInput(session, "article_type", selected = character(0))
    
    updatePickerInput(session, "sav_metric_category", selected = character(0))
    updatePickerInput(session, "specific_sav_metric", selected = character(0))
    updatePickerInput(session, "sav_function_category", selected = character(0))
    updatePickerInput(session, "specific_sav_function", selected = character(0))
    
    updatePickerInput(session, "direction_of_relationship", selected = character(0))
    updatePickerInput(session, "methods", selected = character(0))
    
    updatePickerInput(session, "location_country", selected = character(0))
    updatePickerInput(session, "location_state_province", selected = character(0))
    updatePickerInput(session, "location_waterbody", selected = character(0))
  })
}
# nolint end