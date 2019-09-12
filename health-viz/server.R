# Server

shinyServer(function(input, output, session) {
  # Widgets -------------------
  observe({
    if(input$tab == "bar") {
      show("display")
      show("level")
      show("year")
      show("sex")
      show("metric")
      hide("measure")
      hide("showtop")
    } 
    if(input$tab == "line") {
      show("display")
      show("level")
      hide("year")
      show("sex")
      show("metric")
      show("measure")
      show("showtop")
    }
    if(input$tab == "riskByCause") {
      hide("display")
      show("level")
      show("year")
      show("sex")
      show("metric")
      show("measure")
      hide("showtop")
    }
  })
  
  # Bar -------------------
  FilteredBar <- reactive({
    return(FilterBar(input$display,
                     input$level,
                     input$year,
                     input$sex,
                     input$metric))
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
  
  # Line -------------------
  FilteredLine <- reactive({
    return(FilterLine(input$display,
                      input$level,
                      input$sex,
                      input$metric,
                      input$measure,
                      input$showtop))
  })
  output$linePlot <- renderPlot({
    LinePlot(FilteredLine())
  })
  
  # RiskByCause -------------------
  FilteredRiskByCause <- reactive({
    return(FilterRiskByCause(
      input$level,
      input$year,
      input$sex,
      input$metric,
      input$measure
    ))
  })
  output$riskByCause <- renderPlotly({
    RiskByCausePlot(FilteredRiskByCause())
  })
})