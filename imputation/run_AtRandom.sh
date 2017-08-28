#!/bin/bash

job() {
	command="bsub -M $(( $1 * 1024 )) -n $2 \
	-R \"rusage[mem=$(( $1 * 1024 ))]\" \
	-R \"rusage[tmp=5000]\" \
	-q $3 ${@:4}"
	echo $command
	eval $command
}

inFolder="/hps/nobackup/stegle/users/ricard/CLL/views/minView=all"
# inFolder="/Users/ricard/data/CLL/views/all_small_noXY_alldrugs2"
# inFolder="/Users/ricard/data/CLL/views/minView=2"

inFiles=( "$inFolder/mut.txt" "$inFolder/viab.txt" "$inFolder/mRNA.txt" "$inFolder/meth.txt" )
# inFiles=( "$inFolder/mRNA.txt" "$inFolder/lincRNA.txt" "$inFolder/miRNA.txt" "$inFolder/viab.txt" )

likelihoods=( bernoulli gaussian gaussian gaussian )
views=( mut viab mRNA meth )
schedule=( Y SW Z AlphaW Theta Tau )

# Define number of trials and number of cores
ntrials=10
ncores=1

# Define maximum number of iterations
iter=2000

# Define lower bound frequency
elbofreq=1

# Convergence criterion
tolerance=0.01
nostop=0

# Define initial number of latent factors and how to drop them
factors=50
startDrop=3
freqDrop=1

# factors=25
# startDrop=9999
# freqDrop=9999
# dropR2=0.01
dropR2=0.001

# Define sparsity types
ardW="mk"
learnTheta=( 0 0 0 0 )
initTheta=( 1 1 1 1 )
startSparsity=99999

# Range of missing values to impute the drug response view
na_list=( 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.80 0.85 0.90 )
# na_list=( 0.05 0.1 )

# Learn the feature-wise means (only makes sense for uncentered data)
learnMean=1

# scriptdir="/Users/ricard/mofa/MOFA/run"
scriptdir="/homes/ricard/MOFA/MOFA/run"


for na in "${na_list[@]}"; do
	for trial in $(seq 1 $ntrials); do
		# outFile="/tmp/asd.hdf5"
		outFile="/hps/nobackup/stegle/users/ricard/CLL/out/imputation/missingAtRandom/24Aug/${na}_expr_$trial.hdf5"
		cmd="python $scriptdir/template_run.py
			--inFiles ${inFiles[@]}
			--outFile $outFile
			--delimiter ' '
			--header_cols
			--header_rows
			--likelihoods ${likelihoods[@]}
			--views ${views[@]}
			--schedule ${schedule[@]}
			--initTheta ${initTheta[@]}
			--learnTheta ${learnTheta[@]}
			--startSparsity ${startSparsity[@]}
			--ntrials 1
			--ncores $ncores
			--iter $iter
			--elbofreq $elbofreq
			--factors $factors
			--startDrop $startDrop
			--freqDrop $freqDrop
			--dropR2 $dropR2
			--tolerance $tolerance
			--maskAtRandom 0 0 $na 0
			"
			
		if [[ $nostop -eq 1 ]]; then
			cmd="$cmd --nostop"
		fi

		if [[ $learnMean -eq 1 ]]; then
			cmd="$cmd --learnMean"
		fi

		# eval $cmd
		job 3 $ncores highpri $cmd
	done
done
