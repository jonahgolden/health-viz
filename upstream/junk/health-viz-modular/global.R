library(dplyr)
library(magrittr)
library(shiny)
library(shinyWidgets)
library(ggplot2)
library(plotly)

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

# MODULES----------------------------------------------------------------------
BAR_TAB_ID <- "bars"
LINE_TAB_ID <- "lines"
source("modules/serverModules.R")

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

# Make Line Plot--------------------
library(ggrepel) # for labels
library(grid) # for clipping
# library(ggiraph)  # interactive

LinePlot <- function(display_id_in, level_id_in, sex_id_in, metric_id_in, measure_id_in, show_top) {
  data <- FilterLine(display_id_in, level_id_in, sex_id_in, metric_id_in, measure_id_in, show_top) %>%
    mutate(label = ifelse(year_id == max(year_id), as.character(id_name), NA_character_))
  
  ylabel <- stringr::str_wrap(paste(METRICS[[metric_id_in]]$name, MEASURES[[measure_id_in]]$short_name, sep=" of "), 5)
  years <- unique(data$year_id)
  
  p <- ggplot(data=data, aes(x=year_id, y=val, colour=id_name, group=id_name)) +
    geom_line() + labs(title = "Some Informative Title", x = "Year", y = ylabel) +
    geom_text_repel(data = subset(data, year_id==2017), lineheight = 0.7, hjust = 0, size = 4, fontface = "bold",
              aes(label = stringr::str_wrap(id_name, 20)),  # colour = factor(id_name)),
              xlim = c(2018, 2030), ylim = c(-Inf, max(data$val)),
              segment.size = 0.5 , box.padding = 0.5, # segment.color = "black",
              direction = "y",  # Only allow labels to move in y direction
              nudge_y = max(data$val)/20  # aesthetic
              ) +
    scale_x_continuous(expand = c(0, 0), breaks = scales::pretty_breaks(n = length(years)/2)) +
    scale_y_continuous(breaks = scales::pretty_breaks(n = 10)) +
    scale_colour_discrete(guide = 'none') +  # Remove Legend
    theme_bw() +  # Remove background
    theme(plot.margin = unit(c(1,12,0,0), "lines"),
          axis.text.x = element_text(angle = 45, hjust = 1),  # Add margin for labels and top
          plot.title = element_text(size = 24, face = "bold"),
          axis.title.x = element_text(size = 16, face = "bold"),
          axis.title.y = element_text(angle = 0, vjust = 0.5, size = 16, face = "bold"))
  
  # Code to turn off clipping
  gt <- ggplotGrob(p)
  gt$layout$clip[gt$layout$name == "panel"] <- "off"
  grid.draw(gt)
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





# --- Line Plot Labels with directlabels
# library(directlabels)  # for labels
# p <- ggplot(data=data, aes(x=year_id, y=val, colour=id_name, group=id_name)) +
#   geom_line() +
#   #coord_fixed(0.001) +
#   scale_colour_discrete(guide = 'none') +  # Removes Legend
#   ylab(ylabel) + xlab("Year") +
#   theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
#   scale_x_continuous(expand = c(0, 0)) +
#   geom_dl(aes(label=stringr::str_wrap(id_name, 20)), method=list(dl.trans(x = x + .3, y = y - .1), "last.bumpup", cex=1)) +
#   theme_bw() +
#   theme(plot.margin = unit(c(1,9,1,1), "lines"))
# 
# # Code to turn off clipping
# gt1 <- ggplotGrob(p)
# gt1$layout$clip[gt1$layout$name == "panel"] <- "off"
# grid.draw(gt1)
