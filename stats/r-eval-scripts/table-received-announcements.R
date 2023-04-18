require(sqldf)

get_received_announcements_table <- function(scalars){
  query <- "select Run, Module, Value as ReceivedAnnouncements from scalars where Name == 'receivedJammingAnnouncementsNum'"
  table <- sqldf(query)
  return(table)
}

get_received_announcements_by_run_table <- function(get_received_announcements_table){
  query <- "select Run, AVG(ReceivedAnnouncements) as ReceivedAnnouncements from get_received_announcements_table GROUP BY Run"
  table <- sqldf(query)
  return(table)
}

# f(X0, X1, X2, ..., Xn, Repetition)
get_received_announcements_by_itervars_table <- function(received_by_run_table, itervars_table, run_itervars_table) {
  itervars_str <- get_itervars_str(itervars_table)
  
  query <- stringr::str_interp("SELECT received_by_run_table.Run, ReceivedAnnouncements, Repetition, ${itervars_str} from received_by_run_table JOIN run_itervars_table ON received_by_run_table.Run == run_itervars_table.Run")
  
  table <- sqldf(query)
  return(table)
}

# f(X0, X1, X2, ..., Xn)
get_received_announcements_by_itervars_avg_table <- function(received_by_itervars_table, itervars_table) {
  itervars_str <- get_itervars_str(itervars_table)

  query <- stringr::str_interp("SELECT AVG(ReceivedAnnouncements) as ReceivedAnnouncements, ${itervars_str} from received_by_itervars_table GROUP BY ${itervars_str}")
  print(query)
  table <- sqldf(query)
  
  return(table)
}