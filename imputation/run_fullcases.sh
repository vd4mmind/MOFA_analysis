#!/bin/bash

job() {
	command="bsub -M $(( $1 * 1024 )) -n $2 \
	-R \"rusage[mem=$(( $1 * 1024 ))]\" \
	-R \"rusage[tmp=10000]\" \
	-q $3 ${@:4}"
	echo $command
	eval $command
}

inFolder="/hps/nobackup/stegle/users/ricard/CLL/views/minView=all"

inFiles=( "$inFolder/mut.txt" "$inFolder/viab.txt" "$inFolder/mRNA.txt" "$inFolder/meth.txt" )

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
factors=15
# startDrop=9999
# freqDrop=9999
startDrop=3
freqDrop=1
dropR2=0.10

# Define sparsity types
ardW="mk"
learnTheta=( 0 0 0 0 )
initTheta=( 1 1 1 1 )
startSparsity=99999

# Range of missing samples
# Nmasked_list=( 1 5 10 )
# Nmasked_list=$(seq 1 100)
Nmasked_list=( 1 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 105 110 )

# Learn the feature-wise means (only makes sense for uncentered data)
learnMean=1

# scriptdir="/Users/ricard/mofa/MOFA/run"
scriptdir="/homes/ricard/MOFA/MOFA/run"


for Nmasked in "${Nmasked_list[@]}"; do
	for trial in $(seq 1 $ntrials); do
		outFile="/hps/nobackup/stegle/users/ricard/CLL/out/imputation/FullCases/24Aug/N${Nmasked}_expr_$trial.hdf5"
		# outFile="/hps/nobackup/stegle/users/ricard/CLL/out/imputation/FullCases/10Aug/N${Nmasked}_k5_$trial.hdf5"
		cmd="python $scriptdir/template_run.py
			--inFiles ${inFiles[@]}
			--delimiter ' '
			--header_cols
			--header_rows
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
			--dropR2 $dropR2
			--tolerance $tolerance
			--maskNSamples 0 0 $Nmasked 0
			"
			
		if [[ $nostop -eq 1 ]]; then
			cmd="$cmd --nostop"
		fi

		if [[ $learnMean -eq 1 ]]; then
			cmd="$cmd --learnMean"
		fi

		echo $cmd
		# eval $cmd
		job 3 $ncores research $cmd
	done
done
