printf "Installing R...\n\n"

SUDO_PREFIX=""
if [ "$EUID" -ne 0 ]
then 
    SUDO_PREFIX="sudo"
fi


$SUDO_PREFIX apt -y update
$SUDO_PREFIX apt -y install r-recommended
$SUDO_PREFIX apt -y install libssl-dev

$SUDO_PREFIX R -e "install.packages('tidyverse',dependencies = TRUE, repos=c('http://cran.uni-muenster.de/'))"
$SUDO_PREFIX R -e "install.packages('sqldf',dependencies = TRUE, repos=c('http://cran.uni-muenster.de/'))"
$SUDO_PREFIX R -e "install.packages('optparse',dependencies = TRUE)"
