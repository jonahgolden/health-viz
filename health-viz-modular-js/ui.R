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
  
  # Use one or the other. Defined in modules/uiModuleOptions.R
  #normalUI()
  dashboardUI()
))
