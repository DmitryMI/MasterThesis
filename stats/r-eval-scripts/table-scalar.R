get_scalar_table <- function(scalars, param_name){
  query <- stringr::str_interp("select Run, Module, Value as ${param_name} from scalars where Name == '${param_name}'")
  print(query)
  table <- sqldf(query)
  return(table)
}

get_scalar_by_run_table <- function(scalar_table, param_name){
  query <- stringr::str_interp("select Run, AVG(${param_name}) as ${param_name} from scalar_table group by Run")
  table <- sqldf(query)
  return(table)
}

get_scalar_by_itervars_table <- function(scalar_by_run, itervars_table, run_itervars_table, param_name) {
  itervars_str <- get_itervars_str(itervars_table)
  query <- stringr::str_interp("SELECT scalar_by_run.Run, ${param_name}, Repetition, ${itervars_str} from scalar_by_run JOIN run_itervars_table ON scalar_by_run.Run == run_itervars_table.Run")
  table <- sqldf(query)
  return(table)
}

get_scalar_by_itervars_avg_table <- function(scalar_by_itervars, itervars_table, param_name) {
  itervars_str <- get_itervars_str(itervars_table)
  
  query <- stringr::str_interp("SELECT AVG(${param_name}) as ${param_name}, ${itervars_str} from scalar_by_itervars GROUP BY ${itervars_str}")
  print(query)
  table <- sqldf(query)
  
  return(table)
}