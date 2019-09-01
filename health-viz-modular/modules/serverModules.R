# Load file with individual widget modules
source("modules/uiModules.R")

# Bar server modules function
barModules <- function(input, output, session) {
  return(
    list(
      display = reactive({input$display}),
      level = reactive({input$level}),
      year = reactive({input$year}),
      sex = reactive({input$sex}),
      metric = reactive({input$metric})
    )
  )
}

# Line server modules function
lineModules <- function(input, output, session) {
  return(
    list(
      display = reactive({input$display}),
      level = reactive({input$level}),
      sex = reactive({input$sex}),
      metric = reactive({input$metric}),
      measure = reactive({input$measure}),
      showtop = reactive({input$showtop})
    )
  )
}