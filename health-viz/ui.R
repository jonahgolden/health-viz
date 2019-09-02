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
  
  # Use one or the other. Defined in functions/uiOptions.R
  normalUI()
  #dashboardUI()
))
