require(sqldf)

# Prepares a table with columns:

get_jammed_vehicles_table <- function(scalars){
  query <- "select Run, Module, Value as TotalTimeInJam from scalars where Name == 'totalTimeInJam' and Value > 0"
  table <- sqldf(query)
  return(table)
}

get_jammed_by_run_table <- function(jammed_vehicles_table){
  query <- "select Run, COUNT(Module) as JammedNumber from jammed_vehicles_table group by Run"
  table <- sqldf(query)
  return(table)
}

get_jammed_by_itervars_table <- function(jammed_by_run_table, itervars_table, run_itervars_table) {
  itervars_str <- itervars_table[1,]
  for(i in 2:nrow(itervars_table)) {
    itervar <- itervars_table[i,]
    itervars_str <- paste(itervars_str, itervar, sep = ", ")
  }

  query <- stringr::str_interp("SELECT jammed_by_run_table.Run, JammedNumber, Repetition, ${itervars_str} from jammed_by_run_table JOIN run_itervars_table ON jammed_by_run_table.Run == run_itervars_table.Run")

  table <- sqldf(query)
  return(table)
}

get_jammed_by_itervars_avg_table <- function(jammed_by_itervars_table, itervars_table) {
  itervars_str <- itervars_table[1,]
  for(i in 2:nrow(itervars_table)) {
    itervar <- itervars_table[i,]
    itervars_str <- paste(itervars_str, itervar, sep = ", ")
  }
  
  query <- stringr::str_interp("SELECT AVG(JammedNumber) as JammedNumber, ${itervars_str} from jammed_by_itervars_table GROUP BY ${itervars_str}")
  print(query)
  table <- sqldf(query)
  
  return(table)
}