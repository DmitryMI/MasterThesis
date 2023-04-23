get_vehicles_speed_table <- function(scalars){
  query_time <- "select Run, Module, Value as TotalTime from scalars where Name == 'totalTime'"
  table_time <- sqldf(query_time)
  
  query_distance <- "select Run, Module, Value as TotalDistance from scalars where Name == 'totalDistance'"
  table_distance <- sqldf(query_distance)
  
  query <- "SELECT table_time.Run, table_time.Module, (TotalDistance / TotalTime) AS Speed FROM table_time JOIN table_distance ON table_time.Run == table_distance.Run AND table_time.Module == table_distance.Module"
  table <- sqldf(query)
  return(table)
}

get_vehicle_speed_by_run_table <- function(vehicles_speed_table){
  query <- "select Run, AVG(Speed) as Speed from vehicles_speed_table group by Run"
  table <- sqldf(query)
  return(table)
}

get_vehicle_speed_by_itervars_table <- function(vehicle_speed_by_run_table, itervars_table, run_itervars_table) {
  itervars_str <- get_itervars_str(itervars_table)
  
  query <- stringr::str_interp("SELECT vehicle_speed_by_run_table.Run, Speed, Repetition, ${itervars_str} from vehicle_speed_by_run_table JOIN run_itervars_table ON vehicle_speed_by_run_table.Run == run_itervars_table.Run")
  
  table <- sqldf(query)
  return(table)
}

get_vehicle_speed_by_itervars_avg_table <- function(vehicle_speed_by_itervars_table, itervars_table) {
  itervars_str <- get_itervars_str(itervars_table)
  
  query <- stringr::str_interp("SELECT AVG(Speed) as Speed, ${itervars_str} from vehicle_speed_by_itervars_table GROUP BY ${itervars_str}")
  print(query)
  table <- sqldf(query)
  
  return(table)
}