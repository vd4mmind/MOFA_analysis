import numpy as np
import os

# indir = '/Users/ricard/data/MOFA/simulations/data/R2'
indir = '/hps/nobackup/stegle/users/ricard/MOFA/simulations/data/R2/mofa'

# outdir = '/Users/ricard/data/MOFA/simulations/results/R2'
outdir = '/hps/nobackup/stegle/users/ricard/MOFA/simulations/results/R2'

ntrials = 1
M=3


K_vals = [ 10, 15, 20 ]
for trial in xrange(ntrials):
	for k in K_vals:
	    # inFiles = " ".join([ "%s/trial%d/%d_%d.txt" % (indir, trial, k, m) for m in xrange(M) ])
	    inFiles = " ".join([ "%s/%d_%d.txt" % (indir, k, m) for m in xrange(M) ])
	    likelihoods = " ".join(["gaussian"]*M)
	    views = " ".join([str(m) for m in xrange(M)])
	    initialFactors = 25
	    # initialFactors = k
	    outFile = "%s/Ktrue%d_Kinitial%d_trial%d.hdf5" % (outdir, k, initialFactors, trial)
	    # cmd = "mofa --center_features --scale_views --inFiles %s --outFile %s --likelihoods %s --views %s --factors %d --iter %d --dropR2 0.03" % (scriptDir, inFiles, outFile, likelihoods, views, initialFactors, iterations)
	    cmd = "mofa --center_features --scale_views --inFiles %s --outFile %s --likelihoods %s --views %s --factors %d" % (inFiles, outFile, likelihoods, views, initialFactors)
	    cmd = "bsub -M 1024 -n 1 -q research -o /homes/ricard/tmp/simulations_R2.out %s" % cmd
	    os.system(cmd)
