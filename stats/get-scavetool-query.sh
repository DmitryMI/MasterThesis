#!/bin/bash

input="scavetool-variables.txt"

query=""

while IFS= read -r line
do
  # echo "$line"
  if [ -z "$query" ]
  then
    query="name($line)"
  else
    query="$query OR name($line)"
  fi
  
done < "$input"

echo $query
