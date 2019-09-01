source("modules/widgetModules.R")

normalUI <- function() {
  sidebarLayout(
    
    sidebarPanel(
      width = SIDE_BAR_PANEL_WIDTH,
      useShinyjs(),
      
      displayButtonInput(),
      wellPanel(
        levelSliderInput(),
        yearSliderInput(),
        showtopSliderInput(),
        sexButtonInput(),
        metricButtonInput(),
        measureSelectInput()
      )
    ),
    mainPanel(
      tabsetPanel(type = "tabs", id = "tab",
                  tabPanel("bars", fluid = TRUE, value = "bar",
                           fluidRow(
                             column(6, plotOutput("deathBar")),
                             column(6, plotOutput("dalyBar"))
                           ),
                           fluidRow(
                             column(6, plotOutput("yldBar")),
                             column(6, plotOutput("yllBar"))
                           )
                  ),
                  tabPanel("line", fluid = TRUE, value = "line",
                           plotOutput("linePlot", height = 600)
                  )
      )
    )
  )
}

dashboardUI <- function() {
  dashboardPage(
    dashboardHeader(title = "DASHBOARD"),

    dashboardSidebar(
      useShinyjs(),
      displayButtonInput(),
      levelSliderInput(),
      yearSliderInput(),
      showtopSliderInput(),
      sexButtonInput(),
      metricButtonInput(),
      measureSelectInput()
    ),

    dashboardBody(
      tabsetPanel(type = "tabs", id = "tab",
                  tabPanel("bars", fluid = TRUE, value = "bar",
                    fluidRow(
                      column(6, plotOutput("deathBar")),
                      column(6, plotOutput("dalyBar"))
                      ),
                    fluidRow(
                      column(6, plotOutput("yldBar")),
                      column(6, plotOutput("yllBar"))
                      )
                    ),
                  tabPanel("line", fluid = TRUE, value = "line",
                    plotOutput("linePlot", height = 600)
                  )
                  )
    )
  )
}