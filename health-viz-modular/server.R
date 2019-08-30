#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

shinyServer(function(input, output, session) {
  # Modular Bar Values
  myBarModules <- callModule(barModules, BAR_TAB_ID)
  
  # Bar Plots ---------------------------------
  FilteredBar <- reactive({
    return(FilterBar(myBarModules$display(),
                     myBarModules$level(),
                     myBarModules$year(),
                     myBarModules$sex(),
                     myBarModules$metric()))
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
  myLineModules <- callModule(lineModules, LINE_TAB_ID)
  output$linePlot <- renderPlot({
    LinePlot(myLineModules$display(),
             myLineModules$level(),
             myLineModules$sex(),
             myLineModules$metric(),
             myLineModules$measure(),
             myLineModules$showtop()
             )
    })
  # output$linePlot <- renderPlot({
  #   LinePlot(input$display_line, input$level_line, input$sex_line, input$metric_line, input$measure_line, input$show_top)
  # })
})