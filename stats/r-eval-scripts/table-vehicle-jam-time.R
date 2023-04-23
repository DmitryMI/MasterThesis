get_vehicles_jam_time_table <- function(scalars){
  query <- "select Run, Module, Value as TotalTimeInJam from scalars where Name == 'totalTimeInJam'"
  table <- sqldf(query)
  return(table)
}

get_vehicles_jam_time_by_run_table <- function(vehicles_jam_time_table){
  query <- "select Run, AVG(TotalTimeInJam) as TotalTimeInJam from vehicles_jam_time_table group by Run"
  table <- sqldf(query)
  return(table)
}

get_vehicles_jam_time_by_itervars_table <- function(vehicles_jam_time_by_run_table, itervars_table, run_itervars_table) {
  itervars_str <- get_itervars_str(itervars_table)
  
  query <- stringr::str_interp("SELECT vehicles_jam_time_by_run_table.Run, TotalTimeInJam, Repetition, ${itervars_str} from vehicles_jam_time_by_run_table JOIN run_itervars_table ON vehicles_jam_time_by_run_table.Run == run_itervars_table.Run")
  
  table <- sqldf(query)
  return(table)
}

get_jam_time_by_itervars_avg_table <- function(vehicles_jam_time_by_itervars_table, itervars_table) {
  itervars_str <- get_itervars_str(itervars_table)
  
  query <- stringr::str_interp("SELECT AVG(TotalTimeInJam) as TotalTimeInJam, ${itervars_str} from vehicles_jam_time_by_itervars_table GROUP BY ${itervars_str}")
  print(query)
  table <- sqldf(query)
  
  return(table)
}