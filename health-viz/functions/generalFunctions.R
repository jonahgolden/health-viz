# Functions used by multiple tabs

GetTop <- function(data, keep_top_number) {
  ranked_data <- data %>%
    mutate(rank = rank(-val, ties.method = 'first')) %>%
    filter(rank <= keep_top_number)
  return(ranked_data)
}