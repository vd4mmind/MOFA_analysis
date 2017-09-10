#!/bin/bash

job() {
	command="bsub -M $(( $1 * 1024 )) -n $2 \
	-R \"rusage[mem=$(( $1 * 1024 ))]\" \
	-R \"rusage[tmp=5000]\" -o ~/tmp/sparse_models.out \
	-q $3 ${@:4}"
	echo $command
	eval $command
}

# Define I/O

inFolder="/hps/nobackup/stegle/users/ricard/CLL/views/minView=2"

inFiles=( "$inFolder/mut.txt" "$inFolder/viab.txt" "$inFolder/mRNA.txt" "$inFolder/meth.txt" )

outFiles=( 
	"/hps/nobackup/stegle/users/ricard/CLL/out/test_final/1Sep/nonsparse_model1.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/test_final/1Sep/nonsparse_model2.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/test_final/1Sep/nonsparse_model3.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/test_final/1Sep/nonsparse_model4.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/test_final/1Sep/nonsparse_model5.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/test_final/1Sep/nonsparse_model6.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/test_final/1Sep/nonsparse_model7.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/test_final/1Sep/nonsparse_model8.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/test_final/1Sep/nonsparse_model9.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/test_final/1Sep/nonsparse_model10.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/test_final/1Sep/nonsparse_model11.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/test_final/1Sep/nonsparse_model12.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/test_final/1Sep/nonsparse_model13.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/test_final/1Sep/nonsparse_model14.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/test_final/1Sep/nonsparse_model15.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/test_final/1Sep/nonsparse_model16.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/test_final/1Sep/nonsparse_model17.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/test_final/1Sep/nonsparse_model18.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/test_final/1Sep/nonsparse_model19.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/test_final/1Sep/nonsparse_model20.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/test_final/1Sep/nonsparse_model21.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/test_final/1Sep/nonsparse_model22.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/test_final/1Sep/nonsparse_model23.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/test_final/1Sep/nonsparse_model24.hdf5"
	"/hps/nobackup/stegle/users/ricard/CLL/out/test_final/1Sep/nonsparse_model25.hdf5"
	)

# Define likelihoods
likelihoods=( bernoulli gaussian gaussian gaussian )

# Define view names
views=( Mutations Drugs mRNA Methylation )

# Convergence criterion
tolerance=0.005

# Define number of trials and number of cores
ntrials=1

# Define maximum number of iterations
iter=3000

# Define initial number of latent factors and how to drop them
factors=30
startDrop=3
freqDrop=1
dropR2=0.05

# Define sparsity settings

# Sparse
# learnTheta=( 1 1 1 1 )
# initTheta=( 1 1 1 1 )
# startSparsity=500

# Not sparse
learnTheta=( 0 0 0 0 )
initTheta=( 1 1 1 1 )
startSparsity=999999

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
	--factors $factors
	--startDrop $startDrop
	--freqDrop $freqDrop
	--tolerance $tolerance
	--dropR2 $dropR2
	--learnMean
	"

	# eval $cmd
	job 3 1 research $cmd
done

