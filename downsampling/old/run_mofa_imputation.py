import numpy as np
import os

indir = '/hps/nobackup/stegle/users/ricard/downsample/data'
# indir = '/Users/ricard/data/CLL/out/downsample/data'

outdir = '/hps/nobackup/stegle/users/ricard/downsample/results'
# outdir = '/Users/ricard/data/CLL/out/downsample/results'

iterations = 2000
ntrials = 25
views = ["mRNA","Methylation","Drugs"]
likelihoods = ["gaussian","gaussian","gaussian"]
Nmasked = 50

## Downsampled mRNA view ##
range_downsample = range(5,100+1,5)
for n in range_downsample:
    for trial in xrange(1,ntrials+1):
        initialFactors = 10

        # Incomplete data set
        inFiles = " ".join([ "%s/mRNA/%d_%d_%s.txt" % (indir, n, trial, view) for view in views])
        outFile = "%s/mRNA/imputation_all_%d_%d.hdf5" % (outdir, n, trial)
        cmd = "mofa --inFiles %s --maskNSamples 0 0 %d --delimiter ' ' --header_cols --header_rows --outFile %s --likelihoods %s --views %s --factors %d --iter %d --tolerance 0.01 --center_features --dropR2 0.10 --startDrop 3 --freqDrop 1 " % (inFiles, Nmasked, outFile, " ".join(likelihoods), " ".join(views), initialFactors, iterations)
        cmd = "bsub -M 2048 -n 1 -q research -o /homes/ricard/tmp/downsample_mRNA_imputation.out %s" % cmd
        # os.system(cmd)

        # Imputed Complete data set
        # inFiles = " ".join([ "%s/mRNA/%d_%d_%s_imputed.txt" % (indir, n, trial, view) for view in views])
        # outFile = "%s/mRNA/imputation_common_%d_%d.hdf5" % (outdir, n, trial)
        # # cmd = "mofa --RemoveIncompleteSamples --inFiles %s --maskNSamples 0 0 %d --delimiter ' ' --header_cols --header_rows --outFile %s --likelihoods %s --views %s --factors %d --iter %d --tolerance 0.01 --center_features --dropR2 0.10 --startDrop 3 --freqDrop 1 " % (inFiles, Nmasked, outFile, " ".join(likelihoods), " ".join(views), initialFactors, iterations)
        # cmd = "mofa --inFiles %s --maskNSamples 0 0 %d --delimiter ' ' --header_cols --header_rows --outFile %s --likelihoods %s --views %s --factors %d --iter %d --tolerance 0.01 --center_features --dropR2 0.10 --startDrop 3 --freqDrop 1 " % (inFiles, Nmasked, outFile, " ".join(likelihoods), " ".join(views), initialFactors, iterations)
        # cmd = "bsub -M 2048 -n 1 -q research -o /homes/ricard/tmp/downsample_mRNA_imputation.out %s" % cmd
        # os.system(cmd)

        # Removed Complete data set
        inFiles = " ".join([ "%s/mRNA/%d_%d_%s.txt" % (indir, n, trial, view) for view in views])
        outFile = "%s/mRNA/imputation_common_%d_%d.hdf5" % (outdir, n, trial)
        # cmd = "mofa --RemoveIncompleteSamples --inFiles %s --maskNSamples 0 0 %d --delimiter ' ' --header_cols --header_rows --outFile %s --likelihoods %s --views %s --factors %d --iter %d --tolerance 0.01 --center_features --dropR2 0.10 --startDrop 3 --freqDrop 1 " % (inFiles, Nmasked, outFile, " ".join(likelihoods), " ".join(views), initialFactors, iterations)
        cmd = "mofa --inFiles %s --maskNSamples 0 0 %d --delimiter ' ' --header_cols --header_rows --outFile %s --likelihoods %s --views %s --factors %d --iter %d --tolerance 0.01 --center_features --dropR2 0.10 --startDrop 3 --freqDrop 1 " % (inFiles, Nmasked, outFile, " ".join(likelihoods), " ".join(views), initialFactors, iterations)
        cmd = "bsub -M 2048 -n 1 -q research -o /homes/ricard/tmp/downsample_mRNA_imputation.out %s" % cmd
        os.system(cmd)