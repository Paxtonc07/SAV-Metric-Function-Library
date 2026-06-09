# modules/eda.R
# nolint start
library(shiny)
library(DBI)
library(dplyr)
library(ggplot2)
library(RPostgres)
library(pool)
library(plotly)

# UI for EDA module
edaUI <- function(id) {
  ns <- NS(id)
  tagList(
    fluidPage(
      h3("What's in the SAV e-Library?", style = "color: #0077b6; text-align: center;"),
      tabsetPanel(
        tabPanel("SAV Metrics", plotlyOutput(ns("plot_metric"))),
        tabPanel("SAV Species", plotlyOutput(ns("plot_species"))),
        tabPanel("SAV Functions", plotlyOutput(ns("plot_function"))),
        tabPanel("Top Locations", plotlyOutput(ns("plot_locations")))
      )
    )
  )
}

# Server for EDA module
edaServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    # Shared colors
    bar_fill <- "#6082B6" # Updated to a nice steel blue for SAV
    text_color <- "#005f5f"
    
    # Helper to pull top N counts for plain text columns
    top_n_counts <- function(tbl, col, n = 10) {
      df <- dbGetQuery(pool, sprintf("
        SELECT %s AS value, COUNT(*) AS n
        FROM %s
        WHERE %s IS NOT NULL AND TRIM(%s) <> ''
        GROUP BY %s
        ORDER BY n DESC
        LIMIT %d", col, tbl, col, col, col, n))
      
      # Convert integer64 to standard numeric for Plotly
      if (nrow(df) > 0) df$n <- as.numeric(df$n)
      df
    }
    
    # 1. SAV Metrics (Plain Text)
    output$plot_metric <- renderPlotly({
      df <- top_n_counts("sav_records", "specific_sav_metric", 10)
      
      p <- ggplot(df, aes(x = reorder(value, n), y = n, text = paste("Metric:", value, "<br>Count:", n))) +
        geom_col(fill = bar_fill) +
        coord_flip() +
        labs(title = "Top 10 SAV Metrics in the e-Library", x = NULL, y = "Count") +
        theme_minimal() +
        theme(
          plot.title = element_text(size = 18, face = "bold", color = text_color),
          axis.text = element_text(size = 12, color = text_color),
          axis.title = element_text(size = 14, color = text_color),
          panel.grid.major.x = element_blank()
        )
      
      ggplotly(p, tooltip = "text") %>% config(displayModeBar = FALSE)
    })
    
    # 2. SAV Species (Array)
    output$plot_species <- renderPlotly({
      df1 <- dbGetQuery(pool, "
        SELECT TRIM(unnested) AS raw, COUNT(*) AS n
        FROM sav_records,
          LATERAL unnest(sav_species) AS unnested
        WHERE sav_species IS NOT NULL
          AND array_length(sav_species, 1) > 0
        GROUP BY raw
        ORDER BY n DESC
        LIMIT 10
      ")
      
      if (nrow(df1) > 0) df1$n <- as.numeric(df1$n)
      
      p <- ggplot(df1, aes(x = reorder(raw, n), y = n, text = paste("Species:", raw, "<br>Count:", n))) +
        geom_col(fill = bar_fill) +
        coord_flip() +
        labs(title = "Top 10 SAV Species in the e-Library", x = NULL, y = "Count") +
        theme_minimal() +
        theme(
          plot.title = element_text(size = 18, face = "bold", color = text_color),
          axis.text  = element_text(size = 12, color = text_color),
          axis.title = element_text(size = 14, color = text_color),
          panel.grid.major.x = element_blank()
        )
      
      ggplotly(p, tooltip = "text") %>% config(displayModeBar = FALSE)
    })
    
    # 3. SAV Functions (Array)
    output$plot_function <- renderPlotly({
      df1 <- dbGetQuery(pool, "
        SELECT TRIM(unnested) AS raw, COUNT(*) AS n
        FROM sav_records,
          LATERAL unnest(specific_sav_function) AS unnested
        WHERE specific_sav_function IS NOT NULL
          AND array_length(specific_sav_function, 1) > 0
        GROUP BY raw
        ORDER BY n DESC
        LIMIT 10
      ")
      
      if (nrow(df1) > 0) df1$n <- as.numeric(df1$n)
      
      p <- ggplot(df1, aes(x = reorder(raw, n), y = n, text = paste("Function:", raw, "<br>Count:", n))) +
        geom_col(fill = bar_fill) +
        coord_flip() +
        labs(title = "Top 10 Specific SAV Functions in the e-Library", x = NULL, y = "Count") +
        theme_minimal() +
        theme(
          plot.title = element_text(size = 18, face = "bold", color = text_color),
          axis.text  = element_text(size = 12, color = text_color),
          axis.title = element_text(size = 14, color = text_color),
          panel.grid.major.x = element_blank()
        )
      
      ggplotly(p, tooltip = "text") %>% config(displayModeBar = FALSE)
    })
    
    # 4. Locations (Array)
    output$plot_locations <- renderPlotly({
      df1 <- dbGetQuery(pool, "
        SELECT TRIM(unnested) AS raw, COUNT(*) AS n
        FROM sav_records,
          LATERAL unnest(location_state_province) AS unnested
        WHERE location_state_province IS NOT NULL
          AND array_length(location_state_province, 1) > 0
        GROUP BY raw
        ORDER BY n DESC
        LIMIT 10
      ")
      
      if (nrow(df1) > 0) df1$n <- as.numeric(df1$n)
      
      p <- ggplot(df1, aes(x = reorder(raw, n), y = n, text = paste("Location:", raw, "<br>Count:", n))) +
        geom_col(fill = bar_fill) +
        coord_flip() +
        labs(title = "Top 10 States / Provinces in the e-Library", x = NULL, y = "Count") +
        theme_minimal() +
        theme(
          plot.title = element_text(size = 18, face = "bold", color = text_color),
          axis.text  = element_text(size = 12, color = text_color),
          axis.title = element_text(size = 14, color = text_color),
          panel.grid.major.x = element_blank()
        )
      
      ggplotly(p, tooltip = "text") %>% config(displayModeBar = FALSE)
    })
    
  })
}
# nolint end