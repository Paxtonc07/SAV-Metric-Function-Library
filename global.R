# nolint start

# Load required packages
library(shiny)
library(DBI)
library(markdown)
library(RPostgres)
library(pool)
library(promises)
library(openxlsx)
library(rlang)

# Raise Shiny's maxRequestSize to allow server-side processing of larger file uploads (e.g., PDFs)
options(shiny.maxRequestSize = 10 * 1024^2) # 10 MB

# Configure future plan for background async tasks (emails, etc.)
if (requireNamespace("future", quietly = TRUE)) {
  future::plan("multisession")
} else {
  warning("Package 'future' not installed; async tasks will not run in background. Install 'future' to enable async behaviors.")
}

# Connect to Postgres database
db_config <- list(
  host = Sys.getenv("DB_HOST", "localhost"),
  port = as.integer(Sys.getenv("DB_PORT", "5432")),
  dbname = Sys.getenv("DB_NAME", "nwfsc_public_dev"),
  user = Sys.getenv("DB_USER", "postgres"),
  password = Sys.getenv("DB_PASSWORD", ""),
  
  # --- UPDATED: Now pointing to the new SAV schema ---
  schema = Sys.getenv("DB_SCHEMA", "sav_relationships") 
)

# Validate configuration
if (db_config$password == "") {
  stop("Database password not found. Please check your .Renviron file.")
}

# create a connection pool
pool <- dbPool(
  drv = RPostgres::Postgres(),
  host = db_config$host,
  port = db_config$port,
  dbname = db_config$dbname,
  user = db_config$user,
  password = db_config$password,
  minSize = 1,
  maxSize = 5
)

# set the search path to the schema
dbExecute(pool, sprintf("SET search_path TO %s, public", db_config$schema))

# test connection
tryCatch(
  {
    dbGetQuery(pool, "SELECT 1")
    message("db connection success")
  },
  error = function(e) {
    stop("db connection failed: ", e$message)
  }
)

# --- UPDATED: Initialize all SAV variables with empty vectors ---
article_types <- character(0)
location_countries <- character(0)
location_states_provinces <- character(0)
location_waterbodies <- character(0)
climate_zones <- character(0)
sav_species <- character(0)
sav_types <- character(0)
sav_metric_categories <- character(0)
specific_sav_metrics <- character(0)
sav_function_categories <- character(0)
specific_sav_functions <- character(0)
methods_list <- character(0)
directions_of_relationship <- character(0)

# Check if the `sav_records` table exists
table_exists <- dbExistsTable(pool, Id(schema = db_config$schema, table = "sav_records"))

if (table_exists) {
  tryCatch(
    {
      # query with schema prefix
      data <- dbGetQuery(pool, sprintf("SELECT * FROM %s.sav_records", db_config$schema))
      
      # Helper function to safely extract unique values, even from Postgres Arrays (lists in R)
      get_unique <- function(col) {
        sort(unique(na.omit(unlist(col))))
      }
      
      # Extract unique values for the UI dropdowns
      article_types <- get_unique(data$article_type)
      location_countries <- get_unique(data$location_country)
      location_states_provinces <- get_unique(data$location_state_province)
      location_waterbodies <- get_unique(data$location_waterbody)
      climate_zones <- get_unique(data$climate_zone)
      
      sav_species <- get_unique(data$sav_species)
      sav_types <- get_unique(data$sav_type)
      
      sav_metric_categories <- get_unique(data$sav_metric_category)
      specific_sav_metrics <- get_unique(data$specific_sav_metric)
      sav_function_categories <- get_unique(data$sav_function_category)
      specific_sav_functions <- get_unique(data$specific_sav_function)
      
      methods_list <- get_unique(data$methods)
      directions_of_relationship <- get_unique(data$direction_of_relationship)
      
      message(sprintf("Loaded %d records from database.", nrow(data)))
    },
    error = function(e) {
      warning("failed to load data from sav_records: ", e$message)
    }
  )
} else {
  warning(sprintf("Table sav_records does not exist in schema %s", db_config$schema))
}

# Safely close the pool when the R process shuts down globally
onStop(function() {
  if (exists("pool")) {
    poolClose(pool)
    cat("db connection pool closed globally.\n")
  }
})

# nolint end