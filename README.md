# **How to automatically download blastn database, run blastn, and extract blastn hit sequences?** <br />


### **AUTHOR: Dr Asad Prodhan** https://asadprodhan.github.io/


<br />


<br />



### **Download or update blastn database using NCBI-supplied script**


### **Using NCBI-supplied script**  


- Create a conda environment for blastn
  

```
conda create -n blastn_db
```


- Activate the blastn environment

   
```
conda activate blastn_db
```


- Copy the link of the latest blast executable from the following link


> https://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/LATEST/


- download the executable as follows



```
wget https://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/LATEST/ncbi-blast-2.15.0+-x64-linux.tar.gz
```


- Extract the downloaded file as follows


```
tar -zxvf ncbi-blast-2.15.0+-x64-linux.tar.gz
```


- Navigate to the following directory


```
cd ncbi-blast-2.15.0+/bin
```

 
- Add this path to the PATH environmental variable. See how to do this in my tutorial:


> https://github.com/asadprodhan/About-the-PATH


- Copy the update_blastdb.pl from the ncbi-blast-2.15.0+/bin directory to the directory you want to download the blastn database


```
cp ./update_blastdb.pl databaseDirectory
```


- Run the script as follows


```
run ./update_blastdb.pl --decompress nt
```


> Download will automatically start


> You can delete the md5 files as follows:



```
rm -r *.md5
```



### **Using a bash script**  



- Prepare a metadata.tsv file containing the list of all nt.??.tar.gz files. The nt.??.tar.gz files are located at 


> https://ftp.ncbi.nlm.nih.gov/blast/db/


The file metadata.tsv looks like this:


<br />


<p align="center">
  <img 
    src="https://github.com/asadprodhan/blastn/blob/main/NCBI_BlastDB_List_Example_AP.PNG"
 align="center" width=15% height=15% >   
</p>
<p align = center>
Figure 1: Blastn database nt files.
</p>

<br />



- Put the **metadata.tsv** file and the following **blastn script** in the directory where you want to download the blastn database


### **Bash script to download blastn database automatically** [DOWNLOAD](https://github.com/asadprodhan/blastn/blob/main/blastn_database_download_auto_AP.sh)


```
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

```


> x: tells tar to extract the files


> v: “v” stands for “verbose”, listing all of the files as the decompression continues


> z: tells the tar command to uncompress/decompress the file (gzip)


> f: tells tar that a file will be assigned to work with


> pkill -9 wget # to abort the running wget download



> Wild card like ‘*tar.gz’ doesn’t work for ‘tar’. Because tar supplied with a “*” doesn’t only limit itself to the existing tar files in the directory but also it expands to the imaginary file names (!), for example, abc.tar.gz def.tar.gz ghi.tar.gz or 1.gz, 2.gz and 3.gz etc. Since these files are non-existence, tar can’t find them and produce ‘not found in the archive’ error. The following loop function can overcome this issue when you have multiple tar files to decompress.


```
for file in *.tar.gz; do tar -xvzf "$file"; done
```


### **Run blastn**


### **Blastn automated script** [DOWNLOAD](https://github.com/asadprodhan/blastn/blob/main/blastn_run_with_prompts_auto_AP.sh)



```
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
```



> The smaller the E-value, the better the match


> Ref: https://www.metagenomics.wiki/tools/blast/evalue


> The higher the bit-score, the better the sequence similarity


### **Extract sequences for blastn hits**


### **Bash script to extract sequences for blastn hits automatically** [DOWNLOAD](https://github.com/asadprodhan/blastn/blob/main/blastn_hits_sequences_extraction_auto_AP.sh)



```
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

```


The bash script to extract blastn hit sequences is user-interactive. 
It will ask for inputs, automatically process them, and produce a file containing the expected fasta sequences. 
See the screenshot below:


<br />


<p align="center">
  <img 
    src="https://github.com/asadprodhan/blastn/blob/main/How_blastn_hits_sequences_extraction_auto_AP_script_works.PNG"
 align="center" width=50% height=50% >   
</p>
<p align = center>
Figure 2: How blastn_hits_sequences_extraction_auto_AP script works.
</p>

<br />


### **Common errors and solutions**



**BLAST Database error: No alias or index file found for nucleotide database**


Check the followings:
Blast database location in Pawsey
/scratch/references/blastdb_update/blast-2023-07-01
Each database directory has a ‘db’ directory
Within the ‘db’ directory, there are all the indexed files such as nhr nin etc
so, the complete database path will be as follows:
/scratch/references/blastdb_update/blast-2023-07-01/db/nt


> In the script: make sure to put ‘/nt’ at the end of the blast database path for blastn and ‘/nr’ for blastp


> chmod +x * 


> RAM allocation


