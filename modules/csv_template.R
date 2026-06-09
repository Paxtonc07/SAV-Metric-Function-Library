# nolint start

# Return the CSV template as a data frame
get_csv_template <- function() {
  data.frame(
    curve.id = rep("site_a", 5),
    stressor.label = rep("shoot_density", 5),
    stressor.x = c(10, 20, 30, 40, 50),
    units.x = rep("shoots_m2", 5),
    response.label = rep("wave_attenuation", 5),
    response.y = c(10, 25, 45, 70, 85),
    units.y = rep("percent", 5),
    plot.type = c("scatter", "scatter", "scatter", "scatter", "scatter"), 
    stressor.value = rep("constant", 5),
    lower.limit = c(5, 20, 40, 65, 80),
    upper.limit = c(15, 30, 50, 75, 90),
    sd = rep(2.0, 5),
    stringsAsFactors = FALSE
  )
}

# Write the template to a CSV file
write_csv_template <- function(file_path) {
  write.csv(get_csv_template(), file_path, row.names = FALSE)
}

# nolint end