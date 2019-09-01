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
  
  tabsetPanel(
    # Bar Panel---------------------------------
    tabPanel(
    "bars", fluid = TRUE,
    sidebarLayout(
      # Inputs
      sidebarPanel(
        width = SIDE_BAR_PANEL_WIDTH,
        
        # Using UI modules
        displayButtonInput(BAR_TAB_ID),
        
        wellPanel(
          levelSliderInput(BAR_TAB_ID, min = 2),
          yearSliderInput(BAR_TAB_ID),
          sexButtonInput(BAR_TAB_ID),
          metricButtonInput(BAR_TAB_ID)
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
        
        displayButtonInput(LINE_TAB_ID),
        
        wellPanel(
          levelSliderInput(LINE_TAB_ID, min = 1),
          sexButtonInput(LINE_TAB_ID),
          metricButtonInput(LINE_TAB_ID),
          measureSelectInput(LINE_TAB_ID),
          showtopSliderInput(LINE_TAB_ID)
        )
        
      ),
      mainPanel(
        plotOutput("linePlot", height = 600)
      )
    )
    )
  
  )
))
