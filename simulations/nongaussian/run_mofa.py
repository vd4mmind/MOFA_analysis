
###########################################################################
## Script to train multiple MOFA models to test non-gaussian likelihoods ##
###########################################################################

import numpy as np
import os

# indir = '/Users/ricard/data/MOFA/simulations/data/nongaussian'
indir = '/hps/nobackup/stegle/users/ricard/MOFA/simulations/data/10Aug/nongaussian'

# outdir = '/Users/ricard/data/MOFA/simulations/results/nongaussian'
outdir = '/hps/nobackup/stegle/users/ricard/MOFA/simulations/results/nongaussian'

# scriptDir="/Users/ricard/MOFA/MOFA/run"
scriptDir="/homes/ricard/MOFA/MOFA/run"

iterations = 1500
# iterations = 10
ntrials = 10
M=3

#################
## Binary data ##
#################

# Bernoulli likelihood
for trial in xrange(ntrials):
    inFiles = " ".join([ "%s/binary/trial%d_%d.txt" % (indir, trial, m) for m in xrange(M) ])
    likelihoods = " ".join(["bernoulli"]*M)
    views = " ".join([str(m) for m in xrange(M)])
    initialFactors = 25
    outFile = "%s/binary/bernoulli_%d.hdf5" % (outdir, trial)
    cmd = "python %s/template_run.py --inFiles %s --outFile %s --likelihoods %s --views %s --factors %d --iter %d --startDrop 1 --freqDrop 1 --dropR2 0.03 --tolerance 0.05 --schedule Y SW Z AlphaW Theta Tau --learnMean" % (scriptDir, inFiles, outFile, likelihoods, views, initialFactors, iterations)
    cmd = "bsub -M 1024 -n 1 -q research -o /homes/ricard/tmp/simulations_nongaussian_binary.out %s" % cmd
    # print cmd
    os.system(cmd)


# Gaussian likelihood for binary data
for trial in xrange(ntrials):
    inFiles = " ".join([ "%s/binary/trial%d_%d.txt" % (indir, trial, m) for m in xrange(M) ])
    likelihoods = " ".join(["gaussian"]*M)
    views = " ".join([str(m) for m in xrange(M)])
    initialFactors = 25
    outFile = "%s/binary/gaussian_%d.hdf5" % (outdir, trial)
    cmd = "python %s/template_run.py --inFiles %s --outFile %s --likelihoods %s --views %s --factors %d --iter %d --startDrop 1 --freqDrop 1 --dropR2 0.03 --tolerance 0.05 --schedule Y SW Z AlphaW Theta Tau --learnMean" % (scriptDir, inFiles, outFile, likelihoods, views, initialFactors, iterations)
    cmd = "bsub -M 1024 -n 1 -q research -o /homes/ricard/tmp/simulations_nongaussian_binary.out %s" % cmd
    # print cmd
    os.system(cmd)


################
## Count data ##
################

# Poisson likelihood
for trial in xrange(ntrials):
    inFiles = " ".join([ "%s/poisson/trial%d_%d.txt" % (indir, trial, m) for m in xrange(M) ])
    likelihoods = " ".join(["poisson"]*M)
    views = " ".join([str(m) for m in xrange(M)])
    initialFactors = 25
    outFile = "%s/poisson/poisson_%d.hdf5" % (outdir, trial)
    cmd = "python %s/template_run.py --inFiles %s --outFile %s --likelihoods %s --views %s --factors %d --iter %d --startDrop 1 --freqDrop 1 --dropR2 0.03 --tolerance 0.05 --schedule Y SW Z AlphaW Theta Tau --learnMean" % (scriptDir, inFiles, outFile, likelihoods, views, initialFactors, iterations)
    cmd = "bsub -M 1024 -n 1 -q research -o /homes/ricard/tmp/simulations_nongaussian_count.out %s" % cmd
    # print cmd
    os.system(cmd)


# Gaussian likelihood
for trial in xrange(ntrials):
    inFiles = " ".join([ "%s/poisson/trial%d_%d.txt" % (indir, trial, m) for m in xrange(M) ])
    likelihoods = " ".join(["gaussian"]*M)
    views = " ".join([str(m) for m in xrange(M)])
    initialFactors = 25
    outFile = "%s/poisson/gaussian_%d.hdf5" % (outdir, trial)
    cmd = "python %s/template_run.py --inFiles %s --outFile %s --likelihoods %s --views %s --factors %d --iter %d --startDrop 1 --freqDrop 1 --dropR2 0.03 --tolerance 0.05 --schedule Y SW Z AlphaW Theta Tau --learnMean" % (scriptDir, inFiles, outFile, likelihoods, views, initialFactors, iterations)
    cmd = "bsub -M 1024 -n 1 -q research -o /homes/ricard/tmp/simulations_nongaussian_count.out %s" % cmd
    # print cmd
    os.system(cmd)