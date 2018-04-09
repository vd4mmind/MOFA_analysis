#!/bin/bash

job() {
	command="bsub -M $(( $1 * 1024 )) -n $2 \
	-R \"rusage[mem=$(( $1 * 1024 ))]\" \
	-R \"rusage[tmp=1000]\" \
	-o /homes/ricard/tmp/gfa_imputation_fullcases.out \
	-q $3 ${@:4}"
	echo $command
	eval $command
}

inFolder="/hps/nobackup/stegle/users/ricard/CLL/views/minView=all"
inFiles=( "$inFolder/mut.txt" "$inFolder/viab.txt" "$inFolder/mRNA.txt" "$inFolder/meth.txt" )
outFolder="/hps/nobackup/stegle/users/ricard/MOFA/CLL/imputation/fullCases/gfa/k10"

# Define number of trials and number of cores
ntrials=15

# Define initial number of latent factors
factors=10

# Range of missing samples
# na_list=( 5 10 )
na_list=( 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 )

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
			--maskSamples $na
			--trial $trial
			"
		# eval $cmd
		job 2 1 research $cmd
	done
done