#!/bin/bash

job() {
	command="bsub -M $(( $1 * 1024 )) -n $2 \
	-R \"rusage[mem=$(( $1 * 1024 ))]\" \
	-R \"rusage[tmp=2048]\" \
	-o /homes/ricard/tmp/imputation_fullcases.out \
	-q $3 ${@:4}"
	echo $command
	eval $command
}

inFolder="/hps/nobackup/stegle/users/ricard/CLL/views/minView=all"
inFiles=( "$inFolder/viab.txt" "$inFolder/mRNA.txt" "$inFolder/meth.txt" )

likelihoods=( gaussian gaussian gaussian )
views=( viab mRNA meth )

# Define number of trials
ntrials=10

# Define maximum number of iterations
iter=2000

# Define lower bound frequency
elbofreq=1

# Convergence criterion
tolerance=0.01

# Define initial number of latent factors and how to drop them
factors=15
startDrop=3
freqDrop=1
dropR2=0.10

# Define sparsity types

# without sparsity
# learnTheta=( 0 0 0 0 )
# initTheta=( 1 1 1 1 )
# startSparsity=99999

# with sparsity
learnTheta=( 1 1 1 )
initTheta=( 1 1 1 )
startSparsity=500

# Range of missing samples
Nmasked_list=( 10 15 20 25 30 35 40 45 50 55 60 65 70 75 )

for Nmasked in "${Nmasked_list[@]}"; do
	for trial in $(seq 1 $ntrials); do
		outFile="/hps/nobackup/stegle/users/ricard/CLL/out/imputation/FullCases/7Sep/N${Nmasked}_nomut_$trial.hdf5"
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
			--elbofreq $elbofreq
			--factors $factors
			--startDrop $startDrop
			--freqDrop $freqDrop
			--dropR2 $dropR2
			--tolerance $tolerance
			--maskNSamples $Nmasked 0 0
			--learnMean
			"
			
		# echo $cmd
		# eval $cmd
		job 2 1 research $cmd
	done
done
