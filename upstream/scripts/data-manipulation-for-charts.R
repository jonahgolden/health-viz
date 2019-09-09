# Manipulating data sets for efficient use in app visualizations

# Extracting meta data for cause and risk ------------------------------------------
ihme2017Data <- readRDS("../data/ihme-2017-v2.RDS")

cause_info <- ihme2017Data[!duplicated(ihme2017Data[,'id_num']),] %>%
  subset(., display == 'cause') %>%
  select(id_num, id_name, sort_order, level, parent_id, first_parent) %>%
  'rownames<-'(seq_len(nrow(.))) %>%
  rename('cause_id' = 'id_num', 'cause_name' = 'id_name')

risk_info <- ihme2017Data[!duplicated(ihme2017Data[,'id_num']),] %>%
  subset(., display == 'risk') %>%
  select(id_num, id_name, sort_order, level, parent_id, first_parent) %>%
  'rownames<-'(seq_len(nrow(.))) %>%
  rename('risk_id' = 'id_num', 'risk_name' = 'id_name')

saveRDS(cause_info, file = "../data/meta/cause-info.RDS")
saveRDS(risk_info, file = "../data/meta/risk-info.RDS")

# Making data necessary for Risk By Cause chart ------------------------------------
CAUSE_LEVEL <- 2
UNECESSARY_FIELDS <- c("location_id", "age_group_id", "upper", "lower", "display")
# Only using level 2 causes
level2 <- subset(cause_info, level == 2)

# Full data set
riskByCauseData <- readRDS("../data/ihme-risks-by-cause-2017-v2.RDS") %>%
  subset(., cause_id %in% level2$cause_id) %>%  # Only using level 2 causes
  select(-one_of(UNECESSARY_FIELDS)) %>%  # Don't need these for now
  rename('risk_id' = 'id_num', 'risk_name' = 'id_name', 'first_risk_parent' = 'first_parent')

# Slower
getCause1 <- function(cause_id) {
  return(cause_info$cause_name[cause_info$cause_id == cause_id])
}

# 10 times faster
cause = character()
cause[cause_info$cause_id] <- cause_info$cause_name
getCause2 <- function(cause_id) {
  return(cause[[cause_id]])
}

risk_short_names <- readRDS("../data/meta/risk-meta.RDS") %>%
  select(risk_id, risk_short_name)

cause_first_parents <- cause_info %>%
  select(cause_id, first_parent) %>%
  rename('first_cause_parent' = 'first_parent')

# Add cause names, risk short names, and cause first parents to data
riskByCauseData <- riskByCauseData %>% mutate(cause_name = mapply(getCause2, cause_id)) %>%
  merge(., risk_short_names, by = "risk_id") %>%
  merge(., cause_first_parents, by = "cause_id") 

saveRDS(riskByCauseData, "../data/risk-by-cause.RDS")


# Speed Tests ------------------------------------------------------------------------
# test_size <- 500000
# test_data <- riskByCauseData[1:test_size,]
# start_time <- Sys.time()
# result_test <- test_data %>% mutate(cause_name = mapply(getCause2, cause_id))
# #riskByCauseData$cause_name <- mapply(getCause2, riskByCauseData$cause_id)
# #riskByCauseData %>% mutate(cause_name = mapply(getCause2, cause_id))
# total_time <- Sys.time() - start_time
# print(total_time)
# print(paste0("predicted total: ", total_time*(length(riskByCauseData[,1])/test_size)))
# 
# start_time <- Sys.time()
# result <- riskByCauseData %>% mutate(cause_name = mapply(getCause2, cause_id))
# total_time <- Sys.time() - start_time
# print(paste0("actual total: ", total_time))
