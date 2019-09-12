# User-interface

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

  
  # Use one or the other. Defined in functions/uiOptions.R
  #normalUI()
  #dashboardUI()
))
