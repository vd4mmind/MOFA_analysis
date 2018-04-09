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

inFiles=( "$inFolder/mut.txt" "$inFolder/viab.txt" "$inFolder/meth.txt" )

outFiles=( 
	"/hps/nobackup/stegle/users/ricard/CLL/out/continuity/model_noexpr1.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/continuity/model_noexpr2.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/continuity/model_noexpr3.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/continuity/model_noexpr4.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/continuity/model_noexpr5.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/continuity/model_noexpr6.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/continuity/model_noexpr7.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/continuity/model_noexpr8.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/continuity/model_noexpr9.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/continuity/model_noexpr10.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/continuity/model_noexpr11.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/continuity/model_noexpr12.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/continuity/model_noexpr13.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/continuity/model_noexpr14.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/continuity/model_noexpr15.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/continuity/model_noexpr16.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/continuity/model_noexpr17.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/continuity/model_noexpr18.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/continuity/model_noexpr19.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/continuity/model_noexpr20.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/continuity/model_noexpr21.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/continuity/model_noexpr22.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/continuity/model_noexpr23.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/continuity/model_noexpr24.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/continuity/model_noexpr25.hdf5"
	)

likelihoods=( bernoulli gaussian gaussian )

# Define view names
views=( Mutations Drugs Methylation )

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

