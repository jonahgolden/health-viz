# Functions for the Risk By Cause plot (tab 3)

# Function to filter data for risk by cause plot
FilterRiskByCause <- function(level_id_in, year_id_in, sex_id_in, metric_id_in, measure_id_in) {
  filtered_data <- riskByCauseData %>%
    filter(grepl(level_id_in, level),
           year_id == year_id_in,
           sex_id == sex_id_in,
           metric_id == metric_id_in,
           measure_id == measure_id_in)
  return(filtered_data)
}

# Function to make risk by cause plot
RiskByCausePlot <- function(data) {
  print("Im heeeere")
}