# Functions for different ui options.

# Load the widgets
source("functions/widgets.R")

normalUI <- function() {
  sidebarLayout(

    # Includes all widgets that appear in any tab.
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

    # Includes multiple tabs with values that represent them
  mainPanel(
    tabsetPanel(type = "tabs", id = "tab",

                # Risk By Cause tab
                tabPanel("Risks By Cause", fluid = TRUE, value = "riskByCause",
                         plotlyOutput("riskByCause", height = 600)),

                # Bar graphs tab
                tabPanel("Bars", fluid = TRUE, value = "bar",
                         fluidRow(
                           column(6, plotOutput("deathBar")),
                           column(6, plotOutput("dalyBar"))
                         ),
                         fluidRow(
                           column(6, plotOutput("yldBar")),
                           column(6, plotOutput("yllBar"))
                         )
                ),

                # Line graph tab
                tabPanel("Line", fluid = TRUE, value = "line",
                         plotOutput("linePlot", height = 600)
                )
    )
  )
  )
}

dashboardUI <- function() {
  dashboardPage(
    dashboardHeader(title = "Some Awesome Title"),

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
                  tabPanel("Risks By Cause", fluid = TRUE, value = "riskByCause",
                           plotlyOutput("riskByCause", height = 600)),
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