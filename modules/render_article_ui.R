# nolint start

library(shinyjs)
library(dygraphs)

render_article_ui <- function(article_id, data) {
  article <- data[data$article_id == article_id, ]
  if (nrow(article) == 0) {
    return(tags$p("Article not found."))
  }
  
  # All IDs scoped to article_id to avoid conflicts between articles
  expand_id <- paste0("expand_all_", article_id)
  collapse_id <- paste0("collapse_all_", article_id)
  meta_id <- paste0("metadata_section_", article_id)
  desc_id <- paste0("description_section_", article_id)
  cite_id <- paste0("citations_section_", article_id)
  csv_id <- paste0("csv_section_", article_id)
  plot_id <- paste0("interactive_plot_section_", article_id)
  
  tagList(
    # ── Title ──────────────────────────────────────────────────────────────
    fluidRow(
      column(12,
             align = "center",
             tags$h3(article$title, style = "margin-top: 20px; margin-bottom: 10px;")
      )
    ),
    
    # ── Expand / Collapse ──────────────────────────────────────────────────
    fluidRow(
      column(12,
             align = "center",
             actionButton(expand_id, "Expand All",
                          class = "btn-sm",
                          style = "padding: 8px 16px; margin-right: 8px;"
             ),
             actionButton(collapse_id, "Collapse All",
                          class = "btn-sm",
                          style = "padding: 8px 16px;"
             )
      )
    ),
    
    # ── Article Metadata ───────────────────────────────────────────────────
    div(
      style = "border: 1px solid #ddd; padding: 15px; margin-bottom: 10px; background-color: #f8f9fa; border-radius: 8px;",
      actionLink(paste0("toggle_metadata_", article_id), "Article Metadata ▼", class = "section-title"),
      hidden(div(
        id    = meta_id,
        style = "font-size:1.1em;",
        fluidRow(column(4, strong("SAV Species:")), column(8, textOutput(paste0("sav_species_", article_id)))),
        fluidRow(column(4, strong("SAV Type:")), column(8, textOutput(paste0("sav_type_", article_id)))),
        fluidRow(column(4, strong("Climate Zone:")), column(8, textOutput(paste0("climate_zone_", article_id)))),
        fluidRow(column(4, strong("Metric Category:")), column(8, textOutput(paste0("sav_metric_category_", article_id)))),
        fluidRow(column(4, strong("Specific Metric:")), column(8, textOutput(paste0("specific_sav_metric_", article_id)))),
        fluidRow(column(4, strong("Function Category:")), column(8, textOutput(paste0("sav_function_category_", article_id)))),
        fluidRow(column(4, strong("Specific Function:")), column(8, textOutput(paste0("specific_sav_function_", article_id)))),
        fluidRow(column(4, strong("Direction of Relationship:")), column(8, textOutput(paste0("direction_of_relationship_", article_id)))),
        fluidRow(column(4, strong("Methods:")), column(8, textOutput(paste0("methods_", article_id)))),
        
        # Dynamic UI placeholders for conditional location fields
        uiOutput(paste0("location_country_ui_", article_id)),
        uiOutput(paste0("location_state_province_ui_", article_id)),
        uiOutput(paste0("location_waterbody_ui_", article_id))
      ))
    ),
    
    # ── Findings & Notes ───────────────────────────────────────────────────
    div(
      style = "border: 1px solid #ddd; padding: 15px; margin-bottom: 10px; background-color: #ffffff; border-radius: 8px;",
      actionLink(paste0("toggle_description_", article_id), "Findings & Notes ▼", class = "section-title"),
      hidden(div(
        id = desc_id,
        style = "font-size:1.1em;",
        strong("Main Finding"), br(), textOutput(paste0("main_finding_", article_id)), br(), br(),
        strong("Quotes & Notes"), br(), textOutput(paste0("quotes_and_notes_", article_id))
      ))
    ),
    
    # ── Citations ──────────────────────────────────────────────────────────
    div(
      style = "border: 1px solid #ddd; padding: 15px; margin-bottom: 10px; background-color: #ffffff; border-radius: 8px;",
      actionLink(paste0("toggle_citations_", article_id), "Citation(s) ▼", class = "section-title"),
      hidden(div(
        id    = cite_id,
        style = "font-size:1.1em;",
        uiOutput(paste0("citations_", article_id))
      ))
    ),
    
    # ── CSV Data Table ─────────────────────────────────────────────────────
    div(
      style = "border: 1px solid #ddd; padding: 15px; margin-bottom: 10px; background-color: #ffffff; border-radius: 8px;",
      actionLink(paste0("toggle_csv_", article_id), "Quantitative Data (CSV) ▼", class = "section-title"),
      hidden(div(
        id    = csv_id,
        style = "font-size:1.1em;",
        tableOutput(paste0("csv_table_", article_id))
      ))
    ),
    
    # ── Interactive Plot ───────────────────────────────────────────────────
    div(
      style = "border: 1px solid #ddd; padding: 15px; margin-bottom: 10px; background-color: #ffffff; border-radius: 8px;",
      actionLink(paste0("toggle_interactive_plot_", article_id), "Quantitative Chart ▼", class = "section-title"),
      hidden(div(
        id    = plot_id,
        style = "font-size:1.1em;",
        plotlyOutput(paste0("interactive_plot_", article_id))
      ))
    )
  )
}

# nolint end