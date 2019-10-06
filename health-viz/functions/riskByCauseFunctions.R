### Functions for the Risk By Cause plot (tab 3)

SHOW_TOP = 40

### Function to filter data for risk by cause plot
FilterRiskByCause <- function(level_id_in, year_id_in, sex_id_in, metric_id_in, measure_id_in) {
  filtered_data <- riskByCauseData %>%
    filter(grepl(level_id_in, level),
           year_id == year_id_in,
           sex_id == sex_id_in,
           metric_id == metric_id_in,
           measure_id == measure_id_in)
  
  #xlabel = stringr::str_wrap(paste(METRICS[[metric_id_in]]$name, MEASURES[[measure_id_in]]$short_name, sep=" of "), 13)
  return(list(data = filtered_data,
              xlabel = paste(METRICS[[metric_id_in]]$name, MEASURES[[measure_id_in]]$short_name, sep=" of "),
              title = paste0("California, ", SEXES[[sex_id_in]]$name, ", ", year_id_in),
              measure = MEASURES[[measure_id_in]]$short_name,
              metric = METRICS[[metric_id_in]]$name
  )
  )
}

mental_disorders <- riskByCauseData %>%
  filter(grepl(1, level),
         year_id == 2017,
         sex_id == 3,
         metric_id == 1,
         #measure_id == 1,
         cause_id == 558)


# GGPLOT
RiskByCausePlot <- function(data_in) {
  
  ### Filter negative values (only exist for alcohol - this is weird) 
  # data <- filter(data, val > 0)
  
  ### Add Total.  Arrange by sort order for ordering bars?
  data <- data_in$data
  data <- data %>%
    mutate(total = mapply(function(r) sum(data$val[data$risk_id == r]), risk_id))
  
  ### Remove non-top items
  totals = unique(data$total)
  n <- length(totals)
  if (n > SHOW_TOP) {
    min_total = sort(totals,partial=n-SHOW_TOP)[n-SHOW_TOP]
    data <- data %>% 
      filter(total > min_total) %>%
      arrange(total)
  }
  
  p <- ggplot(data, aes(x = reorder(risk_short_name, total), y = val, fill = cause_short_name,
                        text=paste0(cause_name,
                                    '<br><b>Attributable Risk: </b>', risk_name,
                                    '<br><b>', data_in$metric, ': </b>', val, data_in$measure)
  )) +
    geom_bar(stat = "identity", lwd=0.2, color="white") +
    labs(title=data_in$title, x="", y=data_in$xlabel) +
    scale_fill_manual(name="Cause", values=BAR_PALETTE) +
    theme_classic() +
    theme(legend.position = "right", legend.key.size = unit(4.0, 'cm')) +
    coord_flip(ylim = c(0, max(data$total))) # keep as last ;)
  
  ggplotly(p, tooltip=c("text")) # %>% layout(legend = list(orientation = "v", x = 100000, size = 0.1))
}

# p <- ggplot(aes(text=)) +
#   geom_bar(data = data, stat = "identity", lwd=0.2, color="white",
#            aes(x = reorder(risk_short_name, total), y = val, fill = cause_short_name)) +
#   labs(title=data_in$title, x="", y=data_in$xlabel) +
#   scale_fill_manual(name="Cause", labels = CAUSE_PALETTE$names, values=BAR_PALETTE) +
#   theme_classic() +
#   theme(legend.position = "right", legend.key.size = unit(4.0, 'cm')) +
#   coord_flip(ylim = c(0, max(data$total))) # keep as last ;)



# Function to make risk by cause plot
# Plotly- Add trace?
# library(data.table)
# RiskByCausePlot <- function(data) {
#   data.table::melt(data, id.vars='cause_id')
#   plot_ly(data, x = ~val, y = ~risk_short_name, type = 'bar', # orientation = 'h',
#           name = ~risk_short_name, color = ~risk_short_name) %>%
#     layout(yaxis = list(title = "Count", barmode = 'stack'))
# }
