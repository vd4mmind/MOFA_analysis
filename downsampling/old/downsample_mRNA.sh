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

# inFolder="/Users/ricard/data/CLL/views/minView=all"
inFolder="/hps/nobackup/stegle/users/ricard/CLL/views/minView=all"

# inFiles=( "$inFolder/mut.txt" "$inFolder/viab.txt" "$inFolder/mRNA.txt" "$inFolder/meth.txt" )
inFiles=( "$inFolder/viab.txt" "$inFolder/mRNA.txt" "$inFolder/meth.txt" )

likelihoods=( gaussian gaussian gaussian )
views=( viab mRNA meth )
schedule=( Y SW Z AlphaW Theta Tau )

# Define number of trials and number of cores
ntrials=5
ncores=1

# Define maximum number of iterations
iter=2000

# Define lower bound frequency
elbofreq=1

# Convergence criterion
tolerance=0.01
nostop=0

# Define initial number of latent factors and how to drop them
factors=20
startDrop=1
freqDrop=1
dropNorm=0.00
dropR2=0.03

# Define sparsity types
ardW="mk"
# ardZ=0
learnTheta=( 0 0 0 )
# learnTheta=( 1 1 1 )
# initTheta=( 1 1 1 )
startSparsity=500

# Range of missing samples
Nmasked_list=($(seq 0 3 100))
# Nmasked_list=($(seq 10 3 20))

# Learn the feature-wise means (only makes sense for uncentered data)
learnMean=0
center_features=1
scale_views=1

# scriptdir="/Users/ricard/mofa/MOFA/run"
scriptdir="/homes/ricard/MOFA/MOFA/run"

#######################
## Mask single views ##
#######################

for m in $(seq 0 "${#views[@]}"); do
	echo "Masking ${views[${m}]}..."
	for Nmasked in "${Nmasked_list[@]}"; do
		mask=(0 0 0)
		mask[${m}]=${Nmasked}
		for trial in $(seq 1 $ntrials); do
			outFile="/hps/nobackup/stegle/users/ricard/CLL/out/downsample/${views[${m}]}_N${Nmasked}_$trial.hdf5"
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
				--maskNSamples ${mask[@]}
				"
				
			if [[ $nostop -eq 1 ]]; then
				cmd="$cmd --nostop"
			fi

			if [[ $learnMean -eq 1 ]]; then
				cmd="$cmd --learnMean"
			fi

			echo $cmd
			# job 5 $ncores research $cmd
		done
	done
done

#######################
## Mask all views ##
#######################

# for Nmasked in "${Nmasked_list[@]}"; do
# 	for trial in $(seq 1 $ntrials); do
# 		outFile="/hps/nobackup/stegle/users/ricard/CLL/out/downsample/all_N${Nmasked}_$trial.hdf5"
# 		# outFile="/Users/ricard/data/CLL/out/downsample/all_N${Nmasked}_$trial.hdf5"
# 		cmd="python $scriptdir/template_run.py
# 			--inFiles ${inFiles[@]}
# 			--outFile $outFile
# 			--likelihoods ${likelihoods[@]}
# 			--views ${views[@]}
# 			--schedule ${schedule[@]}
# 			--initTheta ${initTheta[@]}
# 			--learnTheta ${learnTheta[@]}
# 			--startSparsity ${startSparsity[@]}
# 			--ntrials 1
# 			--ncores $ncores
# 			--iter $iter
# 			--elbofreq $elbofreq
# 			--factors $factors
# 			--startDrop $startDrop
# 			--freqDrop $freqDrop
# 			--tolerance $tolerance
# 			--dropNorm $dropNorm
# 			--dropR2 $dropR2
# 			--maskNSamples $Nmasked $Nmasked $Nmasked
# 			"
			
# 		if [[ $center_features -eq 1 ]]; then
# 			cmd="$cmd --center_features"
# 		fi

# 		if [[ $scale_views -eq 1 ]]; then
# 			cmd="$cmd --scale_views"
# 		fi

# 		if [[ $nostop -eq 1 ]]; then
# 			cmd="$cmd --nostop"
# 		fi

# 		if [[ $learnMean -eq 1 ]]; then
# 			cmd="$cmd --learnMean"
# 		fi

# 		# echo $cmd
# 		# eval $cmd
# 		job 3 $ncores highpri $cmd
# 	done
# done
