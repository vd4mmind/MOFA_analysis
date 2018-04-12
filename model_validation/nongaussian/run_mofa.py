
#########################################################################
## Script to train multiple MOFA models on simulated non-gaussian data ##
#########################################################################

import numpy as np
import os

# indir = '/Users/ricard/data/MOFA_revision/simulations/nongaussian/data'
indir = '/hps/nobackup/stegle/users/ricard/MOFA/revision/simulations/nongaussian/data'

# outdir = '/Users/ricard/data/MOFA_revision/simulations/nongaussian/results/test'
outdir = '/hps/nobackup/stegle/users/ricard/MOFA/revision/simulations/nongaussian/results'

iterations = 1000
ntrials = 25        # number of triasl correpsonding to independent data sets
ntrials_elbo = 10   # number of trials for model selection based on ELBO
M = 3

#################
## Binary data ##
#################

# Bernoulli likelihood
for trial1 in xrange(ntrials):
    inFiles = " ".join([ "%s/binary/trial%d_%d.txt" % (indir, trial1, m) for m in xrange(M) ])
    # inFiles = " ".join([ "%s/binary/trial0_%d.txt" % (indir, m) for m in xrange(M) ])
    for trial2 in xrange(ntrials_elbo):
        likelihoods = " ".join(["bernoulli"]*M)
        views = " ".join([str(m) for m in xrange(M)])
        initialFactors = 25
        outFile = "%s/binary/bernoulli_%d_%d.hdf5" % (outdir, trial1, trial2)
        cmd = "mofa --inFiles %s --outFile %s --likelihoods %s --views %s --factors %d --iter %d --dropR2 0.06 --learnIntercept --nostop --startSparsity 500 " % (inFiles, outFile, likelihoods, views, initialFactors, iterations)
        cmd = "bsub -M 2048 -n 1 -q highpri -o /homes/ricard/tmp/simulations_nongaussian_binary.out %s" % cmd
        os.system(cmd)

# Gaussian likelihood for binary data
for trial1 in xrange(ntrials):
    inFiles = " ".join([ "%s/binary/trial%d_%d.txt" % (indir, trial1, m) for m in xrange(M) ])
    # inFiles = " ".join([ "%s/binary/trial0_%d.txt" % (indir, m) for m in xrange(M) ])
    for trial2 in xrange(ntrials_elbo):
        likelihoods = " ".join(["gaussian"]*M)
        views = " ".join([str(m) for m in xrange(M)])
        initialFactors = 25
        outFile = "%s/binary/gaussian_%d_%d.hdf5" % (outdir, trial1, trial2)
        cmd = "mofa --inFiles %s --outFile %s --likelihoods %s --views %s --factors %d --iter %d --dropR2 0.06 --center_features --nostop --startSparsity 500" % (inFiles, outFile, likelihoods, views, initialFactors, iterations)
        cmd = "bsub -M 2048 -n 1 -q highpri -o /homes/ricard/tmp/simulations_nongaussian_binary.out %s" % cmd
        os.system(cmd)

################
## Count data ##
################

# Poisson likelihood
for trial1 in xrange(ntrials):
    inFiles = " ".join([ "%s/poisson/trial%d_%d.txt" % (indir, trial1, m) for m in xrange(M) ])
    # inFiles = " ".join([ "%s/poisson/trial0_%d.txt" % (indir, m) for m in xrange(M) ])
    for trial2 in xrange(ntrials_elbo):
        likelihoods = " ".join(["poisson"]*M)
        views = " ".join([str(m) for m in xrange(M)])
        initialFactors = 25
        outFile = "%s/poisson/poisson_%d_%d.hdf5" % (outdir, trial1, trial2)
        cmd = "mofa --inFiles %s --outFile %s --likelihoods %s --views %s --factors %d --iter %d --dropR2 0.06 --learnIntercept --nostop --startSparsity 500" % (inFiles, outFile, likelihoods, views, initialFactors, iterations)
        cmd = "bsub -M 2048 -n 1 -q highpri -o /homes/ricard/tmp/simulations_nongaussian_poisson.out %s" % cmd
        os.system(cmd)


# Gaussian likelihood
for trial1 in xrange(ntrials):
    inFiles = " ".join([ "%s/poisson/trial%d_%d.txt" % (indir, trial1, m) for m in xrange(M) ])
    # inFiles = " ".join([ "%s/poisson/trial0_%d.txt" % (indir, m) for m in xrange(M) ])
    for trial2 in xrange(ntrials_elbo):
        likelihoods = " ".join(["gaussian"]*M)
        views = " ".join([str(m) for m in xrange(M)])
        initialFactors = 25
        outFile = "%s/poisson/gaussian_%d_%d.hdf5" % (outdir, trial1, trial2)
        cmd = "mofa --inFiles %s --outFile %s --likelihoods %s --views %s --factors %d --iter %d --dropR2 0.06 --center_features --nostop --startSparsity 500" % (inFiles, outFile, likelihoods, views, initialFactors, iterations)
        cmd = "bsub -M 2048 -n 1 -q highpri -o /homes/ricard/tmp/simulations_nongaussian_poisson.out %s" % cmd
        os.system(cmd)
