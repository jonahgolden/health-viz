library(dplyr)
library(jsonlite)
library(docstring)
options(stringsAsFactors=FALSE)
options(max.print = 500)

# Define options-----------------------------------------------------------------------
api_year <- 2017  # 2017 or 2016. GBD 2016 estimates vs GBD 2017 estimates
api_version <- 2  # Only use 2 (1 is depracated)
single_multi <- "single"  # for single-year data vs. cross-year data – version 2’s bigger than version 1
risks_by_cause <- TRUE  # If true, gets all causes for each risk, if false just gets 294 (all causes)
risk_cause <- ifelse(risks_by_cause, "risks-by-cause-", "")
output_file <- paste0("../data/", "ihme-", risk_cause, api_year, "-v", api_version, ".RDS")

risk <- TRUE  # TODO: make these useful, and include other types
cause <- TRUE

# IHME API key, root, and subsets-----------------------------------------------------------------------

ihme_key <- "5a4fc200e1af720001c84cf91e34303eca334ffa8a35722aac008232"
key_text <- paste0("authorization=",ihme_key)

api_root <- paste0("https://api.healthdata.org/healthdata/v", api_version, "/")
cause_subset <- paste0("data/gbd/", api_year, "/cause/", single_multi, "/?")
risk_subset <- paste0("data/gbd/", api_year, "/risk/", single_multi, "/?")

cause_meta_subset <- "metadata/cause/?cause_set_id=3"
risk_meta_subset <- "metadata/risk/?risk_set_id=1"

# Define functions-----------------------------------------------------------------------

# Get Data functions-------------------

make_url <- function(subset, measure_id, year_id="", location_id=527, sex_id, age_group_id=22, metric_id, risk_id="", cause_id="") {
  #' Make URL for cause endpoint. Two degrees of freedom for every endpoint means that you can 
  #' leave up to two dimensions unspecified and you will get all data from them.
  return(paste0(api_root, subset,
                "&measure_id=", measure_id,
                "&year_id=", year_id,
                "&location_id=", location_id,
                "&sex_id=", sex_id,
                "&age_group_id=", age_group_id,
                "&metric_id=", metric_id,
                "&risk_id=", risk_id,  # Only specify risk_id if using a risk_subset
                "&cause_id=", cause_id,
                "&", key_text))
}

make_data_subset <- function(URL){
  #' Inputs: URL, Optional: measure_id, cause_id1, cause_id2
  #' Output: data frame of json data call

  data <- jsonlite::fromJSON(paste0(URL))
  colnames(data$data) <- data$meta$fields
  return(as.data.frame(data$data))
}

# after for loop-------------------

parent_recursive <- function(row, df) {
  if (row[,'level'] == 0) {
    return('0')
  } else if (row[,'level'] == 1) {
    return(row[,'id_name'])
  } else {
    parent_recursive(df[which(df[,'id_num'] == row[,'parent_id']), ], df)
  }
}

merge_with_parent <- function(value_data, meta_subset) {
  #'Input: value_data as created by make_data_subset function
  #'Output: data frame of value_data, now including parent data
  #'Parent Data Fields: cause_id, cause_name, acause, sort_order, level, parent_id
  #'cause_set_id is basically level?
  parent  <- jsonlite::fromJSON(paste0(api_root, meta_subset,"&",key_text))
  colnames(parent$data) <- parent$meta$fields
  parent <- as.data.frame(parent$data) %>%
    rename('id_num' = 1, 'id_name' = 2, 'display' = 3)
  
  if (meta_subset == risk_meta_subset) {
    parent[2,'id_name'] <- 'Environmental/ occupational risks'
  }
  for (row in 1:nrow(parent)) {  # Use apply() here?
    parent[row, 'first_parent'] <- parent_recursive(parent[row,], parent)
  }
  parent <- parent %>%
    mutate(level = ifelse(id_num %in% setdiff(id_num, parent_id) & level == 2, paste(2,3,4, sep =","),
                          ifelse(id_num %in% setdiff(id_num, parent_id) & level == 3, paste(3,4, sep=","), level)))
  return(merge(value_data, parent, by='id_num'))
}

make_numeric <- function(df) {
  cols.num <- c(1:11, 14, 16)
  df[cols.num] <- sapply(df[cols.num], as.numeric)
  df[df$metric_id == 1, 9:11] <- round(df[df$metric_id == 1, 9:11])         # Round number to 0 decimal
  df[df$metric_id == 2, 9:11] <- round(df[df$metric_id == 2, 9:11]*100, 1)  # Multiply Percent by 100, round to 1 decimal
  df[df$metric_id == 3, 9:11] <- round(df[df$metric_id == 3, 9:11]*100000)  # Multiply Rate by 100,000, round to 0 decimal
  return(df)
}


# Load and format data-----------------------------------------------------------------------
# make_url() defaults: subset=cause_subset2017, measure_id="", year_id="", location_id=527,
#                      sex_id="", age_group_id=22, metric_id="", risk_id="", cause_id=""

# get_data <- function(set) {
#   if (set == "risk") {
#     subset <- risk_subset
#     cause <- 294
#   } else if (set == "cause") {
#     subset <- cause_subset
#     cause <- ""
#   }
#   start_time <- Sys.time()
#   big_data <- data.frame()
#   for (m in 1:4) {
#     for (s in 1:3) {
#       for (n in 1:3) {
#         url <- make_url(subset = subset, measure_id = m, sex_id = s, metric_id = n, cause_id = cause)
#         little_data <- make_data_subset(url)
#         big_data <- rbind(big_data, little_data)
#       }
#     }
#   }
#   rm(little_data)
#   total_time <- Sys.time() - start_time
#   print(total_time)
#   return(big_data)
# }

get_data <- function(set) {
  if (set == "risk") {
    subset <- risk_subset
    cause <- ifelse(risks_by_cause, "", 294)
  } else if (set == "cause") {
    subset <- cause_subset
    cause <- ""
  }
  start_time <- Sys.time()
  big_data <- data.frame()
  for (m in 1:4) {
    for (s in 1:3) {
      for (n in 1:3) {
        for (y in 1990:2017) {
          url <- make_url(subset = subset,measure_id = m,year_id = y,sex_id = s,metric_id = n,cause_id = cause)
          little_data <- make_data_subset(url)
          big_data <- rbind(big_data, little_data)
        }
      }
    }
  }
  rm(little_data)
  total_time <- Sys.time() - start_time
  print(total_time)
  return(big_data)
}

# Cause Data
raw_cause_data <- get_data("cause")
cause_data <- raw_cause_data %>%
  rename('id_num' = 'cause_id') %>%
  merge_with_parent(value_data = ., meta_subset = cause_meta_subset) %>%
  mutate(display = 'cause') %>%
  make_numeric()

# Risk Data
raw_risk_data <- get_data("risk")
risk_data <- raw_risk_data %>%
  rename('id_num' = 'risk_id') %>% # Could change to id_name = risk_short_name
  merge_with_parent(value_data = ., meta_subset = risk_meta_subset) %>%
  mutate(display = 'risk') %>%
  #select(-cause_id) %>%
  make_numeric()

# # Save data-----------------------------------------------------------------------
# output <- bind_rows(cause_data, risk_data)
saveRDS(risk_data, file = output_file)








# Previous Get Data Method -----------------------------------------------------------------------
# get_data <- function(cause) {
#   start_time <- Sys.time()
#   big_data <- data.frame()
#   for (m in 1:4) {
#     for (s in 1:3) {
#       for (n in 1:3) {
#         if (cause) {
#           url <- make_url(subset = cause_subset2017, measure_id = m, sex_id = s, metric_id = n)
#         } else {
#           url <- make_url(subset = risk_subset2017, measure_id = m, sex_id = s, metric_id = n, cause_id = 294)
#         }
#         little_data <- make_data_subset(url)
#         big_data <- rbind(big_data, little_data)
#       }
#     }
#   }
#   rm(little_data)
#   total_time <- Sys.time() - start_time
#   print(total_time)
#   return(big_data)
# }

# raw_cause_data <- get_data(cause = TRUE)
# raw_risk_data <- get_data(cause = FALSE)

# # visualize smoking data-----------------------------------------------------------------------

# url2 <- make_url(subset = risk_subset2017, risk_id = 99, age_group_id = 22, metric_id = 1, measure_id = 1, sex_id = 3)
# smoking_2017_risk <- make_data_subset(url2)
# 
# url3 <- make_url(subset = risk_subset2016, risk_id = 99, age_group_id = 22, metric_id = 1, measure_id = 1, sex_id = 3)
# smoking_2016_risk <- make_data_subset(url3)
# 
# 
# plot(smoking_2016_risk$year_id, smoking_2016_risk$val, type = "b", col = "blue",
#      xlim = c(1990, 2018), ylim=c(30000, 60000),
#      main = "Smoking Risk", xlab = "Number Deaths", ylab = "year")
# lines(smoking_2017_risk$year_id, smoking_2017_risk$val, type = "p", col = "red")
# legend("topright", legend=c("2016 Data", "2017 Data"),
#        col = c("blue", "red"), lty = 1)

