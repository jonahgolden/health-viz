# Functions for the line chart (tab 2)

# Function to filter data for line chart
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
  
  return(list(
    data = (filtered_data %>% 
              filter(id_num %in% top_years$id_num) %>%
              arrange(id_num, year_id)),
    ylabel = stringr::str_wrap(paste(METRICS[[metric_id_in]]$name, MEASURES[[measure_id_in]]$short_name, sep=" of "), 13),
    title = paste0("Top ", show_top, ifelse(display_id_in == "cause", " Causes ", " Risks "), "in California (1990-2017)")
  )
  )
}

# Function to make line chart
LinePlot <- function(filteredData) {
  data <- filteredData$data %>%
    mutate(label = ifelse(year_id == max(year_id), as.character(id_name), NA_character_))
  ylabel <- filteredData$ylabel
  title <- filteredData$title
  years <- unique(data$year_id)
  
  p <- ggplot(data=data, aes(x=year_id, y=val, colour=id_name, group=id_name)) +
    geom_line() + labs(title = title, x = "Year", y = ylabel) +
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
          plot.title = element_text(size = 20, face = "bold"),
          axis.title.x = element_text(size = 16, face = "bold"),
          axis.title.y = element_text(angle = 0, vjust = 0.5, size = 16, face = "bold"))
  
  # Code to turn off clipping
  gt <- ggplotGrob(p)
  gt$layout$clip[gt$layout$name == "panel"] <- "off"
  grid.draw(gt)
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
