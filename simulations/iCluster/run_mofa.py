import numpy as np
import os

indir = '/Users/ricard/data/MOFA/simulations/data/iCluster'
# indir = '/hps/nobackup/stegle/users/ricard/MOFA/simulations/data/iCluster'

outdir = '/Users/ricard/data/MOFA/simulations/results/iCluster'
# outdir = '/hps/nobackup/stegle/users/ricard/MOFA/simulations/results/iCluster'

scriptDir="/Users/ricard/MOFA/MOFA/run"
# scriptDir="/homes/ricard/MOFA/MOFA/run"

iterations = 2000
# iterations = 10
ntrials = 1
M=3


K_vals = [ 5, 10, 15, 20 ]
for trial in xrange(ntrials):
	for k in K_vals:
	    inFiles = " ".join([ "%s/trial%d/%d_%d.txt" % (indir, trial, k, m) for m in xrange(M) ])
	    likelihoods = " ".join(["gaussian"]*M)
	    views = " ".join([str(m) for m in xrange(M)])
	    initialFactors = 25
	    outFile = "%s/%d_%d.hdf5" % (outdir, k, trial)
	    cmd = "python %s/template_run.py --center_features --scale_views --inFiles %s --outFile %s --likelihoods %s --views %s --factors %d --iter %d --startDrop 1 --freqDrop 1 --dropR2 0.03 --tolerance 0.05 --schedule Y SW Z AlphaW Theta Tau" % (scriptDir, inFiles, outFile, likelihoods, views, initialFactors, iterations)
	    # cmd = "bsub -M 1024 -n 1 -q research -o /homes/ricard/tmp/simulations_nongaussian_binary.out %s" % cmd
	    # print cmd
	    os.system(cmd)
