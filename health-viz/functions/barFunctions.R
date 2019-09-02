# Functions for the bar plot (tab 1)

# Function to filter data for bar plot
FilterBar <- function(display_id_in, level_id_in, year_id_in, sex_id_in, metric_id_in) {
  filtered_data <- ihme2017Data %>%
    filter(display == display_id_in,
           grepl(level_id_in, level),
           year_id == year_id_in,
           sex_id == sex_id_in,
           metric_id == metric_id_in)
  return(filtered_data)
}

# Constants
SHOW_TOP_BAR <- 15
BAR_WIDTH <- 0.9
BAR_PLOT_WIDTH_MULTIPLIER <- 1.2

# Function to make bar plot
BarPlot <- function(data, measure) {
  data <- data %>%
    filter(measure_id == measure) %>%
    GetTop(., SHOW_TOP_BAR)
  
  plot_width <- max(data$val)*BAR_PLOT_WIDTH_MULTIPLIER
  percent_sign <- ifelse(data$metric[1] == 2, "%", "")
  plot_title <- MEASURES[[measure]]$name
  color <- MEASURES[[measure]]$color
  
  ggplot(data=data, aes(x=reorder(id_name, val),y=val)) +
    coord_flip() +
    geom_bar(position="dodge", stat="identity", width=BAR_WIDTH, fill=color) + 
    geom_text(hjust=0, aes(x=id_name, y=0, label=paste0(" ", rank, ". ", id_name))) +
    annotate(geom="text", hjust=1, x=data$id_name, y=plot_width, label=paste0(data$val, percent_sign)) +
    theme(panel.grid.major=element_blank(),
          panel.grid.minor=element_blank(),
          panel.background=element_blank(),
          axis.title.x=element_blank(),
          axis.text.x=element_blank(),
          axis.ticks.x=element_blank(),
          axis.title.y=element_blank(),
          axis.text.y=element_blank(),
          axis.ticks.y=element_blank(),
          plot.title=element_text(size=16, face="bold")) +
    ggtitle(plot_title) +
    scale_y_continuous(expand = c(0,0), limits = c(0, plot_width))
}