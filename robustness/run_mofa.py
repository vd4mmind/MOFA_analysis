
"""
Robustness under subsampling
"""

import numpy as np
import os

indir = '/hps/nobackup/stegle/users/ricard/robustness/data'
outdir = '/hps/nobackup/stegle/users/ricard/robustness/results'

iterations = 2000
ntrials = 25
views = ["mRNA","Methylation","Drugs","Mutations"]
likelihoods = ["gaussian","gaussian","gaussian","bernoulli"]

# range_downsample = range(29,50+1)
range_downsample = range(76,100+1)
for n in range_downsample:
    for trial in xrange(1,ntrials+1):
        inFiles = " ".join([ "%s/%d_%d_%s.txt" % (indir,n,trial,view) for view in views])
        initialFactors = 15
        outFile = "%s/%d_%d.hdf5" % (outdir, n, trial)
        cmd = "mofa --inFiles %s --delimiter ' ' --header_cols --header_rows --outFile %s --likelihoods %s --views %s --factors %d --iter %d --tolerance 0.01 --center_features --dropR2 0.05 --startDrop 3 --freqDrop 1 " % (inFiles, outFile, " ".join(likelihoods), " ".join(views), initialFactors, iterations)
        cmd = "bsub -M 2048 -n 1 -q research -o /homes/ricard/tmp/robustness.out %s" % cmd
        os.system(cmd)
