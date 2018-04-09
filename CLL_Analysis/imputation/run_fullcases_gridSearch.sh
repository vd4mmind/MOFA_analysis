#!/bin/bash

job() {
	command="bsub -M $(( $1 * 1024 )) -n $2 \
	-R \"rusage[mem=$(( $1 * 1024 ))]\" \
	-R \"rusage[tmp=2048]\" \
	-o /homes/ricard/tmp/mofa_imputation_fullcases.out \
	-q $3 ${@:4}"
	echo $command
	eval $command
}

inFolder="/hps/nobackup/stegle/users/ricard/CLL/views/minView=all"
inFiles=( "$inFolder/mut.txt" "$inFolder/viab.txt" "$inFolder/mRNA.txt" "$inFolder/meth.txt" )
outFolder="/hps/nobackup/stegle/users/ricard/MOFA/CLL/imputation/fullCases/mofa/grid"

# Likelihoods
likelihoods=( bernoulli gaussian gaussian gaussian )

# View names
views=( mut viab mRNA meth )

# Define number of trials and number of cores
ntrials=5

# Define maximum number of iterations
iter=3000

# Convergence criterion
tolerance=0.01

# Define range of factors
factors=20
dropR2=0.00

# Define sparsity types

# without sparsity
# learnTheta=( 0 0 0 0 )
# initTheta=( 1 1 1 1 )
# startSparsity=99999

# with sparsity
learnTheta=( 1 1 1 1 )
initTheta=( 1 1 1 1 )
# startSparsity=500
startSparsity=100

# Range of missing values to impute the drug response view
# na_list=( 10 25 50 75 100 )
na_list=( 10 50 )

# Learn the feature-wise means (only makes sense for uncentered data)
learnIntercept=0


for na in "${na_list[@]}"; do
	for k in $(seq 1 $factors); do
		for trial in $(seq 1 $ntrials); do
			outFile="$outFolder/N${na}_${k}_$trial.hdf5"
			# cmd="python $scriptdir/template_run.py
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
				--factors $k
				--dropR2 $dropR2
				--tolerance $tolerance
				--maskNSamples 0 $na 0 0
				"
				
			if [[ $learnIntercept -eq 1 ]]; then
				cmd="$cmd --learnIntercept"
			else
				cmd="$cmd --center_features"
			fi

			# eval $cmd
			job 2 1 research $cmd
		done
	done
done
