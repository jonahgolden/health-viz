library(dplyr)
library(magrittr)
library(shiny)
library(shinyWidgets)
library(ggplot2)

library(shinyjs)
library(shinydashboard)

# Line
library(ggrepel) # for labels
library(grid) # for clipping
# library(ggiraph)  # interactive

# Risk By Cause
library(plotly)

# Constants-----------------------------------------------------------------------
SIDE_BAR_PANEL_WIDTH <- 4
PURPLE <- "#8F98B5"
RED <- "#E9A291"
LIGHT_BLUE <- "#8ECAE3"
TAN <- "#E6C8A0"

VALID_YEARS <- c(1990:2017)
DEATH_ID <- 1
DALY_ID<- 2
YLD_ID <- 3
YLL_ID <- 4
MEASURES <- list(
  "1" = list(name = "Deaths", color = PURPLE, short_name = "Deaths"),
  "2" = list(name = "Disability-Adjusted Life Years", color = RED, short_name = "DALYs"),
  "3" = list(name = "Years Lived with Disability", color = LIGHT_BLUE, short_name = "YLDs"),
  "4" = list(name = "Years of Life Lost", color = TAN, short_name = "YLLs")
)
METRICS <- list(
  "1" = list(name = "Number", symbol = "#"),
  "2" = list(name = "Percent", symbol = "%"),
  "3" = list(name = "Rate (per 100,000)", symbol = "Rate")
)
SEXES <- list(
  "1" = list(name = "Males"),
  "2" = list(name = "Females"),
  "3" = list(name = "Both sexes")
)

# Load Data-----------------------------------------------------------------------
ihme2017Data <- readRDS("data/ihme-2017-v2.RDS") %>%
  subset(., year_id >= min(VALID_YEARS))

riskByCauseData <- readRDS("data/risk-by-cause.RDS")


# Source functions ----------------------------------------------------------------------
source("functions/uiOptions.R")  # For the UI
source("functions/generalFunctions.R")  # Functions used by multiple tabs
source("functions/barFunctions.R")  # Functions for tab 1
source("functions/lineFunctions.R")  # Functions for tab 2
source("functions/riskByCauseFunctions.R")  # Functions for tab 3
source("data/color-palette.R")  # Color palette for risk by cause bars


