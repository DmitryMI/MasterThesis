require(sqldf)
require(tools)
library("optparse")
library(ggplot2)

source("scalars-loader.R")
source("table-itervars.R")
source("table-jammed-vehicles.R")

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

jammed_vehicles_table <- get_jammed_vehicles_table(scalars)
jammed_by_run_table <- get_jammed_by_run_table(jammed_vehicles_table)
jammed_by_itervars_table <- get_jammed_by_itervars_table(jammed_by_run_table, itervars_table, run_itervars_table)
jammed_by_itervars_avg_table <- get_jammed_by_itervars_avg_table(jammed_by_itervars_table, itervars_table)
print(jammed_by_itervars_avg_table)


