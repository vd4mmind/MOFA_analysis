#!/bin/bash

job() {
	command="bsub -M $(( $1 * 1024 )) -n $2 \
	-R \"rusage[mem=$(( $1 * 1024 ))]\" \
	-R \"rusage[tmp=2048]\" \
	-o /homes/ricard/tmp/mofa_imputation_atrandom.out \
	-q $3 ${@:4}"
	echo $command
	eval $command
}

inFolder="/hps/nobackup/stegle/users/ricard/CLL/views/minView=all"
inFiles=( "$inFolder/mut.txt" "$inFolder/viab.txt" "$inFolder/mRNA.txt" "$inFolder/meth.txt" )

# outFolder="/hps/nobackup/stegle/users/ricard/CLL/out/imputation/missingAtRandom/1Sep"
outFolder="/hps/nobackup/stegle/users/ricard/MOFA/CLL/imputation/atRandom/mofa/3percent"

# Likelihoods
likelihoods=( bernoulli gaussian gaussian gaussian )

# View names
views=( mut viab mRNA meth )

# Define number of trials and number of cores
ntrials=15

# Define maximum number of iterations
iter=3000

# Convergence criterion
tolerance=0.01

# Define initial number of latent factors and how to drop them
factors=20
# dropR2=0.001
dropR2=0.03

# Define sparsity types

# without sparsity
# learnTheta=( 0 0 0 0 )
# initTheta=( 1 1 1 1 )
# startSparsity=99999

# with sparsity
learnTheta=( 1 1 1 1 )
initTheta=( 1 1 1 1 )
# startSparsity=500
startSparsity=1000

# Range of missing values to impute the drug response view
na_list=( 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 )
# na_list=( 0.05 0.1 )

# Learn the feature-wise means (only makes sense for uncentered data)
learnIntercept=0


for na in "${na_list[@]}"; do
	# tmp=$(( $ntrials + 10 ))
	# for trial in $(seq 11 $tmp); do
	for trial in $(seq 1 $ntrials); do
		outFile="$outFolder/${na}_drug_$trial.hdf5"
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
			--factors $factors
			--dropR2 $dropR2
			--tolerance $tolerance
			--maskAtRandom 0 $na 0 0
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
