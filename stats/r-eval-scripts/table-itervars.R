require(sqldf)

source("table-run-repetition.R")

# Prepares a table with columns:

get_itervars_table <- function(scalars){
  query <- "select distinct Attrname from scalars where Type == 'itervar'"
  table <- sqldf(query)
  return(table)
}

check_sanity_run_itervars_table <- function(run_itervars_table) {
  query <- "select distinct * from run_itervars_table"
  table <- sqldf(query)
  return(nrow(run_itervars_table) == nrow(table))
}

get_run_itervars_table <- function(scalars, itervars){
  repetition_table <- get_repetition_table(scalars)
  run_table <- sqldf("select * from scalars where Type == 'itervar'")
  # print(run_table)
  table <- NULL
  for(i in 1:nrow(itervars)) {
    itervar <- itervars[i,]
    itervar_query <- stringr::str_interp("select Run, attrvalue as ${itervar} from run_table where Type == 'itervar' and attrname == '${itervar}'")
    # print(itervar_query, end="\n")
    temp_table = sqldf(itervar_query)
    if (is.null(table))    {
      table <- temp_table
    }else{
      table <- merge(table, temp_table, by="run", all = TRUE)
    }
  }
  
  table <- merge(table, repetition_table, by="run", all = TRUE)
  
  return(table)
}