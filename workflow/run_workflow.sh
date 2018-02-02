#!/bin/bash

# Enter the ftp url to download the reference genome
ref_url="ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/005/845/GCF_000005845.2_ASM584v2/GCF_000005845.2_ASM584v2_genomic.fna.gz"

# Enter the unzipped file name of the reference genome
ref_file="GCF_000005845.2_ASM584v2_genomic.fna"

# Enter which tools you want to use as mapper (bwa or bowtie2 or both)
declare -a mappers=("bwa"
	"bowtie2"
	)

# Enter which which tools you want to use as variant caller (bcftools or gatk or both)
declare -a callers=("bcftools"
	"gatk"
	)

# Enter the SRA numbers of the samples splitted by spaces
declare -a sras=("SRR3736622" 
	"SRR3736623"
	"SRR3736624"
	"SRR3736625"
	"SRR3736626"
	"SRR3736627"
	"SRR3736628"
	"SRR3736629"
	"SRR3736630"
	"SRR3736631"
	"SRR3736632"
	"SRR3736633"
	"SRR3736634"
	"SRR3736635"
	"SRR3736636"
	"SRR3736637"
	"SRR3736638"
	"SRR3736639"
	"SRR3736640"
	"SRR3736641")

# Do not change anything after here
for caller in "${callers[@]}"
do
	for mapper in "${mappers[@]}"
	do
		for sra in "${sras[@]}"
		do
			make -f Makefile SRA="$sra" CALLER="$caller" MAPPER="$mapper" REF_URL="$ref_url" REF_GENOME_FILE="$ref_file"
		done
	done
done