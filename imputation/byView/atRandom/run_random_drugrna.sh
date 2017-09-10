#!/bin/bash

job() {
	command="bsub -M $(( $1 * 1024 )) -n $2 \
	-R \"rusage[mem=$(( $1 * 1024 ))]\" \
	-R \"rusage[tmp=2048]\" \
	-o /homes/ricard/tmp/imputation_random.out \
	-q $3 ${@:4}"
	echo $command
	eval $command
}

# I/O
inFolder="/hps/nobackup/stegle/users/ricard/CLL/views/minView=all"
inFiles=( "$inFolder/viab.txt" "$inFolder/mRNA.txt"  )

likelihoods=( gaussian gaussian )
views=( viab mRNA )

# Define number of trials
ntrials=10

# Define maximum number of iterations
iter=2000

# Convergence criterion
tolerance=0.01

# Define initial number of latent factors and how to drop them
factors=50
startDrop=3
freqDrop=1
dropR2=0.001

# Define sparsity
learnTheta=( 1 1 )
initTheta=( 1 1 )
startSparsity=250

# Range of missing values to impute the drug response view
na_list=( 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 )

for na in "${na_list[@]}"; do
	for trial in $(seq 1 $ntrials); do
		outFile="/hps/nobackup/stegle/users/ricard/CLL/out/imputation/missingAtRandom/7Sep/${na}_drugrna_$trial.hdf5"
		cmd="mofa
			--inFiles ${inFiles[@]}
			--outFile $outFile
			--delimiter ' '
			--header_cols
			--header_rows
			--likelihoods ${likelihoods[@]}
			--views ${views[@]}
			--initTheta ${initTheta[@]}
			--learnTheta ${learnTheta[@]}
			--startSparsity ${startSparsity[@]}
			--iter $iter
			--factors $factors
			--startDrop $startDrop
			--freqDrop $freqDrop
			--dropR2 $dropR2
			--tolerance $tolerance
			--maskAtRandom $na 0
			--learnMean
			"

		# eval $cmd
		job 2 1 research $cmd
	done
done
