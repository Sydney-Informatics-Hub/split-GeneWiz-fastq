#!/usr/bin/env perl

#########################################################
#
# Platform: NCI Gadi HPC
# Description: Check split files contain same number of reads as input
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

use warnings;
use strict;


############## CHECK/UPDATE: ##############

# Check directory paths match your setup: 
my $unsplit_fastq_dir = './Fastq'; 
my $unzipped_fastq_dir = './Fastq_unzipped'; 
my $fastqc_split_dir = './fastQC/lanesplit'; 


# Collect samples (check this bash one liner manually before running)  
my @samples = split(' ', `ls -1 ${unsplit_fastq_dir}/*f*q.gz | awk -F _ '{print \$1}' | sort | uniq`); 

############## END CHECK/UPDATE: ##########



foreach my $s (@samples ) {
	my $sample = `basename $s`; 
	chomp $sample;  
		
	# Get total read count for GeneWiz "combined" fastq:  	
	my $r1_log = (`ls ${unzipped_fastq_dir}/*${sample}*R1.fastq.lineCount`); chomp $r1_log; 
	my $r1_combined_reads = (`awk '{print \$1}' $r1_log` / 4); 
	chomp $r1_combined_reads; 
	
	my $r2_log = (`ls ${unzipped_fastq_dir}/*${sample}*R2.fastq.lineCount`); chomp $r2_log; 
	my $r2_combined_reads = (`awk '{print \$1}' $r2_log` / 4); 
	chomp $r2_combined_reads; 
	
	# Basic check r1 matches r2 for the input: 
	if ($r1_combined_reads != $r2_combined_reads) {
		print "ERROR: $sample has different read counts for R1 ($r1_combined_reads) and R2 ($r2_combined_reads)!\n";
		print "TERMINATING\n"; die;  
	}

	# Get total read count from split files via FastQC output: 
	# R1: 
	my @dirs = split(' ', `find $fastqc_split_dir -type d -name "$sample\*_R1_fastqc" -print`);
	my $r1_splitTotal_reads = 0; 
	foreach my $dir (@dirs) {
		my $seqs = `grep "Total Sequences" ${dir}/fastqc_data.txt | awk '{print \$3}'`; 
		chomp $seqs; 
		$r1_splitTotal_reads += $seqs; 
	}
	
	# R2: 
	@dirs = split(' ', `find $fastqc_split_dir -type d -name "$sample\*_R2_fastqc" -print`);
	my $r2_splitTotal_reads = 0; 
	foreach my $dir (@dirs) {
		my $seqs = `grep "Total Sequences" ${dir}/fastqc_data.txt | awk '{print \$3}'`; 
		chomp $seqs; 
		$r2_splitTotal_reads += $seqs; 
	}	
	
	#Compare R1 split v R2 split: 
	if ($r1_splitTotal_reads != $r2_splitTotal_reads) {
		print "SPLITTING ERROR: $sample has different read counts for R1 split ($r1_splitTotal_reads) and R2 split ($r2_splitTotal_reads)!\n";
	} 	
	
	#Compare split v unsplit:
	if ($r1_combined_reads != $r1_splitTotal_reads) {
		print "SPLITTING ERROR: $sample has different read counts for R1 original ($r1_combined_reads) and R1 post-split ($r1_splitTotal_reads)!\n";
	} 
	else {
		print "Splitting read count check passed for sample $sample\: $r1_splitTotal_reads reads\n";
	} 	
}  
