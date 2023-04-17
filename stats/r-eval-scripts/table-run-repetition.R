require(sqldf)

# Prepares a table with columns:

get_repetition_table <- function(scalars){
  repetition_query <- "select Run, Attrvalue as Repetition from scalars where Type == 'runattr' and Attrname == 'repetition'"
  repetition_table <- sqldf(repetition_query)
  # print(head(repetition_table, 10))
  return(repetition_table)
}

get_run_table <- function(scalars){
  repetition_table <- get_repetition_table(scalars)
  number_of_drones_query <- "select Run, CAST(Attrvalue as integer) as NumberOfDrones from scalars where Type == 'itervar' and Attrname == 'NumberOfDrones'"
  
  number_of_drones_table <- sqldf(number_of_drones_query)
  run_description_query <- "select number_of_drones_table.Run as Run, Repetition, NumberOfDrones from number_of_drones_table inner join repetition_table on number_of_drones_table.Run == repetition_table.Run"
  run_description_table <- sqldf(run_description_query)
  
  return(run_description_table)
}