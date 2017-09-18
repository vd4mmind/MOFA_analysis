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

# Define I/O
inFolder="/hps/nobackup/stegle/users/ricard/CLL/views/minView=all"
inFiles=( "$inFolder/viab.txt" )

# Define view names
views=( viab )

# Define likelihoods
likelihoods=( gaussian )

# Define number of trials
ntrials=10

# Define maximum number of iterations
iter=2000

# Define lower bound frequency
elbofreq=1

# Convergence criterion
tolerance=0.01
nostop=0

# Define initial number of latent factors and how to drop them
factors=25
startDrop=3
freqDrop=1
dropR2=0.001

# Define sparsity types

# without sparsity
# learnTheta=( 0 0 0 0 )
# initTheta=( 1 1 1 1 )
# startSparsity=99999

# with sparsity
learnTheta=( 1 )
initTheta=( 1 )
startSparsity=100

# Range of missing values to impute the drug response view
na_list=( 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 )

# Learn the feature-wise means (only makes sense for uncentered data)
learnMean=1


for na in "${na_list[@]}"; do
	# tmp=$(( $ntrials + 10 ))
	# for trial in $(seq 11 $tmp); do
	for trial in $(seq 1 $ntrials); do
		outFile="/hps/nobackup/stegle/users/ricard/CLL/out/imputation/missingAtRandom/6Sep/${na}_drug_$trial.hdf5"
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
			--elbofreq $elbofreq
			--factors $factors
			--startDrop $startDrop
			--freqDrop $freqDrop
			--dropR2 $dropR2
			--tolerance $tolerance
			--maskAtRandom $na
			"
			
		if [[ $learnMean -eq 1 ]]; then cmd="$cmd --learnMean"; fi

		# eval $cmd
		job 1 1 research $cmd
	done
done
