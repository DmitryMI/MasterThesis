require(sqldf)
require(readr)
library("optparse")

option_list = list(
    make_option(c("-i", "--opp_config"), type="character", default=NULL, help="OMNeT++ config name", metavar="character")
); 
 
opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

cols <-cols(
  run = col_character(),
  type = col_character(),
  module = col_skip(),
  name = col_character(),
  attrname = col_character(),
  attrvalue = col_character(),
  value = col_double()
)

csv_name <- paste(opt$opp_config, ".csv", sep="")
scalars <- read_csv(csv_name, col_types = cols)
                       
repetition_query <- "select Run, Attrvalue as Repetition from scalars where Type == 'runattr' and Attrname == 'repetition'"
number_of_drones_query <- "select Run, CAST(Attrvalue as integer) as NumberOfDrones from scalars where Type == 'itervar' and Attrname == 'NumberOfDrones'"
repetition_table <- sqldf(repetition_query)
# head(repetition_table,n=200)

number_of_drones_table <- sqldf(number_of_drones_query)
# head(number_of_drones_table,n=200)

run_description_query <- "select number_of_drones_table.Run, Repetition, NumberOfDrones from number_of_drones_table inner join repetition_table on number_of_drones_table.Run == repetition_table.Run"
run_description_table <- sqldf(run_description_query)
# head(run_description_table,n=200)

jammed_vehicles_query <- "select COUNT(Value) as JammedNum, NumberOfDrones, Repetition, scalars.Run from scalars inner join run_description_table on scalars.Run == run_description_table.Run where Name == 'totalTimeInJam' and Value > 0 GROUP BY scalars.Run"

jammed_vehicles_table <- sqldf(jammed_vehicles_query)
# head(jammed_vehicles_table,n=200)

jammed_vehicles_avg_query <- "select AVG(JammedNum) as JammedNumAvg, NumberOfDrones from jammed_vehicles_table group by NumberOfDrones"
jammed_vehicles_avg_table <- sqldf(jammed_vehicles_avg_query)
head(jammed_vehicles_avg_table, n=100)


pdf_name <- paste(opt$opp_config, "-JammedVehiclesNumber-", Sys.time(), ".pdf", sep="")
plot_name <- paste("Boxplot for ", "Number of Jammed Vehicles ", "(", opt$opp_config, ")", sep="")
pdf(pdf_name) 
par(cex.main=1)
plot(jammed_vehicles_avg_table$JammedNumAvg ~ jammed_vehicles_avg_table$NumberOfDrones, type = "l", main=plot_name, ylab="Jammed vehicles Average", xlab="Number of Drones")
dev.off()


