#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

shinyUI(fluidPage(
  # Application title
  # titlePanel("Old Faithful Geyser Data"),
  
  # Styles
  # So slider bar does not fill with color
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
  
  tabsetPanel(
    # Bar Panel---------------------------------
    tabPanel(
    "bars", fluid = TRUE,
    sidebarLayout(
      # Inputs
      sidebarPanel(
        width = SIDE_BAR_PANEL_WIDTH,
        
        radioGroupButtons(
          "display",
          label = h4("Display:"),
          choices = c("Cause" = "cause", "Risk" = "risk"),
          selected = "cause",
          justified = TRUE,
          status = "primary"
        ),
        
        wellPanel(
          sliderInput(
            "level",
            label = h4("Level:"),
            min = 2,
            max = 4,
            value = 3
          ),
          
          sliderInput(
            "year",
            label = h4("Year:"),
            min = min(VALID_YEARS),
            max = max(VALID_YEARS),
            value = max(VALID_YEARS),
            sep = "",
            step = 1
            # animate = animationOptions(interval = 3000)
          ),
          
          radioGroupButtons(
            "sex",
            label = h4("Sex:"),
            choices = c(
              "Male" = 1,
              "Female" = 2,
              "Both" = 3
            ),
            selected = 3,
            justified = TRUE,
            status = "primary"
          ),
          
          radioGroupButtons(
            "metric",
            label = h4("Metric:"),
            choices = c("#" = 1, "%" = 2, "Rate" = 3),
            selected = 1,
            justified = TRUE,
            status = "primary"
          )
        )
      ),
      mainPanel(fluidRow(
        column(6, plotOutput("deathBar")),
        column(6, plotOutput("dalyBar"))
      ),
      fluidRow(
        column(6, plotOutput("yldBar")),
        column(6, plotOutput("yllBar"))
      ))
    )
  )
  ,
  # Line Panel
  tabPanel(
    "line", fluid = TRUE,
    sidebarLayout(
      sidebarPanel(
        width = SIDE_BAR_PANEL_WIDTH,
        
        radioGroupButtons(
          "display_line",
          label = h4("Display:"),
          choices = c("Cause" = "cause", "Risk" = "risk"),
          selected = "cause",
          justified = TRUE,
          status = "primary"
        ),
        
        wellPanel(
          sliderInput(
            "level_line",
            label = h4("Level:"),
            min = 1,
            max = 4,
            value = 3
          ),
          
          radioGroupButtons(
            "sex_line",
            label = h4("Sex:"),
            choices = c(
              "Male" = 1,
              "Female" = 2,
              "Both" = 3
            ),
            selected = 3,
            justified = TRUE,
            status = "primary"
          ),
          
          radioGroupButtons(
            "metric_line",
            label = h4("Metric:"),
            choices = c("#" = 1, "%" = 2, "Rate" = 3),
            selected = 1,
            justified = TRUE,
            status = "primary"
          ),
          
          radioGroupButtons(
            "measure_line",
            label = h4("Measure:"),
            choices = c("Deaths" = 1, "DALYs" = 2, "YLDs" = 3, "YLLs" = 4),
            selected = 1,
            justified = TRUE,
            status = "primary"
          ),
          
          sliderInput(
            "show_top",
            label = h4("Show Top:"),
            min = 1,
            max = 10,
            value = 10
          )
        )
        
      ),
      mainPanel(
        plotOutput("linePlot", height = 600)
      )
    )
    )
  
  )
))
