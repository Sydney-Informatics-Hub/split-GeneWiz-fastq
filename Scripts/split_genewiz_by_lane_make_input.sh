#!/bin/bash

#########################################################
#
# Platform: NCI Gadi HPC
# Description:  Create input text file for parallel GeneWiz data lane splitting
# see https://github.com/Sydney-Informatics-Hub/split-GeneWiz-fastq
#
# Author/s: Cali Willet
# cali.willet@sydney.edu.au
#
# If you use this script towards a publication, please acknowledge the
# Sydney Informatics Hub (or co-authorship, where appropriate).
#
# Suggested acknowledgement:
# The authors acknowledge the scientific and technical assistance
# <or e.g. bioinformatics assistance of <PERSON>> of Sydney Informatics
# Hub and resources and services from the National Computational
# Infrastructure (NCI), which is supported by the Australian Government
# with access facilitated by the University of Sydney.
#
#########################################################

mkdir -p ./Inputs

inputs=./Inputs/split_genewiz_by_lane.inputs
rm -f $inputs

unzipdir=./Fastq_unzipped
outdir=./Fastq_laneSplit

mkdir -p $unzipdir $outdir

for fastq in ./Fastq/*.f*q.gz
do
	prefix=$(basename $fastq | sed 's/\.gz$//' )
	printf "${fastq},${prefix},${unzipdir},${outdir}\n" >> $inputs 
done

tasks=`wc -l < $inputs`
printf "Number of fastq files to split: ${tasks}\n"
