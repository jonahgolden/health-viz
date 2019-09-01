displayButtonInput <- function(id) {
  # Create a namespace function using the provided id
  ns <- NS(id)
  
  # The widget
  radioGroupButtons(
    ns("display"),
    label = "Display:",
    choices = c("Cause" = "cause", "Risk" = "risk"),
    selected = "cause",
    justified = TRUE,
    status = "primary"
  )
}

levelSliderInput <- function(id, min) {
  ns <- NS(id)
  sliderInput(
    ns("level"),
    label = h4("Level:"),
    min = min,
    max = 4,
    value = 3
  )
}

yearSliderInput <- function(id) {
  ns <- NS(id)
  sliderInput(
    ns("year"),
    label = h4("Year:"),
    min = min(VALID_YEARS),
    max = max(VALID_YEARS),
    value = max(VALID_YEARS),
    sep = "",
    step = 1
    # animate = animationOptions(interval = 3000)
  )
}

sexButtonInput <- function(id) {
  ns <- NS(id)
  radioGroupButtons(
    ns("sex"),
    label = h4("Sex:"),
    choices = c(
      "Male" = 1,
      "Female" = 2,
      "Both" = 3
    ),
    selected = 3,
    justified = TRUE,
    status = "primary"
  )
}

metricButtonInput <- function(id) {
  ns <- NS(id)
  radioGroupButtons(
    ns("metric"),
    label = h4("Metric:"),
    choices = c("#" = 1, "%" = 2, "Rate" = 3),
    selected = 1,
    justified = TRUE,
    status = "primary"
  )
}

measureSelectInput <- function(id) {
  ns <- NS(id)
  selectInput(
    ns("measure"),
    label = h4("Measure:"),
    choices = c("Deaths" = 1,
                "Disability Adjusted Life Years (DALYs)" = 2,
                "Years Lived with Disability (YLDs)" = 3,
                "Years of Life Lost (YLLs)" = 4),
    selected = 1)
}

showtopSliderInput <- function(id) {
  ns <- NS(id)
  sliderInput(
    ns("showtop"),
    label = h4("Show Top:"),
    min = 1,
    max = 10,
    value = 10
  )
}