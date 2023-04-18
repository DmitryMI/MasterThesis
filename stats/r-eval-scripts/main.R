require(sqldf)
require(tools)
library("optparse")
library(ggplot2)

source("scalars-loader.R")
source("table-itervars.R")
source("table-jammed-vehicles.R")
source("table-received-announcements.R")

get_itervars_str <- function(itervars_table){
  itervars_str <- itervars_table[1,]
  for(i in 2:nrow(itervars_table)) {
    itervar <- itervars_table[i,]
    itervars_str <- paste(itervars_str, itervar, sep = ", ")
  }
  return(itervars_str)
}

get_itervars_prefixed_str <- function(itervars_table, prefix){
  itervars_str <- paste(prefix, ".", itervars_table[1,], sep="")
  for(i in 2:nrow(itervars_table)) {
    itervar <- paste(prefix, ".", itervars_table[i,], sep="")
    itervars_str <- paste(itervars_str, itervar, sep = ", ")
  }
  return(itervars_str)
}

get_itervars_join <- function(itervars_table, prefix1, prefix2){
  s1 <- paste(prefix1, ".", itervars_table[1,], sep="")
  s2 <- paste(prefix2, ".", itervars_table[1,], sep="")
  result <- paste(s1, " = ", s2, sep="")
  for(i in 2:nrow(itervars_table)) {
    s1 <- paste(prefix1, ".", itervars_table[i,], sep="")
    s2 <- paste(prefix2, ".", itervars_table[i,], sep="")
    temp <- paste(s1, " = ", s2, sep="")
    result <- paste(result, temp, sep = " AND ")
  }
  return(result)
}

option_list = list(
  make_option(c("-i", "--collected_csv"), type="character", default="../eval/Evaluation.csv", help="Path to collected CSV file", metavar="character")
); 

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

csv_path <- opt$collected_csv
csv_name <- basename(csv_path)
opp_config_name <- tools::file_path_sans_ext(csv_name)

scalars <- load_scalars(csv_path)

itervars_table <- get_itervars_table(scalars)
run_itervars_table <- get_run_itervars_table(scalars, itervars_table)
if (check_sanity_run_itervars_table(run_itervars_table)) 
{
  print("Sanity check for run_itervars_table OK")
} else {
  print("Sanity check for run_itervars_table FAILED")
}

print(stringr::str_interp("run_itervars_table has ${nrow(run_itervars_table)} rows"))

# Jammed vehicles
jammed_vehicles_table <- get_jammed_vehicles_table(scalars)
jammed_by_run_table <- get_jammed_by_run_table(jammed_vehicles_table)
jammed_by_itervars_table <- get_jammed_by_itervars_table(jammed_by_run_table, itervars_table, run_itervars_table)
jammed_by_itervars_avg_table <- get_jammed_by_itervars_avg_table(jammed_by_itervars_table, itervars_table)

# Received announcements
received_table <- get_received_announcements_table(scalars)
received_by_run_table <- get_received_announcements_by_run_table(received_announcements_table)
received_by_itervars_table <- get_received_announcements_by_itervars_table(received_by_run_table, itervars_table, run_itervars_table)
received_by_itervars_avg_table <- get_received_announcements_by_itervars_avg_table(received_by_itervars_table, itervars_table)

# Jammed join received_table
select_str <- get_itervars_prefixed_str(itervars_table, "jammed_by_itervars_avg_table")
join_str <- get_itervars_join(itervars_table, "jammed_by_itervars_avg_table", "received_by_itervars_avg_table")
received_and_jammed_query <- stringr::str_interp("SELECT ReceivedAnnouncements, JammedNumber, ${itervars_prefixed} FROM jammed_by_itervars_avg_table LEFT JOIN received_by_itervars_avg_table ON ${join_str}")
print(received_and_jammed_query)
received_and_jammed_table <- sqldf(received_and_jammed_query)
print(received_and_jammed_table)