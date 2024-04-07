#!/bin/bash -i
# ask for query file
echo Enter your input file name including extension and hit ENTER
read -e F
# ask for an output directory name
echo Enter an output directory name and hit ENTER
read -e outDir
# ask for the blast database path
echo Enter the path to the blast database and hit ENTER
read -e BlastDB
echo ""
# start monitoring run time
SECONDS=0
# make blast results directory
mkdir ${outDir}
# prepare output file name prefix
baseName=$(basename $F .fasta)
# Run blastn with .asn output
echo blastn in progress...
blastn -db ${BlastDB} -num_alignments 1 -num_threads 16 -outfmt 11 -query $PWD/$F > $PWD/${outDir}/${baseName}.asn
# convert output file from asn to xml format
echo converting output file from asn to xml format
blast_formatter -archive $PWD/${outDir}/${baseName}.asn -outfmt 5 > $PWD/${outDir}/${baseName}.xml
# convert output file from asn to tsv format
echo converting output file from asn to tsv format
blast_formatter -archive $PWD/${outDir}/${baseName}.asn -outfmt 0 > $PWD/${outDir}/${baseName}.tsv
# display the compute time
if (( $SECONDS > 3600 )) ; then
    let "hours=SECONDS/3600"
    let "minutes=(SECONDS%3600)/60"
    let "seconds=(SECONDS%3600)%60"
    echo "Completed in $hours hour(s), $minutes minute(s) and $seconds second(s)"
elif (( $SECONDS > 60 )) ; then
    let "minutes=(SECONDS%3600)/60"
    let "seconds=(SECONDS%3600)%60"
    echo "Completed in $minutes minute(s) and $seconds second(s)"
else
    echo "Completed in $SECONDS seconds"
fi
