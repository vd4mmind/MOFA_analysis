#!/bin/bash

job() {
	command="bsub -M $(( $1 * 1024 )) -n $2 \
	-R \"rusage[mem=$(( $1 * 1024 ))]\" \
	-R \"rusage[tmp=2048]\" \
	-o /homes/ricard/tmp/icluster_simulations.out \
	-q $3 ${@:4}"
	echo $command
	eval $command
}

# inFolder="/Users/ricard/data/MOFA_revision/simulations/joint/data"
# outFolder="/Users/ricard/data/MOFA_revision/simulations/joint/results"

inFolder="/hps/nobackup/stegle/users/ricard/MOFA/revision/simulations/joint/data"
outFolder="/hps/nobackup/stegle/users/ricard/MOFA/revision/simulations/joint/results"

# views
views=( gaussian bernoulli poisson )

# Likelihoods
likelihoods=( gaussian binomial poisson )

# Define number of trials and number of cores
# trials=5

# Define maximum number of factors
factors=20

# Number of cores
cores=5

# Script file
script="/homes/ricard/mofa_rebuttal/gfa_comparison/simulations/run_icluster.R"
# script="/Users/ricard/mofa_rebuttal/gfa_comparison/simulations/run_icluster.R"

ntrials=$(($trials-1))
# for trial in $(seq 1 $trials); do
for trial in $(seq 10 11); do
	for k in $(seq 10 $factors); do
		inFiles=( "$inFolder/trial${trial}_0.txt" "$inFolder/trial${trial}_1.txt" "$inFolder/trial${trial}_2.txt" )
		outFile="$outFolder/icluster_simulation_nongaussian_${trial}_${k}.rds"
		cmd="Rscript $script
			--inFiles ${inFiles[@]}
			--outFile $outFile
			--factors $k
			--views ${views[@]}
			--likelihoods ${likelihoods[@]}
			--cores $cores
			"
		# eval $cmd
		job 3 $cores highpri $cmd
	done
done
