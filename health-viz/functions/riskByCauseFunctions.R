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
# Plotly- Add trace?
# library(data.table)
# RiskByCausePlot <- function(data) {
#   data.table::melt(data, id.vars='cause_id')
#   plot_ly(data, x = ~val, y = ~id_name, type = 'bar', # orientation = 'h',
#           name = ~id_name, color = ~id_name) %>%
#     layout(yaxis = list(title = "Count", barmode = 'stack'))
# }


# GGPLOT
RiskByCausePlot <- function(data) {
  ggplot() +
    geom_bar(data = data, aes(x = id_name, y = val, fill = cause_id), stat = "identity") +
    coord_flip()

  # ggplot(data = data, aes(x = id_name, y = val, fill = cause_id)) +
  #   geom_bar(position = "dodge", stat = "identity", fill = "cause_id")
    #coord_flip()


  # %>% ggplotly()
}
