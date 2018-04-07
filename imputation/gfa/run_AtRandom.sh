#!/bin/bash

job() {
	command="bsub -M $(( $1 * 1024 )) -n $2 \
	-R \"rusage[mem=$(( $1 * 1024 ))]\" \
	-R \"rusage[tmp=2048]\" \
	-o /homes/ricard/tmp/gfa_imputation_random.out \
	-q $3 ${@:4}"
	echo $command
	eval $command
}

inFolder="/hps/nobackup/stegle/users/ricard/CLL/views/minView=all"
outFolder="/hps/nobackup/stegle/users/ricard/MOFA/CLL/imputation/atRandom/gfa/k10"
# inFolder="/Users/ricard/data/CLL/views/minView=all"
# outFolder="/Users/ricard/data/mofa/imputation"

# Define number of trials and number of cores
ntrials=15

# Define initial number of latent factors
factors=10

# Range of missing values to impute the drug response view
na_list=( 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 )
# na_list=( 0.05 0.1 )

# Script file
# script="/Users/ricard/MOFA_CLL/imputation/gfa/run_gfa.R"
script="/homes/ricard/MOFA_CLL/imputation/gfa/run_gfa.R"


for na in "${na_list[@]}"; do
	for trial in $(seq 1 $ntrials); do
		inFiles=( "$inFolder/mut.txt" "$inFolder/viab.txt" "$inFolder/mRNA.txt" "$inFolder/meth.txt" )
		outFile="$outFolder/${na}_drug_$trial.rds"
		cmd="Rscript $script
			--inFiles ${inFiles[@]}
			--outFile $outFile
			--factors $factors
			--maskAtRandom $na
			--trial $trial
			"
		# eval $cmd
		job 2 1 research $cmd
	done
done
