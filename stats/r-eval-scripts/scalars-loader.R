require(readr)

load_scalars <- function(csv_name) {
  cols <-cols(
    run = col_character(),
    type = col_character(),
    module = col_character(),
    name = col_character(),
    attrname = col_character(),
    attrvalue = col_character(),
    value = col_double()
  )
  
  scalars <- read_csv(csv_name, col_types = cols)
  return(scalars)
}