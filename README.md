<h1 align="center">How to automatically download blastn database, run blastn, and extract blastn hit sequences</h1>


<h3 align="center">M. Asaduzzaman Prodhan<sup>*</sup></h3>


<div align="center"><b> DPIRD Diagnostics and Laboratory Services, Department of Primary Industries and Regional Development </b></div>


<div align="center"><b> 3 Baron-Hay Court, South Perth, WA 6151, Australia </b></div>


<div align="center"><b> <sup>*</sup>Correspondence: Asad.Prodhan@dpird.wa.gov.au </b></div>


<br />


<p align="center">
  <a href="https://github.com/asadprodhan/blastn/tree/main#GPL-3.0-1-ov-file"><img src="https://img.shields.io/badge/License-GPL%203.0-yellow.svg" alt="License GPL 3.0" style="display: inline-block;"></a>
  <a href="https://orcid.org/0000-0002-1320-3486"><img src="https://img.shields.io/badge/ORCID-green?style=flat-square&logo=ORCID&logoColor=white" alt="ORCID" style="display: inline-block;"></a>
</p>


<br />


### Content


[01.  Blastn database download and update [Automated by NCBI tool]](https://github.com/asadprodhan/blastn#using-ncbi-supplied-script)


[02.  Blastn database download and update [Automated by bash script]](https://github.com/asadprodhan/blastn#using-a-bash-script)


[03.  Blastn execution [User-interactive bash script & Nextflow DSL2 script]](https://github.com/asadprodhan/blastn#run-blastn)


[04.  Blastn hits sequence extraction [User-interactive bash script]](https://github.com/asadprodhan/blastn#extract-sequences-for-blastn-hits)


[05.  Blastn common errors and solutions](https://github.com/asadprodhan/blastn#common-blastn-errors-and-solutions)


<br />


<br />


## **Download or update blastn database using NCBI-supplied script**

<br />

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


> When the download is complete, confirm that all the nt files have been downloaded. You can do that by cross-checking nt file numbers between https://ftp.ncbi.nlm.nih.gov/blast/db/ and your directory


> If you don't have all the nt files in your directory, then you will get "BLAST Database error: Could not find volume or alias file nt.xxx in referenced alias file"


> You can download the missing nt files by using the following bash script


> When all the nt files are downloaded, you can delete the md5 files as follows:



```
rm -r *.md5
```


<br />


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



- Put the ***metadata.tsv*** file and the following ***blastn script*** in the directory where you want to download the blastn database


- Check the file format as follows:


```
file *
```


All files are required to be in UNIX format i.e., ASCII text only. Files written in Windows computer will have Windows format i.e., ASCII text, with CRLF line terminators. Convert these files into unix format by running the following command:


```
dos2unix *
```


- Check the files are executable


```
ls -l
```


Run the following command to make the files executable


```
chmod +x *
```
  

<br />


### **Bash script to download blastn database automatically** 


#### [DOWNLOAD](https://github.com/asadprodhan/blastn/blob/main/blastn_database_download_auto_AP.sh)


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


<br />


## **Run blastn**


### **Interactive bash script to run blastn** 


#### [DOWNLOAD](https://github.com/asadprodhan/blastn/blob/main/blastn_run_with_prompts_auto_AP.sh)



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


> Default identity percentage is 90%


> Default query coverage percentage is 0%


> The smaller the E-value, the better the match


> Ref: https://www.metagenomics.wiki/tools/blast/evalue


> The higher the bit-score, the better the sequence similarity


<br />



### **Nextflow script to run blastn** 


**This script allows you for** 


- modifying the default blastn parameters

- running blastn on both local and remote computers using containers (This removes the need of installing and updating the blastn software. However, you will need to install Nextflow and Singularity)

- automating blastn analysis for multiple samples



#### [DOWNLOAD](https://github.com/asadprodhan/blastn/blob/main/main.nf) 


#### **Nextflow main.nf script**


```
#!/usr/bin/env nextflow

nextflow.enable.dsl=2

//data_location
params.in = "$PWD/*.fasta"
params.outdir = './results'
params.db = "./blastn_db"
params.evalue='0.05'
params.identity='90'
params.qcov='90'

// blastn

process blastn {

	errorStrategy 'ignore'
	tag { file }
	publishDir "${params.outdir}/blastn", mode:'copy'

	input:
	path (file) 
	path db 

	output:
	path "${file.simpleName}_blast.xml"
	path "${file.simpleName}_blast.html"
	path "${file.simpleName}_blast_sort_withHeader.tsv"

	script:
	"""
	blastn \
		-query $file -db ${params.db}/nt \
		-outfmt 11 -out ${file.simpleName}_blast.asn \
		-evalue ${params.evalue} \
		-perc_identity ${params.identity} \
		-qcov_hsp_perc ${params.qcov} \
		-num_threads ${task.cpus}

	blast_formatter \
		-archive ${file.simpleName}_blast.asn \
		-outfmt 5 -out ${file.simpleName}_blast.xml

	blast_formatter \
		-archive ${file.simpleName}_blast.asn \
		-html -out ${file.simpleName}_blast.html

	blast_formatter \
		-archive ${file.simpleName}_blast.asn \
		-outfmt "6 qaccver saccver pident length evalue bitscore stitle" -out ${file.simpleName}_blast_unsort.tsv

	sort -k1,1 -k5,5n -k4,4nr -k6,6nr ${file.simpleName}_blast_unsort.tsv > ${file.simpleName}_blast_sort.tsv
	awk 'BEGIN{print "qaccver\tsaccver\tpident\tlength\tevalue\tbitscore\tmismatch\tgapopen\tqstart\tqend\tsstart\tsend\tstitle"}1' ${file.simpleName}_blast_sort.tsv > ${file.simpleName}_blast_sort_withHeader.tsv

	"""
}

workflow {

	query_ch = Channel.fromPath(params.in)
	db = file( params.db )
	blastn (query_ch, db)
        
}
```


<br />


#### **Nextflow nextflow.config script**


#### [DOWNLOAD](https://github.com/asadprodhan/blastn/blob/main/nextflow.config)


```
resume = true

process {
    withName:'blastn|blastIndex'                 { container = 'quay.io/biocontainers/blast:2.14.1--pl5321h6f7f691_0' }
}

singularity {
 enabled = true
 autoMounts = true
 //runOptions = '-e TERM=xterm-256color'
 envWhitelist = 'TERM'
}

```


#### **command**


```
nextflow run main.nf --evalue=0.05 --identity='90' --qcov='0' --db="/path/to/blastn_database"
```


<br />


## **Extract sequences for blastn hits**


<br />

### **Bash script to extract sequences for blastn hits automatically** 


#### [DOWNLOAD](https://github.com/asadprodhan/blastn/blob/main/blastn_hits_sequences_extraction_auto_AP.sh)


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
 align="center" >   
</p>
<p align = center>
Figure 2: How blastn_hits_sequences_extraction_auto_AP script works.
</p>


<br />


<br />


## **Common blastn errors and solutions**


<br />


### **Q: How to resolve the Blastn database error ‘No alias or index file found’?**


<br />


<p align="center">
  <img 
    src="https://github.com/asadprodhan/blastn/blob/main/Blastn_database_error_No_alias_or_index_file_found.png"
 align="center" >   
</p>
<p align = center>
Figure 3: Blastn database error "No alias or index file found".
</p>

<br />


### **Solution**


This error might be resolved by adjusting the script as follows:


- Add ‘nt’ at the end of the database path like /path/to/the/blastn/db/nt


> See the database path in the blastn script above. Likewise, ‘/nr’ for blastp

  
- If Blastn is your first or only process in the Nextflow script; then the process might take the path of the database. If not, then the database needs to be supplied as files. See the following reference. And the input channel should have path(db) in addition to the path(query_sequence). See the blastn script above. 

 
 > https://stackoverflow.com/questions/75465741/path-not-being-detected-by-nextflow


<br />



### **Q: How to resolve the Blastn database error ‘Not a valid version 4 database’?**


<br />


<p align="center">
  <img 
    src="https://github.com/asadprodhan/blastn/blob/main/Blastn_database_error_Not_a_valid_version_4_database.png"
 align="center" >   
</p>
<p align = center>
Figure 4: Blastn database error "Not a valid version 4 database".
</p>


<br />


### **Solution**

- This is a blast version conflict


- When you create a conda environment, it automatically installs blast v2.6 that can’t use the latest blast nr database


- You need an undated version such as blast v2.15.0 to use the latest blast nr database.


- Check which version of blastn you have:


```
blastn -version
```


- Update the latest version of blastn:


```
conda install -c bioconda blast
```


<br />


### **Q: How to resolve the Blastn database error "could not find nt.XXX alias in the reference alias"?**


<br />


<p align="center">
  <img 
    src="https://github.com/asadprodhan/blastn/blob/main/Blastn_database_error_could_not_find_ntXXX_alias_in_the_reference_alias.PNG"
 align="center" >   
</p>
<p align = "center">
Figure 5: Blastn database error "could not find nt.XXX alias in the reference alias".
</p>


<br />


### **Solution**


- When you don't have all the nt files in your blastn database directory, then you will get this error "BLAST Database error: Could not find volume or alias file nt.xxx in referenced alias file"


- Cross-check the nt file numbers between https://ftp.ncbi.nlm.nih.gov/blast/db/ and your blastn database directory


- You can download the missing nt files by using the above bash script 



<br />

<br />



