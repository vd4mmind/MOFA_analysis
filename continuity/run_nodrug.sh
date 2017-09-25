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

inFiles=( "$inFolder/mut.txt" "$inFolder/mRNA.txt" "$inFolder/meth.txt" )

outFiles=( 
	"/hps/nobackup/stegle/users/ricard/CLL/out/continuity/model1.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/continuity/model2.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/continuity/model3.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/continuity/model4.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/continuity/model5.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/continuity/model6.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/continuity/model7.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/continuity/model8.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/continuity/model9.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/continuity/model10.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/continuity/model11.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/continuity/model12.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/continuity/model13.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/continuity/model14.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/continuity/model15.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/continuity/model16.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/continuity/model17.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/continuity/model18.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/continuity/model19.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/continuity/model20.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/continuity/model21.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/continuity/model22.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/continuity/model23.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/continuity/model24.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/continuity/model25.hdf5"
	)

likelihoods=( bernoulli gaussian gaussian )

# Define view names
views=( Mutations mRNA Methylation )

# Convergence criterion
tolerance=0.01

# Define number of trials and number of cores
ntrials=1
ncores=1

# Define maximum number of iterations
iter=3000

# Define lower bound frequency
elbofreq=1

# Define initial number of latent factors and how to drop them
factors=20
startDrop=3
freqDrop=1
dropR2=0.05

# Define sparsity 
learnTheta=( 1 1 1 )
initTheta=( 1 1 1 )
startSparsity=300

for outfile in "${outFiles[@]}"; do

	cmd="mofa
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
	--ntrials $ntrials
	--iter $iter
	--elbofreq $elbofreq
	--factors $factors
	--startDrop $startDrop
	--freqDrop $freqDrop
	--tolerance $tolerance
	--dropR2 $dropR2
	--learnMean
	"

	# eval $cmd
	job 3 $ncores highpri $cmd
done

