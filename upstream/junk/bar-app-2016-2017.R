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
data2016 <- readRDS("../upstream/data/ihme-2016-v2.RDS") %>%
  subset(., year_id >= min(VALID_YEARS))
data2017 <- readRDS("../upstream/data/ihme-2017-v2.RDS") %>%
  subset(., year_id >= min(VALID_YEARS))

risk_years_2016 <- sort(unique(data2016[data2016$display == 'risk', "year_id"]))
cause_years_2016 = sort(unique(data2016[data2016$display == 'cause', "year_id"]))
risk_years_2017 <- sort(unique(data2017[data2017$display == 'risk', "year_id"]))
cause_years_2017 = sort(unique(data2017[data2017$display == 'cause', "year_id"]))

# Functions-----------------------------------------------------------------------
filter1 <- function(display_id_in, level_id_in, year_id_in, sex_id_in, metric_id_in, estimate_year_in) {
  if (estimate_year_in == 2016) {
    data <- data2016
  } else {
    data <- data2017
  }
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

# UI---------------------------------------------------------------------------
ui <- fluidPage(
  tags$style(
    ".irs-bar {",
    "  border-color: transparent;",
    "  background-color: transparent;",
    "}",
    ".irs-bar-edge {",
    "  border-color: transparent;",
    "  background-color: transparent;",
    "}"
  ),
  sidebarLayout(
    # Inputs
    sidebarPanel(width=4,
                 
                 radioGroupButtons("display",
                                   label = h4("Display:"),
                                   choices = c("Cause" = "cause", "Risk" = "risk"),
                                   selected = "cause",
                                   justified = TRUE, status = "primary"),
                 
                 sliderInput("level",
                             label = h4("Level:"),
                             min = 2,
                             max = 4,
                             value = 3),
                 
                 conditionalPanel(
                   condition = "input.estimates == 2017 && input.display == 'cause'",
                   sliderTextInput("years",
                                   label = h4("Year:"),
                                   choices = cause_years_2017,
                                   selected = max(cause_years_2017))
                 ),
                 conditionalPanel(
                   condition = "input.estimates == 2017 && input.display == 'risk'",
                   sliderTextInput("years",
                                   label = h4("Year:"),
                                   choices = risk_years_2017,
                                   selected = max(risk_years_2017))
                 ),
                 conditionalPanel(
                   condition = "input.estimates == 2016 && input.display == 'cause'",
                   sliderTextInput("years",
                                   label = h4("Year:"),
                                   choices = cause_years_2016,
                                   selected = max(cause_years_2016))
                 ),
                 conditionalPanel(
                   condition = "input.estimates == 2016 && input.display == 'risk'",
                   sliderTextInput("years",
                                   label = h4("Year:"),
                                   choices = risk_years_2016,
                                   selected = max(risk_years_2016))
                 ),
                #  #wellPanel(
                #    conditionalPanel(
                #      condition = "input.estimates == 2017 && input.display == 'cause'",
                #      sliderInput("year",
                #                  label = h4("Year:"),
                #                  min = min(cause_years_2017),
                #                  max = max(cause_years_2017),
                #                  value = max(cause_years_2017),
                #                  sep = "", step = 1)   # animate = animationOptions(interval = 3000)
                #    ),
                # # ),
                 
                 radioGroupButtons("sex",
                                   label = h4("Sex:"), 
                                   choices = c("Male" = 1, "Female" = 2, "Both" = 3),
                                   selected = 3,
                                   justified = TRUE, status = "primary"),
                 
                 radioGroupButtons("metric",
                                   label = h4("Metric:"), 
                                   choices = c("#" = 1, "%" = 2, "Rate" = 3),
                                   selected = 1,
                                   justified = TRUE, status = "primary"),
                 
                 radioGroupButtons("estimates",
                                   label = h4("IHME Estimate Year:"), 
                                   choices = c("2016" = 2016, "2017" = 2017),
                                   selected = 2017,
                                   justified = TRUE, status = "primary")
    ),
    mainPanel(
      fluidRow(
        column(6, plotOutput("deathBar")),
        column(6, plotOutput("dalyBar"))
      ),
      fluidRow(
        column(6, plotOutput("yldBar")),
        column(6, plotOutput("yllBar"))
      )
    )
  )
)

# Server---------------------------------------------------------------------------
server <- function(input, output, session) {
  
  fd <- reactive({
    filter1(input$display, input$level, input$years, input$sex, input$metric, input$estimates)
  })
  
  output$deathBar <- renderPlot({
    bar_plot(filter2(fd(), DEATH_ID), DEATH_ID)
  })
  
  output$dalyBar <- renderPlot({
    bar_plot(filter2(fd(), DALY_ID), DALY_ID)
  })
  
  output$yldBar <- renderPlot({
    bar_plot(filter2(fd(), YLD_ID), YLD_ID)
  })
  
  output$yllBar <- renderPlot({
    bar_plot(filter2(fd(), YLL_ID), YLL_ID)
  })
}

shinyApp(ui = ui, server = server)


# observeEvent({
#   input$estimates
#   input$display},
#   {
#     years <- switch(input$estimates,
#                    "2016" = ifelse(input$display == "cause", cause_years_2016, risk_years_2016),
#                    # switch(input$display,
#                    #               "cause" = cause_years_2016,
#                    #               "risk" = risk_years_2016),
#                    "2017" = ifelse(input$display == "cause", cause_years_2017, risk_years_2017)
#                      # switch(input$display,
#                      #             "cause" = cause_years_2017,
#                      #             "risk" = risk_years_2017)
#                    )
#     updateSliderTextInput(
#       session = session,
#       inputId = "years",
#       choices = years,
#       selected = max(years)
#     )
#   }, ignoreInit = TRUE)