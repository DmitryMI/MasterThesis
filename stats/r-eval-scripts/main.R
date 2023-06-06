require(sqldf)
require(tools)
library("optparse")
library(ggplot2)

source("scalars-loader.R")
source("table-itervars.R")
source("table-jammed-vehicles.R")
source("table-vehicle-jam-time.R")
source("table-vehicle-speed.R")
source("table-scalar.R")
source("table-received-announcements.R")
source("plotting.R")

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
  make_option(c("-i", "--collected_csv"), type="character", default="../../hpc/eval/Evaluation-NumberOfVehicles.csv", help="Path to collected CSV file", metavar="character"),
  make_option(c("-o", "--output_dir"), type="character", default="../eval", help="Path to output directory", metavar="character")
); 

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

csv_path <- opt$collected_csv
csv_name <- basename(csv_path)
opp_config_name <- tools::file_path_sans_ext(csv_name)

output_dir <- opt$output_dir


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
received_by_run_table <- get_received_announcements_by_run_table(received_table)
received_by_itervars_table <- get_received_announcements_by_itervars_table(received_by_run_table, itervars_table, run_itervars_table)
received_by_itervars_avg_table <- get_received_announcements_by_itervars_avg_table(received_by_itervars_table, itervars_table)

# Jammed and Received in one table
select_str <- get_itervars_prefixed_str(itervars_table, "jammed_by_itervars_avg_table")
join_str <- get_itervars_join(itervars_table, "jammed_by_itervars_avg_table", "received_by_itervars_avg_table")
received_and_jammed_query <- stringr::str_interp("SELECT ReceivedAnnouncements, JammedNumber, ${select_str} FROM jammed_by_itervars_avg_table LEFT JOIN received_by_itervars_avg_table ON ${join_str}")
print(received_and_jammed_query)
received_and_jammed_table <- sqldf(received_and_jammed_query)
# print(received_and_jammed_table)

# Jamed DIV Received
itervars_str <- get_itervars_str(itervars_table)
received_div_jammed_query <- stringr::str_interp("SELECT (ReceivedAnnouncements / JammedNumber) as ReceivedDivJammed, ${itervars_str} FROM received_and_jammed_table")
print(received_div_jammed_query)
received_div_jammed_table <- sqldf(received_div_jammed_query)
# print(received_div_jammed_table)

# Time in jam
jam_time_table1 <- get_vehicles_jam_time_table(scalars)
jam_time_table2 <- get_vehicles_jam_time_by_run_table(jam_time_table1)
jam_time_table3 <- get_vehicles_jam_time_by_itervars_table(jam_time_table2, itervars_table, run_itervars_table)
jam_time_table <- get_jam_time_by_itervars_avg_table(jam_time_table3, itervars_table)
# print(jam_time_table)

# Average vehicle speed
speed_table1 <- get_vehicles_speed_table(scalars)
speed_table2 <- get_vehicle_speed_by_run_table(speed_table1)
speed_table3 <- get_vehicle_speed_by_itervars_table(speed_table2, itervars_table, run_itervars_table)
speed_table <- get_vehicle_speed_by_itervars_avg_table(speed_table3, itervars_table)
# print(speed_table)

# Channel busy time ratio
busytime_table1 <- get_scalar_table(scalars, "busyTime")
busytime_table2 <- get_scalar_by_run_table(busytime_table1, "busyTime")
busytime_table3 <- get_scalar_by_itervars_table(busytime_table2, itervars_table, run_itervars_table, "busyTime")
busytime_table <- get_scalar_by_itervars_avg_table(busytime_table3, itervars_table, "busyTime")

# Hop count
#hops_table1 <- get_scalar_table(scalars, "hopsAverage")
#hops_table2 <- get_scalar_by_run_table(hops_table1, "hopsAverage")
#hops_table3 <- get_scalar_by_itervars_table(hops_table2, itervars_table, run_itervars_table, "hopsAverage")
#hops_table <- get_scalar_by_itervars_avg_table(hops_table3, itervars_table, "hopsAverage")

# E2E Latency
# latency_table1 <- get_scalar_table(scalars, "latencyAverage")
latency_table1 <- get_scalar_table_where(scalars, "latencyAverage", "Module LIKE '%node%'")
latency_table2 <- get_scalar_by_run_table(latency_table1, "latencyAverage")
latency_table3 <- get_scalar_by_itervars_table(latency_table2, itervars_table, run_itervars_table, "latencyAverage")
latency_table <- get_scalar_by_itervars_avg_table(latency_table3, itervars_table, "latencyAverage")

accident_probabilities_values <- sqldf("select distinct AccidentProbability from received_div_jammed_table")
number_of_vehicles_values <-sqldf("select distinct NumberOfVehicles from received_div_jammed_table")
print(accident_probabilities_values)
print(number_of_vehicles_values)

param1_values = NULL
param2_values = NULL

if (nrow(accident_probabilities_values) < nrow(number_of_vehicles_values)) {
  param1_values <- accident_probabilities_values
  param2_values <- number_of_vehicles_values
} else {
  param2_values <- accident_probabilities_values
  param1_values <- number_of_vehicles_values
}

# time <- Sys.time()
time <- "NA"

pdf_name <- paste(opp_config_name, "-ReceivedAnnouncements-", time, ".pdf", sep="")
pdf(file.path(output_dir, pdf_name))
plot_default(received_div_jammed_table, ReceivedDivJammed, param1_values, param2_values, "Received Announcements Ratio")
dev.off()

pdf_name <- paste(opp_config_name, "-JamTime-", time, ".pdf", sep="")
pdf(file.path(output_dir, pdf_name))
plot_default(jam_time_table, TotalTimeInJam, param1_values, param2_values, "Jam Time", "s")
dev.off()

pdf_name <- paste(opp_config_name, "-JammedNumber-", time, ".pdf", sep="")
pdf(file.path(output_dir, pdf_name))
plot_default(jammed_by_itervars_avg_table, JammedNumber, param1_values, param2_values, "Jammed Vehicles")
dev.off()

pdf_name <- paste(opp_config_name, "-VehicleSpeed-", time, ".pdf", sep="")
pdf(file.path(output_dir, pdf_name))
plot_default(speed_table, Speed, param1_values, param2_values, "Vehicle Speed", "m/s")
dev.off()

pdf_name <- paste(opp_config_name, "-ChannelBusyTimeRatio-", time, ".pdf", sep="")
pdf(file.path(output_dir, pdf_name))
plot_default(busytime_table, busyTime, param1_values, param2_values, "Channel Busy Time Ratio")
dev.off()

pdf_name <- paste(opp_config_name, "-Latency-", time, ".pdf", sep="")
pdf(file.path(output_dir, pdf_name))
plot_default(latency_table, latencyAverage, param1_values, param2_values, "Latency", "s")
dev.off()

#pdf_name <- paste(opp_config_name, "-Hops-", time, ".pdf", sep="")
#pdf(file.path(output_dir, pdf_name))
#plot_default(hops_table, hopsAverage, param1_values, param2_values)
#dev.off()