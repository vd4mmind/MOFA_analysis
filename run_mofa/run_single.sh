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
# inFolder="/Users/ricard/data/CLL/views/minView=2"

inFiles=( "$inFolder/mut.txt" "$inFolder/viab.txt" "$inFolder/mRNA.txt" "$inFolder/meth.txt" )

outFile=( "/homes/ricard/test/test_k20.hdf5" )
# outFile=( "/hps/nobackup/stegle/users/ricard/CLL/out/test_final/commonPats_big_k15_test1.hdf5" )
# outFile=( "/hps/nobackup/stegle/users/ricard/CLL/out/test_final/commonPats_big_k15_test5.hdf5" )
# outFile=( "/Users/ricard/test/test.hdf5" )

likelihoods=( bernoulli gaussian gaussian gaussian )

# Define view names
views=( Mutation Drugs mRNA Methylation )

# Define covariates
# covariatesFile="/Users/ricard/data/CLL/views/commonPats_small/covariates.txt"

# Define schedule of updates
schedule=( Y SW Z AlphaW Theta Tau )

# Convergence criterion
tolerance=0.01
nostop=0

# Define maximum number of iterations
iter=3000

# Define lower bound frequency
elbofreq=1

# Define initial number of latent factors and how to drop them
factors=20
# startDrop=3
# freqDrop=1
startDrop=999999
freqDrop=999999
dropR2=0.00

# Define sparsity types
learnTheta=( 1 1 1 1 )
initTheta=( 1 1 1 1 )

startSparsity=250

# Learn the feature-wise means (only makes sense for uncentered data)
learnMean=1

# Parse the data
center_features=0
scale_views=0

# scriptdir="/Users/ricard/MOFA/MOFA/run"
scriptdir="/homes/ricard/MOFA/MOFA/run"

cmd="python $scriptdir/template_run.py
	--delimiter ' '
	--header_rows
	--header_cols
	--inFiles ${inFiles[@]}
	--outFile $outFile
	--likelihoods ${likelihoods[@]}
	--views ${views[@]}
	--schedule ${schedule[@]}
	--iter $iter
	--learnTheta ${learnTheta[@]}
	--initTheta ${initTheta[@]}
	--startSparsity ${startSparsity[@]}
	--elbofreq $elbofreq
	--startDrop $startDrop
	--freqDrop $freqDrop
	--tolerance $tolerance
	--factors $factors
	--dropR2 $dropR2
"

if [ -n "$covariatesFile" ]; then cmd="$cmd --covariatesFile $covariatesFile"; fi

if [[ $center_features -eq 1 ]]; then
	cmd="$cmd --center_features"
fi

if [[ $scale_features -eq 1 ]]; then
	cmd="$cmd --scale_features"
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

# eval $cmd
job 5 1 highpri $cmd

