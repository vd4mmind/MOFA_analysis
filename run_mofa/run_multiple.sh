#!/bin/bash

job() {
	command="bsub -M $(( $1 * 1024 )) -n $2 \
	-R \"rusage[mem=$(( $1 * 1024 ))]\" \
	-R \"rusage[tmp=5000]\" \
	-q $3 ${@:4}"
	echo $command
	eval $command
}

# inFolder="/Users/ricard/data/CLL/views/minView=all"
inFolder="/hps/nobackup/stegle/users/ricard/CLL/views/minView=2"

inFiles=( "$inFolder/mut.txt" "$inFolder/viab.txt" "$inFolder/mRNA.txt" "$inFolder/meth.txt" )

outFiles=( 
	# "/Users/ricard/test.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/test_final/17Aug/model1.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/test_final/17Aug/model2.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/test_final/17Aug/model3.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/test_final/17Aug/model4.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/test_final/17Aug/model5.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/test_final/17Aug/model6.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/test_final/17Aug/model7.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/test_final/17Aug/model8.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/test_final/17Aug/model9.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/test_final/17Aug/model10.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/test_final/17Aug/model11.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/test_final/17Aug/model12.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/test_final/17Aug/model13.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/test_final/17Aug/model14.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/test_final/17Aug/model15.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/test_final/17Aug/model16.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/test_final/17Aug/model17.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/test_final/17Aug/model18.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/test_final/17Aug/model19.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/test_final/17Aug/model20.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/test_final/17Aug/model21.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/test_final/17Aug/model22.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/test_final/17Aug/model23.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/test_final/17Aug/model24.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/test_final/17Aug/model25.hdf5"
	)

likelihoods=( bernoulli gaussian gaussian gaussian )

# Define view names
views=( Mutations Drugs mRNA Methylation )

# Define covariates
# covariatesFile="/Users/ricard/data/CLL/views/commonPats_small_noXY_alldrugs/covariates.txt"

# Define schedule of updates
schedule=( Y SW Z AlphaW Theta Tau )
# schedule=( Y SW Z AlphaW AlphaZ Theta Tau )

# Convergence criterion
tolerance=0.01
nostop=1

# Define number of trials and number of cores
ntrials=1
ncores=1

# Define maximum number of iterations
iter=3000

# Define lower bound frequency
elbofreq=1

# Define initial number of latent factors and how to drop them
factors=30
startDrop=3
freqDrop=1
dropR2=0.05

# startDrop=999999
# freqDrop=999999
# dropR2=0.00

# Define sparsity types
ardW="mk"

# learnTheta=( 0 0 0 0 )
learnTheta=( 1 1 1 1 )
initTheta=( 1 1 1 1 )

# 
startSparsity=500

# Learn the feature-wise means (only makes sense for uncentered data)
learnMean=1

center=0
scale_views=0
scale_features=0

# scriptdir="/Users/ricard/MOFA/MOFA/run"
scriptdir="/homes/ricard/MOFA/MOFA/run"

for outfile in "${outFiles[@]}"; do

	cmd="python $scriptdir/template_run.py
	--delimiter ' '
	--header_rows
	--header_cols
	--inFiles ${inFiles[@]}
	--outFile $outfile
	--likelihoods ${likelihoods[@]}
	--views ${views[@]}
	--initTheta ${initTheta[@]}
	--learnTheta ${learnTheta[@]}
	--startSparsity ${startSparsity[@]}
	--schedule ${schedule[@]}
	--ntrials $ntrials
	--ncores 1
	--iter $iter
	--elbofreq $elbofreq
	--factors $factors
	--startDrop $startDrop
	--freqDrop $freqDrop
	--tolerance $tolerance
	--dropR2 $dropR2
	"

	if [ -n "$covariatesFile" ]; then cmd="$cmd --covariatesFile $covariatesFile"; fi

	if [[ $nostop -eq 1 ]]; then
		cmd="$cmd --nostop"
	fi

	if [[ $learnMean -eq 1 ]]; then
		cmd="$cmd --learnMean"
	fi

	if [[ $center -eq 1 ]]; then
		cmd="$cmd --center_features"
	fi

	if [[ $scale_features -eq 1 ]]; then
		cmd="$cmd --scale_features"
	fi

	if [[ $scale_views -eq 1 ]]; then
		cmd="$cmd --scale_views"
	fi

	# eval $cmd
	job 5 $ncores highpri $cmd
done

