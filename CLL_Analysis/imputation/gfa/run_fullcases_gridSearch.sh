#!/bin/bash

job() {
	command="bsub -M $(( $1 * 1024 )) -n $2 \
	-R \"rusage[mem=$(( $1 * 1024 ))]\" \
	-R \"rusage[tmp=2048]\" \
	-o /homes/ricard/tmp/gfa_imputation_fullcases.out \
	-q $3 ${@:4}"
	echo $command
	eval $command
}

inFolder="/hps/nobackup/stegle/users/ricard/CLL/views/minView=all"
outFolder="/hps/nobackup/stegle/users/ricard/MOFA/CLL/imputation/fullCases/gfa/grid2"
# inFolder="/Users/ricard/data/CLL/views/minView=all"
# outFolder="/Users/ricard/data/mofa/imputation"

# Define number of trials and number of cores
ntrials=5

# Define initial number of latent factors
factors=20

# Range of missing values to impute the drug response view
# na_list=( 10 25 50 75 100 )
na_list=( 10 50 )

# Script file
# script="/Users/ricard/MOFA_CLL/imputation/gfa/run_gfa.R"
script="/homes/ricard/MOFA_CLL/imputation/gfa/run_gfa.R"


for na in "${na_list[@]}"; do
	for k in $(seq 1 $factors); do
		for trial in $(seq 1 $ntrials); do
			inFiles=( "$inFolder/mut.txt" "$inFolder/viab.txt" "$inFolder/mRNA.txt" "$inFolder/meth.txt" )
			outFile="$outFolder/N${na}_K${k}_$trial.rds"
			cmd="Rscript $script
				--inFiles ${inFiles[@]}
				--outFile $outFile
				--factors $k
				--maskSamples $na
				--trial $trial
				"
			# eval $cmd
			job 2 1 research $cmd
		done
	done
done
