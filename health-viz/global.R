library(dplyr)
library(magrittr)
library(shiny)
library(shinyWidgets)
library(ggplot2)

# Constants-----------------------------------------------------------------------
VALID_YEARS <- c(1990:2017)
DEATH_ID <- 1
DALY_ID <- 2
YLD_ID <- 3
YLL_ID <- 4
SHOW_TOP <- 15
BAR_WIDTH <- 0.9
PLOT_WIDTH_MULTIPLIER <- 1.2

# Data-----------------------------------------------------------------------
data <- readRDS("../upstream/data/ihme-2017-v2.RDS") %>%
  subset(., year_id >= min(VALID_YEARS))

# Functions-----------------------------------------------------------------------
filter1 <- function(display_id_in, level_id_in, year_id_in, sex_id_in, metric_id_in) {
  data %>% filter(display == display_id_in,
                  grepl(level_id_in, level),
                  year_id == year_id_in,
                  sex_id == sex_id_in,
                  metric_id == metric_id_in)
}

filter2 <- function(f1_output, measure_id_in) {
  f1_output %>%
    filter(measure_id == measure_id_in) %>%
    mutate(rank = rank(-val, ties.method = 'first')) %>%
    filter(rank <= SHOW_TOP)
}

bar_plot <- function(filtered, measure) {
  plot_width <- max(filtered$val)*PLOT_WIDTH_MULTIPLIER
  percent_sign <- switch(filtered$metric[1],
                         "",
                         "%")
  plot_title <- switch(measure,
                       "Deaths",
                       "Disability-Adjusted Life Years",
                       "Years Lived with Disability",
                       "Years of Life Lost")
  color <- switch(measure,
                  "#8F98B5",
                  "#E9A291",
                  "#8ECAE3",
                  "#E6C8A0")
  
  ggplot(data=filtered, aes(x=reorder(id_name, val),y=val)) +
    coord_flip() +
    geom_bar(position="dodge", stat="identity", width=BAR_WIDTH, fill=color) + 
    geom_text(hjust=0, aes(x=id_name, y=0, label=paste0(" ", rank, ". ", id_name))) +
    annotate(geom="text", hjust=1, x=filtered$id_name, y=plot_width, label=paste0(filtered$val, percent_sign)) +
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

