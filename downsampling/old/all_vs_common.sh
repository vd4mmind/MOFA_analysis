#!/bin/bash

job() {
	command="bsub -M $(( $1 * 1024 )) -n $2 \
	-R \"rusage[mem=$(( $1 * 1024 ))]\" \
	-R \"rusage[tmp=5000]\" \
	-o /homes/ricard/tmp/downsample.out \
	-q $3 ${@:4}"
	echo $command
	eval $command
}

inFolder="/Users/ricard/data/CLL/views/minView=all"
# inFolder="/Users/ricard/data/CLL/views/minView=2"
# inFolder="/hps/nobackup/stegle/users/ricard/CLL/views/minView=all"
# inFolder="/hps/nobackup/stegle/users/ricard/CLL/views/minView=2"

inFiles=( "$inFolder/mut.txt" "$inFolder/viab.txt" "$inFolder/mRNA.txt" "$inFolder/meth.txt" )

likelihoods=( bernoulli gaussian gaussian gaussian )
views=( mut viab mRNA meth )
schedule=( Y SW Z AlphaW Theta Tau )

# Define number of trials and number of cores
ntrials=1
ncores=1

# Define maximum number of iterations
iter=5000

# Define lower bound frequency
elbofreq=1

# Convergence criterion
tolerance=0.001
nostop=0

# Define initial number of latent factors and how to drop them
factors=30
startDrop=999
freqDrop=9999
dropNorm=0.00
dropR2=0.00

# Define sparsity types
ardW="mk"
# ardZ=0
# learnTheta=( 0 0 0 )
learnTheta=( 1 1 1 1 )
initTheta=( 0.5 0.5 0.5 0.5 )
startSparsity=500

# Range of missing samples

# Learn the feature-wise means (only makes sense for uncentered data)
learnMean=0
center_features=1
scale_views=1

scriptdir="/Users/ricard/mofa/MOFA/run"
# scriptdir="/homes/ricard/MOFA/MOFA/run"

for trial in $(seq 1 $ntrials); do
	# outFile="/Users/ricard/data/CLL/out/test_missing/all_$trial.hdf5"
	outFile="/Users/ricard/data/CLL/out/test_missing/common_$trial.hdf5"
	cmd="python $scriptdir/template_run.py
		--inFiles ${inFiles[@]}
		--outFile $outFile
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
		--tolerance $tolerance
		--dropNorm $dropNorm
		--dropR2 $dropR2
		"
		
	if [[ $center_features -eq 1 ]]; then
		cmd="$cmd --center_features"
	fi

	if [[ $scale_views -eq 1 ]]; then
		cmd="$cmd --scale_views"
	fi

	if [[ $nostop -eq 1 ]]; then
		cmd="$cmd --nostop"
	fi

	if [[ $learnMean -eq 1 ]]; then
		cmd="$cmd --learnMean"
	fi

	echo $cmd
	eval $cmd
	# job 3 $ncores highpri $cmd
done
