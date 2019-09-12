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

md <- riskByCauseData %>%
  filter(grepl(1, level),
         year_id == 2017,
         sex_id == 3,
         metric_id == 1,
         #measure_id == 1,
         cause_id == 558)

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
  
  nb = 22 # length(unique(data$cause_name))
  nm = length(unique(data$first_cause_parent))
  colors = apply(expand.grid(seq(70,40,length=nm), 100, seq(15,375,length=nb+1)[1:nb]), 1,
                 function(x) hcl(x[3],x[2],x[1])) # hcl(x[3],x[2],x[1]))
  data <- filter(data, val > 0)  # For negative alcohol vals
  data <- data %>%
    mutate(total = mapply(function(r) sum(data$val[data$risk_id == r]), risk_id)) %>%
    arrange(sort_order)

  #data$cause_short_name <- as.factor(data$cause_short_name)
  #data$first_cause_parent <- factor(data$first_cause_parent, levels = data$cause_short_name)

  p <- ggplot() +
    geom_bar(data = data, aes(x = reorder(risk_short_name, total), y = val, fill = cause_short_name), stat = "identity") +
    # theme(legend.position="bottom", legend.direction="horizontal",
    #       legend.title = element_blank()) +
    # scale_fill_identity() +
    scale_fill_discrete(breaks = CAUSE_SHORT_NAMES[1:22]) +
    #scale_fill_manual(values=level2$color, labels=level2$cause_name) +
    theme_classic() +
    theme(legend.position = "right") +
    coord_flip(ylim = c(0, max(data$total))) # keep as last ;)
  
  #p

  ggplotly(p) # %>% layout(legend = list(orientation = "v", x = 100000, size = 0.1))
}
