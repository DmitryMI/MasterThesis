require(sqldf)
require(readr)
cols <-cols(
  run = col_character(),
  type = col_skip(),
  module = col_skip(),
  name = col_character(),
  attrname = col_character(),
  attrvalue = col_character(),
  value = col_double()
)
scalars <- read_csv("results.csv", col_types = cols)
                       
head(scalars,n=100)

jammed_vehicles_num <- sqldf("select COUNT(Value) as cnt from scalars where Name == 'totalTimeInJam' and Value > 0 GROUP BY Run")

pdf("JammedVehiclesNumber.pdf") 
boxplot(jammed_vehicles_num$cnt, main="Boxplot for 'JammedVehiclesNumber'", ylab="Number")
dev.off()

