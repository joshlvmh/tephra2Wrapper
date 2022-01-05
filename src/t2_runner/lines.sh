#!/bin/bash

file=../../inputs/t2_inputs/conf/VEI2/t2.txt
folder=../../inputs/t2_inputs/conf/*

lines=`wc -l < $file`
characters=`wc -m < $file`
chars=$((characters / lines))
dirss=$(find $folder -maxdepth 0 -type d | wc -l)

for file_c in $(find $folder -maxdepth 0 -type d); do
  echo ${file_c: -1}
done

#echo $lines $characters $chars $dirss
#echo $list
DIR=../../inputs/t2_inputs/conf

declare -a files
files=($DIR/*)
pos=$(( ${#files[*]} - 1 ))
last=${files[$pos]}
first=${files[0]}

for FILE in "${files[@]}"
do 
  if [[ $FILE == $first ]]
  then
    echo "$FILE is the first" 
  else 
    echo "$FILE"
  fi 
done 
