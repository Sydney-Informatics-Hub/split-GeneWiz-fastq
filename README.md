# split-GeneWiz-fastq
Split GeneWiz 'combined' (concatenated) fastq files into correct flowcell-lane pairs

## GeneWiz 'combined' data format

If you receive some GeneWiz fastq sequence data and the word 'combined' appears within it, it is most likely the product of multiple flowcell-lane pairs being concatenated into one pair of fastq per sample.

In order to enable correct assignation of the 'ID' and 'PU' read group fields (which can be critical for downstream steps, [for example BQSR](https://gatk.broadinstitute.org/hc/en-us/articles/360035890671), this data needs to be split into separate pairs per flowcell-lane. 

## Workflow assumptions

- Your input data is in the `./Fastq` working directory
- Your fastq files are named following the format `./Fastq/<sampleID>_combined_R[1|2].fastq.qz`
- You are running the conversion on NCI Gadi HPC

If any of these assumptions are not met, you will need to edit a local copy of the code according to your needs. 

## Download the code repository

Change into your working directory, then run:
```
 git clone https://github.com/Sydney-Informatics-Hub/split-GeneWiz-fastq.git
```

### Make the parallel inputs file

Run the following from your base working directory:
``` 
bash ./Scripts/split_genewiz_by_lane_make_input.sh
```

This will make 3 output directories:
1) `./Inputs` - will hold the list of inputs required to execute the tasks in parallel
2) `./Fastq_unziped` - will hold the unziped fastq files required by the perl worker script
3) `./Fastq_laneSplit` - will hold the output fastq files split into correct flowcell-lane pairs

You will typically see 3 pairs of fastq per 'combined' input file pair. 

### Submit the job

Open `./Scripts/split_genewiz_by_lane_run_parallel.pbs` and edit the resource directives for CPUs, MEM, project and storage.

Allow 1 hugemem CPU and 30 GB RAM per parallel task. Remember that jobs requiring more than 1 node must use whole nodes. If you have <= 48 tasks (lines in the Inputs file) then request this many CPUs. If you have 50 tasks, you have a few options:

Less efficient strategies:

- Submit all tasks on 48 CPU, as soon as a tasks completes the 49th, and then 50th will start
- Submit all tasks on 96 CPU, leaving 46 idle

More efficient strategies:

- Submit all tasks on 25 CPU, and double the walltime
- Create 2 input lists, one with 48 tasks and the other with 2 tasks, and submit these as 2 separate jobs with 48 and 2 CPUs respectively

Ocne you have adjusted the resources, submit with:

```
qsub ./Scripts/split_genewiz_by_lane_run_parallel.pbs  
```

This will launch parallel tasks of `./Scripts/split_genewiz_by_lane.sh`, which will perform the unzipping and then automatically run `./Scripts/split_genewiz_by_lane.pl` once the fastq are unziped.

## Outputs

Unzipped fastq in `./Fastq_unzipped` (one pair per input 'combined' pair) and new fastq file pairs in `./Fastq_laneSplit` with each fastq pair containing reads from one flowcell-lane. Expect 3 pairs of split fastq per input 'combined' fastq. 

The data will be output as unzipped, and a line count recorded. This is for the next step, which will cehck the line counts of output split fastq match that of input combined fastq.  

## Run checker

Run the checking script to confirm that the split output files contain the same number of reads as the combined input files. COMING SOON. 

## QC

As always, you should run fastQC over this data, see [SIH QC-tools](https://github.com/Sydney-Informatics-Hub/QC-tools) for helpful scripts. 
