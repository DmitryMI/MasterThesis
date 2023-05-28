input="scavetool-variables.txt"

filter=""

while IFS= read -r line
do
  filter="$filter -F $line"
  
done < "$input"

itervar="-I NumberOfDrones -I NumberOfVehicles -I AccidentProbability"

./opp_sca2csv.pl $filter $itervar
