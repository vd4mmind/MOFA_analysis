#!/bin/bash

job() {
	command="bsub -M $(( $1 * 1024 )) -n $2 \
	-R \"rusage[mem=$(( $1 * 1024 ))]\" \
	-R \"rusage[tmp=10000]\" \
	-o /homes/ricard/tmp/imputation_fullcases.out \
	-q $3 ${@:4}"
	echo $command
	eval $command
}

inFolder="/hps/nobackup/stegle/users/ricard/CLL/views/minView=all"
inFiles=( "$inFolder/mut.txt" "$inFolder/viab.txt" "$inFolder/mRNA.txt" "$inFolder/meth.txt" )
outFolder="/hps/nobackup/stegle/users/ricard/MOFA/CLL/imputation/fullCases/mofa/k10"

# Likelihoods
likelihoods=( bernoulli gaussian gaussian gaussian )

# View names
views=( mut viab mRNA meth )

# Define number of trials and number of cores
ntrials=15

# Define maximum number of iterations
iter=2000

# Convergence criterion
tolerance=0.01

# Define initial number of latent factors and how to drop them
# factors=15
# dropR2=0.10
factors=10
dropR2=0.00

# Define sparsity types

# without sparsity
# learnTheta=( 0 0 0 0 )
# initTheta=( 1 1 1 1 )
# startSparsity=99999

# with sparsity
learnTheta=( 1 1 1 1 )
initTheta=( 1 1 1 1 )
startSparsity=100

# Range of missing samples
# Nmasked_list=( 1 5 10 )
Nmasked_list=( 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 )


# Learn the feature-wise means (only makes sense for uncentered data)
learnIntercept=0

for Nmasked in "${Nmasked_list[@]}"; do
	# tmp=$(( $ntrials + 10 ))
	# for trial in $(seq 11 $tmp); do
	for trial in $(seq 1 $ntrials); do
		outFile="$outFolder/N${Nmasked}_drug_$trial.hdf5"
		cmd="mofa
			--inFiles ${inFiles[@]}
			--delimiter ' '
			--header_cols
			--header_rows
			--outFile $outFile
			--likelihoods ${likelihoods[@]}
			--views ${views[@]}
			--initTheta ${initTheta[@]}
			--learnTheta ${learnTheta[@]}
			--startSparsity ${startSparsity[@]}
			--iter $iter
			--factors $factors
			--dropR2 $dropR2
			--tolerance $tolerance
			--maskNSamples 0 $Nmasked 0 0
			"
			

		if [[ $learnIntercept -eq 1 ]]; then
			cmd="$cmd --learnIntercept"
		else
			cmd="$cmd --center_features"
		fi

		# echo $cmd
		# eval $cmd
		job 2 1 research $cmd
	done
done
