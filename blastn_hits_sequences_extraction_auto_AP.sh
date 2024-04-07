#!/bin/bash -i

#
Red="$(tput setaf 1)"
Green="$(tput setaf 2)"
Bold=$(tput bold)
reset=`tput sgr0` # turns off all atribute

# ask for blastn output file
echo ""
echo ""
echo "${Red}${Bold}Enter blastn output tsv file and hit ENTER ${reset}" 
echo ""
read -e F
echo ""
# ask for the key word
echo "${Red}${Bold}Enter filter word (CASE-SENSITIVE) and hit ENTER ${reset}" 
echo ""
read -e KeyWord
echo ""

# ask for the blastn query fasta file
echo "${Red}${Bold}Enter blastn query fasta file and hit ENTER ${reset}" 
echo ""
read -e Query
echo ""

# prepare output file name prefix
baseName=$(basename $F .tsv)
echo ""

# filtering the selected blastn hits
echo ""
echo "${Green}${Bold}Filtering the blastn hits containing ${reset}: "${KeyWord}"" 
echo ""
grep ${KeyWord} $F > ${baseName}_${KeyWord}.tsv

# collecting the query IDs from the selected blastn hits

echo "${Green}${Bold}Collecting the query IDs from the selected blastn hits ${reset}: "${KeyWord}"" 
echo ""
awk '{print $1}' ${baseName}_${KeyWord}.tsv > IDs.txt

# extracting the sequences for the selected blastn hits

echo "${Green}${Bold}Extracting the sequences for the selected blastn hits ${reset}: "${KeyWord}"" 
echo ""
bioawk -cfastx 'BEGIN{while((getline k <"IDs.txt")>0)i[k]=1}{if(i[$name])print ">"$name"\n"$seq}' ${Query} > ${baseName}_${KeyWord}.fasta
echo ""

echo "${Green}${Bold}Done ${reset}: "${KeyWord}"" 
echo ""
echo ""