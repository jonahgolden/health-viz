#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  fd <- reactive({
    filter1(input$display, input$level, input$year, input$sex, input$metric)
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
})