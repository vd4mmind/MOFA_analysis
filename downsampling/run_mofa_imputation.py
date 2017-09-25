
"""
Script to run MOFA for imputation in downsampling analysis
"""

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

## Normal models ##
range_downsample = range(0,100+1,5)
for n in range_downsample:
    for trial in xrange(1,ntrials+1):
        initialFactors = 15

        # Incomplete data set -> Incomplete model
        inFiles = " ".join([ "%s/%d_%d_%s_incomplete.txt" % (indir, n, trial, view) for view in views])
        outFile = "%s/imputation_incompleteD_incompleteM_%d_%d.hdf5" % (outdir, n, trial)
        cmd = "mofa --maskNSamples 0 0 %d --inFiles %s --delimiter ' ' --header_cols --header_rows --outFile %s --likelihoods %s --views %s --factors %d --iter %d --tolerance 0.01 --center_features --dropR2 0.10 --startDrop 3 --freqDrop 1 " % (Nmasked, inFiles, outFile, " ".join(likelihoods), " ".join(views), initialFactors, iterations)
        cmd = "bsub -M 2048 -n 1 -q research -o /homes/ricard/tmp/downsample_incompleteD_incompleteM.out %s" % cmd
        os.system(cmd)

        # Incomplete data set -> Complete model
        inFiles = " ".join([ "%s/%d_%d_%s_incomplete.txt" % (indir, n, trial, view) for view in views])
        outFile = "%s/imputation_incompleteD_completeM_%d_%d.hdf5" % (outdir, n, trial)
        cmd = "mofa --maskNSamples 0 0 %d --RemoveIncompleteSamples --inFiles %s --delimiter ' ' --header_cols --header_rows --outFile %s --likelihoods %s --views %s --factors %d --iter %d --tolerance 0.01 --center_features --dropR2 0.10 --startDrop 3 --freqDrop 1 " % (Nmasked, inFiles, outFile, " ".join(likelihoods), " ".join(views), initialFactors, iterations)
        cmd = "bsub -M 2048 -n 1 -q research -o /homes/ricard/tmp/downsample_incompleteD_completeM.out %s" % cmd
        os.system(cmd)

        # Complete data set -> Incomplete model
        inFiles = " ".join([ "%s/%d_%d_%s_complete.txt" % (indir, n, trial, view) for view in views])
        outFile = "%s/imputation_completeD_incompleteM_%d_%d.hdf5" % (outdir, n, trial)
        cmd = "mofa --maskNSamples 0 0 %d --inFiles %s --delimiter ' ' --header_cols --header_rows --outFile %s --likelihoods %s --views %s --factors %d --iter %d --tolerance 0.01 --center_features --dropR2 0.10 --startDrop 3 --freqDrop 1 " % (Nmasked, inFiles, outFile, " ".join(likelihoods), " ".join(views), initialFactors, iterations)
        cmd = "bsub -M 2048 -n 1 -q research -o /homes/ricard/tmp/downsample_completeD_incompleteM.out %s" % cmd
        os.system(cmd)

        # Complete data set -> Complete model
        inFiles = " ".join([ "%s/%d_%d_%s_complete.txt" % (indir, n, trial, view) for view in views])
        outFile = "%s/imputation_completeD_completeM_%d_%d.hdf5" % (outdir, n, trial)
        cmd = "mofa --maskNSamples 0 0 %d --RemoveIncompleteSamples --inFiles %s --delimiter ' ' --header_cols --header_rows --outFile %s --likelihoods %s --views %s --factors %d --iter %d --tolerance 0.01 --center_features --dropR2 0.10 --startDrop 3 --freqDrop 1 " % (Nmasked, inFiles, outFile, " ".join(likelihoods), " ".join(views), initialFactors, iterations)
        cmd = "bsub -M 2048 -n 1 -q research -o /homes/ricard/tmp/downsample_completeD_completeM.out %s" % cmd
        os.system(cmd)

        # Incomplete imputed data set
        inFiles = " ".join([ "%s/%d_%d_%s_incomplete_imputed.txt" % (indir, n, trial, view) for view in views])
        outFile = "%s/imputation_incomplete_imputed_%d_%d.hdf5" % (outdir, n, trial)
        cmd = "mofa --maskNSamples 0 0 %d --inFiles %s --delimiter ' ' --header_cols --header_rows --outFile %s --likelihoods %s --views %s --factors %d --iter %d --tolerance 0.01 --center_features --dropR2 0.10 --startDrop 3 --freqDrop 1 " % (Nmasked, inFiles, outFile, " ".join(likelihoods), " ".join(views), initialFactors, iterations)
        cmd = "bsub -M 2048 -n 1 -q research -o /homes/ricard/tmp/downsample_incomplete_imputed.out %s" % cmd
        os.system(cmd)

        # Complete imputed data set
        inFiles = " ".join([ "%s/%d_%d_%s_complete_imputed.txt" % (indir, n, trial, view) for view in views])
        outFile = "%s/imputation_complete_imputed_%d_%d.hdf5" % (outdir, n, trial)
        cmd = "mofa --maskNSamples 0 0 %d --inFiles %s --delimiter ' ' --header_cols --header_rows --outFile %s --likelihoods %s --views %s --factors %d --iter %d --tolerance 0.01 --center_features --dropR2 0.10 --startDrop 3 --freqDrop 1 " % (Nmasked, inFiles, outFile, " ".join(likelihoods), " ".join(views), initialFactors, iterations)
        cmd = "bsub -M 2048 -n 1 -q research -o /homes/ricard/tmp/downsample_complete_imputed.out %s" % cmd
        os.system(cmd)

exit()
