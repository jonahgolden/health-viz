#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

shinyServer(function(input, output) {
  
  # Bar Plots ---------------------------------
  FilteredBar <- reactive({
    return(FilterBar(input$display, input$level, input$year, input$sex, input$metric))
  })
  output$deathBar <- renderPlot({
    BarPlot(FilteredBar(), DEATH_ID)
  })
  output$dalyBar <- renderPlot({
    BarPlot(FilteredBar(), DALY_ID)
  })
  output$yldBar <- renderPlot({
    BarPlot(FilteredBar(), YLD_ID)
  })
  output$yllBar <- renderPlot({
    BarPlot(FilteredBar(), YLL_ID)
  })
  
  # Line Plot ---------------------------------
  output$linePlot <- renderPlot({
    LinePlot(input$display_line, input$level_line, input$sex_line, input$metric_line, input$measure_line, input$show_top)
  })
})