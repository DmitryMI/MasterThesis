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
  type = col_skip(),
  module = col_skip(),
  name = col_character(),
  attrname = col_character(),
  attrvalue = col_character(),
  value = col_double()
)

csv_name <- paste(opt$opp_config, ".csv", sep="")
pdf_name <- paste(opt$opp_config, "-JammedVehiclesNumber.pdf", sep="")
plot_name <- paste("Boxplot for ", "JammedVehiclesNumber ", "(", opt$opp_config, ")", sep="")
scalars <- read_csv(csv_name, col_types = cols)
                       
head(scalars,n=100)

jammed_vehicles_num <- sqldf("select COUNT(Value) as cnt from scalars where Name == 'totalTimeInJam' and Value > 0 GROUP BY Run")

pdf(pdf_name) 
par(cex.main=1)
boxplot(jammed_vehicles_num$cnt, main=plot_name, ylab="Number")
dev.off()

