#!/bin/bash

job() {
	command="bsub -M $(( $1 * 1024 )) -n $2 \
	-R \"rusage[mem=$(( $1 * 1024 ))]\" \
	-R \"rusage[tmp=5000]\" \
	-q $3 ${@:4}"
	echo $command
	eval $command
}

# Input files as plain text format
inFolder="/Users/ricard/data/CLL/views/minView=2"
# inFolder="/hps/nobackup/stegle/users/ricard/CLL/views/minView=2"
inFiles=( "$inFolder/mut.txt" "$inFolder/mRNA.txt" "$inFolder/meth.txt" "/Users/ricard/MOFA_CLL/imputation/examples/data/drug_masked.txt")
# inFiles=( "$inFolder/mut.txt" "$inFolder/mRNA.txt" "$inFolder/meth.txt" "/Users/ricard/MOFA_CLL/imputation/examples/data/drug_masked_all.txt")

# Options for the input files
delimiter=" " # Delimiter, such as "\t", "" or " "
header_rows=1 # Set to 1 if the files contain row names
header_cols=1 # Set to 0 if the files contain column names

# Output file
outFile=( "/Users/ricard/data/CLL/out/imputation/examples/drug_masked.hdf5" )
# outFile=( "/Users/ricard/data/CLL/out/imputation/examples/drug_masked_all.hdf5" )

# Define likelihoods
likelihoods=( bernoulli gaussian gaussian gaussian  )

# Define view names
views=( Mutation mRNA Methylation Drugs )

# Maximum number of iterations
iterations=3000

# Define the initial number of latent factors and how they are dropped during training.
# Imputing at random (just few drugs)
factors=50
dropR2=0.001
# Imputation full cases (entire assay missing)
# factors=15
# dropR2=0.10


# Run!
cmd='mofa
	--delimiter "$delimiter"
	--inFiles ${inFiles[@]}
	--outFile $outFile
	--likelihoods ${likelihoods[@]}
	--views ${views[@]}
	--iter $iterations
	--factors $factors
	--dropR2 $dropR2
	--learnMean
'
if [[ $header_rows -eq 1 ]]; then cmd="$cmd --header_rows"; fi
if [[ $header_cols -eq 1 ]]; then cmd="$cmd --header_cols"; fi

eval $cmd
# job 5 1 highpri $cmd
