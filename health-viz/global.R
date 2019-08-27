library(dplyr)
library(magrittr)
library(shiny)
library(shinyWidgets)
library(ggplot2)

# Constants-----------------------------------------------------------------------
SIDE_BAR_PANEL_WIDTH <- 4
PURPLE <- "#8F98B5"
RED <- "#E9A291"
LIGHT_BLUE <- "#8ECAE3"
TAN <- "#E6C8A0"

VALID_YEARS <- c(1990:2017)
DEATH_ID <- 1
DALY_ID<- 2
YLD_ID <- 3
YLL_ID <- 4
MEASURES <- list(
  "1" = list(name = "Deaths", color = PURPLE, short_name = "Deaths"),
  "2" = list(name = "Disability-Adjusted Life Years", color = RED, short_name = "DALYs"),
  "3" = list(name = "Years Lived with Disability", color = LIGHT_BLUE, short_name = "YLDs"),
  "4" = list(name = "Years of Life Lost", color = TAN, short_name = "YLLs")
)
METRICS <- list(
  "1" = list(name = "Number", symbol = "#"),
  "2" = list(name = "Percent", symbol = "%"),
  "3" = list(name = "Rate (per 100,000)", symbol = "Rate")
)

# Load Data-----------------------------------------------------------------------
ihme2017Data <- readRDS("../upstream/data/ihme-2017-v2.RDS") %>%
  subset(., year_id >= min(VALID_YEARS))

# Functions-----------------------------------------------------------------------

GetTop <- function(data, keep_top_number) {
  ranked_data <- data %>%
    mutate(rank = rank(-val, ties.method = 'first')) %>%
    filter(rank <= keep_top_number)
  return(ranked_data)
}

FilterBar <- function(display_id_in, level_id_in, year_id_in, sex_id_in, metric_id_in) {
  filtered_data <- ihme2017Data %>%
    filter(display == display_id_in,
           grepl(level_id_in, level),
           year_id == year_id_in,
           sex_id == sex_id_in,
           metric_id == metric_id_in)
  return(filtered_data)
}

FilterLine <- function(display_id_in, level_id_in, sex_id_in, metric_id_in, measure_id_in, show_top) {
  filtered_data <- ihme2017Data %>%
    filter(display == display_id_in,
           grepl(level_id_in, level),
           sex_id == sex_id_in,
           metric_id == metric_id_in,
           measure_id == measure_id_in) 
  
  top_years <- filtered_data %>%
    filter(year_id == max(filtered_data$year_id)) %>%
    GetTop(., show_top)
  
  return(filtered_data %>% 
           filter(id_num %in% top_years$id_num) %>%
           arrange(id_num, year_id))
}

# library(ggrepel)
# ggplot(data=data, aes(x=year_id, y=val, colour=id_name, group=id_name)) +
#   geom_line() +
#   geom_label_repel(aes(label = label), nudge_x = 1, na.rm = TRUE)
#   

# Make Line Plot--------------------
library(directlabels)  # for labels

LinePlot <- function(display_id_in, level_id_in, sex_id_in, metric_id_in, measure_id_in, show_top) {
  data <- FilterLine(display_id_in, level_id_in, sex_id_in, metric_id_in, measure_id_in, show_top) %>%
    mutate(label = ifelse(year_id == max(year_id), as.character(id_name), NA_character_))
  
  ylabel = paste(METRICS[[metric_id_in]]$name, MEASURES[[measure_id_in]]$name, sep=" of ")
  print(measure_id_in)
  ggplot(data=data, aes(x=factor(year_id), y=val, colour=id_name, group=id_name)) +
    geom_line() +
    scale_colour_discrete(guide = 'none') +  # Removes Legend
    ylab(ylabel) + xlab("Year") +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    #scale_x_continuous("year_id", labels = as.character(year_id), breaks = year_id) +
    scale_x_discrete(expand=c(0, 1)) +
    geom_dl(aes(label=id_name), method=list("last.bumpup"), cex=1.3, hjust=3) #list(dl.combine("first.points", "last.points"), cex = 0.8))
}

# Make Bar Plot--------------------
SHOW_TOP_BAR <- 15
BAR_WIDTH <- 0.9
BAR_PLOT_WIDTH_MULTIPLIER <- 1.2

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
