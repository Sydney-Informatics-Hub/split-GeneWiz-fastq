#!/bin/bash 

#########################################################
#
# Platform: NCI Gadi HPC
# Description: Split GeneWiz 'combined' fastq files into flowcell/lane pairs
# by launching a perl sript that writes new flow-cell-lane fastq
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

fastq=`echo $1 | cut -d ',' -f 1`
prefix=`echo $1 | cut -d ',' -f 2`
unzipdir=`echo $1 | cut -d ',' -f 3`
outdir=`echo $1 | cut -d ',' -f 4`

# Unzip the fastq
gunzip -c $fastq > ${unzipdir}/${prefix}

lines=$(wc -l ${unzipdir}/${prefix})

echo $lines > ${unzipdir}/${prefix}.lineCount

perl Scripts/split_genewiz_by_lane_updated.pl ${unzipdir}/${prefix} $outdir
