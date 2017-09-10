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

# I/O
inFolder="/hps/nobackup/stegle/users/ricard/CLL/views/minView=all"
inFiles=( "$inFolder/viab.txt" "$inFolder/mut.txt" "$inFolder/mRNA.txt" "$inFolder/meth.txt" )

likelihoods=( gaussian bernoulli gaussian gaussian )
views=( viab mut mRNA meth )

# Define number of trials
ntrials=10

# Define maximum number of iterations
iter=2000

# Convergence criterion
tolerance=0.01

# Define initial number of latent factors and how to drop them
factors=10
startDrop=3
freqDrop=1
dropR2=0.05

# Define sparsity types
learnTheta=( 1 1 1 1 )
initTheta=( 1 1 1 1 )
startSparsity=500

# Range of missing samples
Nmasked_list=( 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 )
# Nmasked_list=( 10 15 20 25 30 35 40 45 50 55 60 65 70 75 )

for Nmasked in "${Nmasked_list[@]}"; do
	tmp=$(( $ntrials + 10 ))
	for trial in $(seq 11 $tmp); do
	# for trial in $(seq 1 $ntrials); do
		outFile="/hps/nobackup/stegle/users/ricard/CLL/out/imputation/FullCases/7Sep/${Nmasked}_viabrnametmut_$trial.hdf5"
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
			--startDrop $startDrop
			--freqDrop $freqDrop
			--dropR2 $dropR2
			--tolerance $tolerance
			--maskNSamples $Nmasked 0 0 0
			--learnMean
			"
			
		# eval $cmd
		job 2 1 research $cmd
	done
done
