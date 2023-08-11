#!/usr/bin/env perl

#########################################################
#
# Platform: NCI Gadi HPC
# Description: Split GeneWiz 'combined' fastq files into flowcell/lane pairs
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

my $fastq = '';
my $outdir = ''; 
if ($ARGV[0]) {
	$fastq = $ARGV[0];
}
if ($ARGV[1]) {
	$outdir = $ARGV[1];
}

if ( -e $fastq) {
	chomp $fastq;
	print "Splitting $fastq by flowcell and lane\n"; 
}
else {
	print "Fatal error: input fastq $fastq not found. Please resubmit with fastq input as argument 1 and outdir as argument 2\n"; 
	die;
} 

if ( ( -e $outdir) && ( -d $outdir) ) {
	chomp $outdir;
	print "Writing lane-level fastq to $outdir\n"; 
}
else {
	print "Fatal error: output directory $outdir not found. Please resubmit with fastq input as argument 1 and outdir as argument 2\n"; 
	die;		
}

#Note: this bit is not portable right now. Needs updating...
# Assumes sample ID is separated from 'R1.fastq' or 'R2.fastq' by '_combined_'
$fastq=~m/\w+\/(\S+)\_combined_(R\d{1}).fastq/;
my $prefix = $1; my $end = $2; 
 

open (I, $fastq) || die "$! $fastq\n";
my $c = 0; 
my $first = 1; 
my $prev_out = '';
my $out = '';
while (my $line = <I>){
	chomp $line; 
	my $in = ''; 
	$c++;
	if ($c == 1) {
		# Old GeneWiz data (pre-llumina) needed this split method:
		#$line=~s/^\@//;
		#my $flowcell = substr $line, 0, 10;
		#my $lane = substr $line, 11, 1;
		#my $other = substr $line, 12; 
		
		# Latest GeneWiz data needs this method (normal Illumina read ID format):
		my ($inst, $runid, $flowcell, $lane, @rest) = split(':', $line);
		
		$out = "$outdir\/$prefix\_$flowcell\_$lane\_$end\.fastq"; 
		if ($first) {
			print "Opening $out\n";
			open OUT, '>', $out or die "$! write $out\n";
			# print OUT "\@$flowcell\:$lane\:$other\n"; # old method			
			print OUT "$line\n"; # new
			$first = 0; 
		}
		else {
			if  ($out eq $prev_out) {
				#print OUT "\@$flowcell\:$lane\:$other\n"; # old method			
				print OUT "$line\n"; # new		
			}
			else {
				print "Closing $prev_out and opening $out\n"; 
				close OUT; 
				open OUT, '>>', $out or die "$! write $out\n"; ### Note that the append 
				# output redirection is required as we dont know if all reads from a flowcell/lane
				# combo are adjacent. So this means that the outdir MUST be emptied in the event of
				# a rerun of this script over the same data to the same outdir. 
				      
				#print OUT "\@$flowcell\:$lane\:$other\n"; # old method			
				print OUT "$line\n"; # new				
			}
		}		
	}
	else {
		print OUT "$line\n";		
		if ($c == 4) {
			$c = 0; 
			$prev_out = $out; 
		}
	}
} close I; 
