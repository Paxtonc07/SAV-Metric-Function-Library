# nolint start

# Load required modules
source("modules/csv_validation.R")
source("modules/error_handling.R")

# Compact Upload UI matched to the new SAV Database Schema
upload_ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    shinyjs::useShinyjs(),
    tags$head(
      includeCSS("www/custom.css")
    ),
    div(
      id = ns("upload_form"),
      fluidRow(
        column(12, 
               h3("Submit New SAV Relationship", style = "text-align: center; color: #6082B6; margin-bottom: 10px;"),
               p(
                 style = "text-align: center; font-size: 1.05em; color: #555; margin-bottom: 30px; padding-left: 15px; padding-right: 15px;",
                 "Fields marked with an asterisk (", strong("*"), ") are required.", br(),
                 em("Note: For dropdown menus, you may select an existing option or type your own text to add a new entry to the database.")
               )
        )
      ),
      
      # Core Metadata
      fluidRow(
        column(8, offset = 2, textInput(ns("title"), "Article Title *", placeholder = "Add a short descriptive title", width = "100%"))
      ),
      fluidRow(
        column(4, offset = 2, selectizeInput(ns("article_type"), "Article Type *", choices = NULL, options = list(create = TRUE, placeholder = "e.g., Peer-reviewed, Report"), width = "100%")),
        column(4, selectizeInput(ns("direction_of_relationship"), "Direction of Relationship", choices = NULL, options = list(create = TRUE, placeholder = "e.g., Positive, Negative, Context-Dependent"), width = "100%"))
      ),
      
      # Optional CSV Upload
      fluidRow(
        column(8, offset = 2, wellPanel(
          style = "background-color: #f9f9f9; border-color: #ccc; margin-top: 15px; margin-bottom: 25px;",
          strong("Optional: Quantitative Data CSV"),
          uiOutput(ns("sr_csv_file_ui")),
          helpText(
            "Upload a CSV data file if there is quantitative data for this relationship. This is entirely optional.",
            br(),
            tags$em("Note: Map your SAV Metric to the 'stressor' columns and Ecological Function to the 'response' columns."),
            br(), br(),
            "Required columns: curve.id, stressor.label, stressor.x, units.x, response.label, response.y, units.y.",
            br(),
            "Optional columns: plot.type (use 'scatter' or 'curve' or 'bar'), stressor.value, lower.limit, upper.limit, sd."
          ),
          downloadButton(ns("download_csv_template"), "Download CSV Template", class = "btn btn-info mb-2"),
          uiOutput(ns("csv_validation_status"))
        ))
      ),
      
      # SAV Profile Info
      fluidRow(
        column(4, offset = 2, selectizeInput(ns("sav_species"), "SAV Species", choices = NULL, multiple = TRUE, options = list(create = TRUE, placeholder = "Type to search or add..."), width = "100%")),
        column(4, selectizeInput(ns("sav_type"), "SAV Type", choices = NULL, multiple = TRUE, options = list(create = TRUE, placeholder = "Type to search or add..."), width = "100%"))
      ),
      fluidRow(
        column(8, offset = 2, selectizeInput(ns("climate_zone"), "Climate Zone", choices = NULL, multiple = TRUE, options = list(create = TRUE, placeholder = "Type to search or add..."), width = "100%"))
      ),
      
      # Metrics and Functions
      fluidRow(
        column(4, offset = 2, selectizeInput(ns("sav_metric_category"), "Metric Category", choices = NULL, multiple = TRUE, options = list(create = TRUE, placeholder = "e.g., Density, Area"), width = "100%")),
        column(4, selectizeInput(ns("specific_sav_metric"), "Specific SAV Metric", choices = NULL, options = list(create = TRUE, placeholder = "e.g., Shoot density per m2"), width = "100%"))
      ),
      fluidRow(
        column(4, offset = 2, selectizeInput(ns("sav_function_category"), "Function Category", choices = NULL, multiple = TRUE, options = list(create = TRUE, placeholder = "e.g., Physical, Biotic"), width = "100%")),
        column(4, selectizeInput(ns("specific_sav_function"), "Specific SAV Function", choices = NULL, multiple = TRUE, options = list(create = TRUE, placeholder = "e.g., Wave attenuation"), width = "100%"))
      ),
      
      # Location & Methods Info
      fluidRow(
        column(4, offset = 2, selectizeInput(ns("location_country"), "Country", choices = NULL, multiple = TRUE, options = list(create = TRUE, placeholder = "Type to search or add..."), width = "100%")),
        column(4, selectizeInput(ns("location_state_province"), "State / Province", choices = NULL, multiple = TRUE, options = list(create = TRUE, placeholder = "Type to search or add..."), width = "100%"))
      ),
      fluidRow(
        column(4, offset = 2, selectizeInput(ns("location_waterbody"), "Waterbody", choices = NULL, multiple = TRUE, options = list(create = TRUE, placeholder = "Type to search or add..."), width = "100%")),
        column(4, selectizeInput(ns("methods"), "Methods", choices = NULL, multiple = TRUE, options = list(create = TRUE, placeholder = "e.g., Experimental, Observational"), width = "100%"))
      ),
      
      # Coordinates Row
      fluidRow(
        column(8, offset = 2, textInput(ns("lat_long"), "Latitude / Longitude (Optional)", placeholder = "e.g., 34.0522, -118.2437", width = "100%"))
      ),
      
      # Findings & Notes
      fluidRow(
        column(8, offset = 2, textAreaInput(ns("main_finding"), "Main Finding *", placeholder = "Describe the core qualitative relationship discovered between the metric and function.", height = "100px", width = "100%"))
      ),
      fluidRow(
        column(8, offset = 2, textAreaInput(ns("quotes_and_notes"), "Quotes & Notes", placeholder = "Add any direct quotes or additional context here.", height = "100px", width = "100%"))
      ),
      
      # Citations (Dynamic)
      fluidRow(
        column(8, offset = 2, h4("Citations *", style = "margin-top: 20px; border-bottom: 1px solid #ddd; padding-bottom: 5px;"))
      ),
      fluidRow(
        column(8, offset = 2,
               div(
                 id = ns("citation_block_1"),
                 style = "border: 1px solid #e3e3e3; padding: 15px; margin-bottom: 10px; border-radius: 5px; background-color: #fafafa;",
                 textAreaInput(ns("citation_text_1"), "Citation 1 (Text)", placeholder = "e.g., Smith et al. (2020)...", height = "70px", width = "100%"),
                 fluidRow(
                   column(6, textInput(ns("citation_title_1"), "Link Title", placeholder = "e.g., Smith et al. 2020", width = "100%")),
                   column(6, textInput(ns("citation_url_1"), "URL", placeholder = "e.g., https://doi.org/...", width = "100%"))
                 )
               ),
               tags$div(id = ns("extra_citations_container")) 
        )
      ),
      fluidRow(
        column(8, offset = 2, actionButton(ns("add_citation"), "Add Another Citation", icon = icon("plus"), class = "btn-sm", style = "margin-bottom: 30px;"))
      ),
      
      # Revision Log and Submit
      fluidRow(
        column(8, offset = 2, textAreaInput(ns("revision_log"), "Revision Log Message", placeholder = "Briefly describe the reason for this upload/change", height = "60px", width = "100%"))
      ),
      
      # Buttons
      fluidRow(
        column(8, offset = 2, 
               div(style = "margin-top: 20px; margin-bottom: 50px;",
                   actionButton(ns("save"), "Submit SAV Profile", class = "btn-primary", style = "margin-right: 15px; width: 180px;"),
                   actionButton(ns("preview"), "Preview", class = "btn-secondary", style = "width: 120px;")
               )
        )
      )
    )
  )
}

upload_server <- function(id, db_conn = pool, current_user = NULL) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    # ── Populate Dropdowns natively via Postgres Array Unnesting ──
    observe({
      get_distinct <- function(col) {
        tryCatch({
          res <- dbGetQuery(db_conn, sprintf("SELECT DISTINCT %s AS val FROM sav_records WHERE %s IS NOT NULL", col, col))
          c("", sort(res$val[res$val != ""]))
        }, error = function(e) "")
      }
      
      get_distinct_array <- function(col) {
        tryCatch({
          res <- dbGetQuery(db_conn, sprintf("SELECT DISTINCT unnest(%s) AS val FROM sav_records WHERE %s IS NOT NULL", col, col))
          sort(res$val[res$val != ""])
        }, error = function(e) character(0))
      }
      
      updateSelectizeInput(session, "article_type", choices = get_distinct("article_type"), server = FALSE, options = list(create = TRUE))
      updateSelectizeInput(session, "direction_of_relationship", choices = get_distinct("direction_of_relationship"), server = FALSE, options = list(create = TRUE))
      
      # FIXED: Updated specific_sav_metric to populate cleanly from array layouts
      updateSelectizeInput(session, "specific_sav_metric", choices = get_distinct_array("specific_sav_metric"), server = FALSE, options = list(create = TRUE))
      
      updateSelectizeInput(session, "sav_species", choices = get_distinct_array("sav_species"), server = FALSE, options = list(create = TRUE))
      updateSelectizeInput(session, "sav_type", choices = get_distinct_array("sav_type"), server = FALSE, options = list(create = TRUE))
      updateSelectizeInput(session, "climate_zone", choices = get_distinct_array("climate_zone"), server = FALSE, options = list(create = TRUE))
      updateSelectizeInput(session, "sav_metric_category", choices = get_distinct_array("sav_metric_category"), server = FALSE, options = list(create = TRUE))
      updateSelectizeInput(session, "sav_function_category", choices = get_distinct_array("sav_function_category"), server = FALSE, options = list(create = TRUE))
      updateSelectizeInput(session, "specific_sav_function", choices = get_distinct_array("specific_sav_function"), server = FALSE, options = list(create = TRUE))
      updateSelectizeInput(session, "methods", choices = get_distinct_array("methods"), server = FALSE, options = list(create = TRUE))
      updateSelectizeInput(session, "location_country", choices = get_distinct_array("location_country"), server = FALSE, options = list(create = TRUE))
      updateSelectizeInput(session, "location_state_province", choices = get_distinct_array("location_state_province"), server = FALSE, options = list(create = TRUE))
      updateSelectizeInput(session, "location_waterbody", choices = get_distinct_array("location_waterbody"), server = FALSE, options = list(create = TRUE))
    })
    
    output$sr_csv_file_ui <- renderUI({
      fileInput(ns("sr_csv_file"), NULL, accept = ".csv", buttonLabel = "Choose File", placeholder = "No file chosen", width = "100%")
    })
    
    citation_count <- reactiveVal(1)
    
    observeEvent(input$add_citation, {
      new_count <- citation_count() + 1
      citation_count(new_count)
      
      insertUI(
        selector = paste0("#", ns("extra_citations_container")),
        where = "beforeEnd",
        ui = div(
          id = ns(paste0("citation_block_", new_count)),
          style = "border: 1px solid #e3e3e3; padding: 15px; margin-bottom: 10px; border-radius: 5px; background-color: #fafafa;",
          textAreaInput(ns(paste0("citation_text_", new_count)), paste("Citation", new_count, "(Text)"), placeholder = "Citation format without link...", height = "70px", width = "100%"),
          fluidRow(
            column(6, textInput(ns(paste0("citation_title_", new_count)), "Link Title", placeholder = "e.g., Smith et al. 2020", width = "100%")),
            column(6, textInput(ns(paste0("citation_url_", new_count)), "URL", placeholder = "e.g., https://doi.org/...", width = "100%"))
          )
        )
      )
    })
    
    observeEvent(input$sr_csv_file, {
      req(input$sr_csv_file)
      csv_validation_result <- validate_csv_upload(input$sr_csv_file)
      
      output$csv_validation_status <- renderUI({
        if (csv_validation_result$valid) {
          df <- csv_validation_result$data
          HTML(create_alert_html(
            type = "success",
            message = "CSV is valid and ready to submit",
            details = list(sprintf("Total rows: %d", nrow(df)))
          ))
        } else {
          error_msg <- get_csv_error_message(csv_validation_result)
          HTML(create_alert_html(type = "error", message = error_msg$message, details = error_msg$issues))
        }
      })
    })
    
    observeEvent(input$save, {
      req(input$title)
      
      df_csv <- data.frame()
      if (!is.null(input$sr_csv_file)) {
        csv_validation_result <- validate_csv_upload(input$sr_csv_file)
        if (!csv_validation_result$valid) {
          show_error_modal(session, "❌ CSV Validation Failed", "Please fix the CSV file before submitting.")
          return()
        }
        df_csv <- csv_validation_result$data
      }
      
      citations_list <- list()
      for (i in seq_len(citation_count())) {
        c_text <- input[[paste0("citation_text_", i)]]
        c_title <- input[[paste0("citation_title_", i)]]
        c_url <- input[[paste0("citation_url_", i)]]
        
        if (!is.null(c_text) && trimws(c_text) != "") {
          citations_list[[length(citations_list) + 1]] <- list(
            text = trimws(c_text),
            title = (if (!is.null(c_title) && trimws(c_title) != "") trimws(c_title) else NA_character_),
            url = (if (!is.null(c_url) && trimws(c_url) != "") trimws(c_url) else NA_character_)
          )
        }
      }
      
      citation_json <- if (length(citations_list) > 0) {
        jsonlite::toJSON(citations_list, auto_unbox = TRUE, null = "null")
      } else {
        "[]"
      }
      
      # Converts input selections to true PostgreSQL text[] array syntax
      to_pg_array <- function(val) {
        if (is.null(val) || length(val) == 0) return(NA_character_)
        parts <- trimws(val)
        parts <- parts[parts != ""]
        if (length(parts) == 0) return(NA_character_)
        paste0("{", paste(sprintf('"%s"', gsub('"', '\\"', parts, fixed = TRUE)), collapse = ","), "}")
      }
      
      # Safely converts blank scalar text strings into true database NULL values
      empty_to_null <- function(val) {
        if (is.null(val) || length(val) == 0 || trimws(val) == "") return(NA_character_)
        return(trimws(val))
      }
      
      user_name_to_log <- if(is.null(current_user)) "System Admin" else current_user
      
      tryCatch({
        revision_json <- jsonlite::toJSON(list(
          list(
            message = input$revision_log,
            user = user_name_to_log,
            date = as.character(Sys.Date())
          )
        ), auto_unbox = TRUE)
        
        max_id_res <- dbGetQuery(db_conn, "SELECT MAX(article_id) as max_id FROM sav_records;")
        new_article_id <- if(is.na(max_id_res$max_id[1])) 1 else as.integer(max_id_res$max_id[1] + 1)
        
        lookup_query <- "SELECT user_id FROM users WHERE name = $1 OR email ILIKE $2 LIMIT 1"
        user_res <- dbGetQuery(db_conn, lookup_query, params = list(
          current_user, 
          paste0(current_user, "@%")
        ))
        uploader_id <- if (nrow(user_res) > 0) as.integer(user_res$user_id[1]) else 1L
        
        query <- "
          INSERT INTO sav_records (
            article_id, user_id, article_type, title,
            location_country, location_state_province, location_waterbody, climate_zone,
            sav_species, sav_type,
            sav_metric_category, specific_sav_metric, sav_function_category, specific_sav_function,
            methods, direction_of_relationship, main_finding, quotes_and_notes,
            citations, revision_log, lat_long
          ) VALUES (
            $1, $2, $3, $4,
            $5, $6, $7, $8,
            $9, $10,
            $11, $12, $13, $14,
            $15, $16, $17, $18,
            $19::jsonb, $20::jsonb, $21
          );"
        
        lat_long_clean <- if (!is.null(input$lat_long) && nzchar(trimws(input$lat_long))) trimws(input$lat_long) else NA_character_
        
        dbExecute(db_conn, query, params = list(
          new_article_id, 
          uploader_id,    
          empty_to_null(input$article_type), 
          empty_to_null(input$title), 
          to_pg_array(input$location_country), 
          to_pg_array(input$location_state_province), 
          to_pg_array(input$location_waterbody), 
          to_pg_array(input$climate_zone), 
          to_pg_array(input$sav_species), 
          to_pg_array(input$sav_type), 
          to_pg_array(input$sav_metric_category), 
          to_pg_array(input$specific_sav_metric), # FIXED: Parameter 12 wrapped securely in to_pg_array()
          to_pg_array(input$sav_function_category), 
          to_pg_array(input$specific_sav_function), 
          to_pg_array(input$methods), 
          empty_to_null(input$direction_of_relationship), 
          empty_to_null(input$main_finding), 
          empty_to_null(input$quotes_and_notes), 
          citation_json, 
          revision_json,
          lat_long_clean
        ))
        
        if (nrow(df_csv) > 0) {
          df_csv$article_id <- new_article_id
          df_csv$row_index <- 1:nrow(df_csv) 
          names(df_csv) <- gsub("\\.", "_", names(df_csv)) 
          dbAppendTable(db_conn, "csv_data", df_csv)
        }
        
        show_success_modal(
          session,
          "✓ Submission Successful",
          sprintf("Your SAV relationship <strong>%s</strong> has been successfully saved to the database (ID: %s).", input$title, new_article_id)
        )
        
        try({ shinyjs::reset(ns("upload_form")) }, silent = TRUE)
        
        if (citation_count() > 1) {
          for (i in 2:citation_count()) {
            removeUI(selector = paste0("#", ns(paste0("citation_block_", i))))
          }
          citation_count(1)
        }
        
        try({ updateTextAreaInput(session, "citation_text_1", value = "") }, silent = TRUE)
        try({ updateTextInput(session, "citation_title_1", value = "") }, silent = TRUE)
        try({ updateTextInput(session, "citation_url_1", value = "") }, silent = TRUE)
        
        all_text_inputs <- c(
          "title", "article_type", "direction_of_relationship", "specific_sav_metric",
          "sav_species", "sav_type", "climate_zone", "sav_metric_category",
          "sav_function_category", "specific_sav_function", "methods", 
          "location_country", "location_state_province", "location_waterbody", "lat_long"
        )
        for (tid in all_text_inputs) {
          try({ updateSelectizeInput(session, inputId = tid, selected = character(0)) }, silent = TRUE)
          try({ updateTextInput(session, inputId = tid, value = "") }, silent = TRUE)
        }
        
        textarea_inputs <- c("main_finding", "quotes_and_notes", "revision_log")
        for (tid in textarea_inputs) {
          try({ updateTextAreaInput(session, inputId = tid, value = "") }, silent = TRUE)
        }
        
        output$csv_validation_status <- renderUI({ NULL })
        
      }, error = function(e) {
        error_msg <- conditionMessage(e)
        show_error_modal(
          session,
          "❌ Error Saving to Database",
          sprintf("Failed to save your data. Error: %s<br><br><strong>Please verify all required fields.</strong>", error_msg)
        )
      })
    })
    
    # ── 2. Preview modal logic ──
    observeEvent(input$preview, {
      req(input$title)
      
      cit_list <- tagList()
      for (i in seq_len(citation_count())) {
        c_text <- input[[paste0("citation_text_", i)]]
        c_title <- input[[paste0("citation_title_", i)]]
        c_url <- input[[paste0("citation_url_", i)]]
        
        if (!is.null(c_text) && trimws(c_text) != "") {
          link_tag <- if (!is.null(c_url) && trimws(c_url) != "") {
            tags$a(href = c_url, target = "_blank", if (!is.null(c_title) && trimws(c_title) != "") c_title else "Link")
          } else {
            span(if (!is.null(c_title)) c_title else "")
          }
          cit_list <- tagAppendChild(cit_list, tags$li(c_text, " ", link_tag))
        }
      }
      
      show_val <- function(val) { 
        if (is.null(val) || length(val) == 0 || all(trimws(val) == "")) em("Not provided") else paste(val, collapse = ", ") 
      }
      
      make_preview_row <- function(label, val) {
        if (is.null(val) || length(val) == 0 || all(trimws(val) == "")) return(NULL)
        fluidRow(column(4, strong(paste0(label, ":"))), column(8, paste(val, collapse = ", ")))
      }
      
      showModal(modalDialog(
        title = "Preview: Final Submission Layout",
        size = "xl", 
        easyClose = TRUE,
        footer = modalButton("Close Preview"),
        
        tagList(
          fluidRow(
            column(12, align = "center", tags$h3(input$title, style = "margin-top: 10px; margin-bottom: 20px;"))
          ),
          
          div(
            style = "border: 1px solid #ddd; padding: 15px; margin-bottom: 10px; background-color: #f8f9fa; border-radius: 8px;",
            tags$strong("Article Metadata ▼", class = "section-title", style = "display:block; margin-bottom:15px; color:#0073e6; font-size:1.1em;"),
            div(style = "font-size:1.1em;",
                fluidRow(column(4, strong("SAV Species:")), column(8, show_val(input$sav_species))),
                fluidRow(column(4, strong("SAV Type:")), column(8, show_val(input$sav_type))),
                fluidRow(column(4, strong("Climate Zone:")), column(8, show_val(input$climate_zone))),
                fluidRow(column(4, strong("Metric Category:")), column(8, show_val(input$sav_metric_category))),
                fluidRow(column(4, strong("Specific Metric:")), column(8, show_val(input$specific_sav_metric))),
                fluidRow(column(4, strong("Function Category:")), column(8, show_val(input$sav_function_category))),
                fluidRow(column(4, strong("Specific Function:")), column(8, show_val(input$specific_sav_function))),
                fluidRow(column(4, strong("Direction of Relationship:")), column(8, show_val(input$direction_of_relationship))),
                fluidRow(column(4, strong("Methods:")), column(8, show_val(input$methods))),
                make_preview_row("Country", input$location_country),
                make_preview_row("State / Province", input$location_state_province),
                make_preview_row("Waterbody", input$location_waterbody),
                make_preview_row("Coordinates", input$lat_long)
            )
          ),
          
          div(
            style = "border: 1px solid #ddd; padding: 15px; margin-bottom: 10px; background-color: #ffffff; border-radius: 8px;",
            tags$strong("Findings & Notes ▼", class = "section-title", style = "display:block; margin-bottom:15px; color:#0073e6; font-size:1.1em;"),
            div(style = "font-size:1.1em;",
                strong("Main Finding"), br(), p(show_val(input$main_finding)),
                strong("Quotes & Notes"), br(), p(show_val(input$quotes_and_notes))
            )
          ),
          
          div(
            style = "border: 1px solid #ddd; padding: 15px; margin-bottom: 10px; background-color: #ffffff; border-radius: 8px;",
            tags$strong("Citation(s) ▼", class = "section-title", style = "display:block; margin-bottom:15px; color:#0073e6; font-size:1.1em;"),
            div(style = "font-size:1.1em;",
                if (length(cit_list$children) > 0) tags$ul(cit_list) else p(em("No citations added yet."))
            )
          ),
          
          if(!is.null(input$sr_csv_file)) {
            tagList(
              div(
                style = "border: 1px solid #ddd; padding: 15px; margin-bottom: 10px; background-color: #ffffff; border-radius: 8px; opacity: 0.7;",
                tags$strong("Quantitative Data (CSV) ▼", class = "section-title", style = "display:block; margin-bottom:15px; color:#0073e6; font-size:1.1em;"),
                div(style = "font-size:1.1em; text-align: center; padding: 20px;",
                    icon("table", "fa-2x"), br(),
                    em("Your uploaded CSV data will render here.")
                )
              ),
              div(
                style = "border: 1px solid #ddd; padding: 15px; margin-bottom: 10px; background-color: #ffffff; border-radius: 8px; opacity: 0.7;",
                tags$strong("Quantitative Chart ▼", class = "section-title", style = "display:block; margin-bottom:15px; color:#0073e6; font-size:1.1em;"),
                div(style = "font-size:1.1em; text-align: center; padding: 20px;",
                    icon("chart-line", "fa-2x"), br(),
                    em("An interactive Plotly chart will automatically render here.")
                )
              )
            )
          } else {
            NULL
          }
        )
      ))
    })
    
    # ── 3. CSV Template Download ──
    output$download_csv_template <- downloadHandler(
      filename = function() { paste0("SAV_Quantitative_Template_", Sys.Date(), ".csv") },
      content = function(file) {
        template_data <- data.frame(
          curve.id = rep("site_a", 5), stressor.label = rep("shoot_density", 5),
          stressor.x = c(10, 20, 30, 40, 50), units.x = rep("shoots_m2", 5),
          response.label = rep("wave_attenuation", 5), response.y = c(10, 25, 45, 70, 85),
          units.y = rep("percent", 5), 
          stressor.value = rep("constant", 5),
          lower.limit = c(5, 20, 40, 65, 80), upper.limit = c(15, 30, 50, 75, 90),
          sd = rep(2, 5),
          plot.type = rep("scatter", 5)
        )
        write.csv(template_data, file, row.names = FALSE)
      }
    )
  })
}
# nolint end