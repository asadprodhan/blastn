#!/bin/bash

#metadata
metadata=./*.tsv
#
Red="$(tput setaf 1)"
Green="$(tput setaf 2)"
Bold=$(tput bold)
reset=`tput sgr0` # turns off all atribute
while IFS=, read -r field1   

do  
    echo "${Red}${Bold}Downloading ${reset}: "${field1}"" 
    echo ""
    wget https://ftp.ncbi.nlm.nih.gov/blast/db/"${field1}" 
    echo "${Green}${Bold}Downloaded ${reset}: ${field1}"
    echo ""
    echo "${Green}${Bold}Extracting ${reset}: ${field1}"
    tar -xvzf "${field1}"
    echo "${Green}${Bold}Extracted ${reset}: ${field1}"
    echo ""
    echo "${Green}${Bold}Deleting zipped file ${reset}: ${field1}"
    rm -r "${field1}"
    echo "${Green}${Bold}Deleted ${reset}: ${field1}"
    echo ""

done < ${metadata}

