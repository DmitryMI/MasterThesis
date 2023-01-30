sudo apt -y update
sudo apt -y install r-recommended
sudo apt -y install libssl-dev

sudo R -e "install.packages('tidyverse',dependencies = TRUE, repos=c('http://cran.uni-muenster.de/'))"
sudo R -e "install.packages('sqldf',dependencies = TRUE, repos=c('http://cran.uni-muenster.de/'))"
