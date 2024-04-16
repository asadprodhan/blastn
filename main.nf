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
