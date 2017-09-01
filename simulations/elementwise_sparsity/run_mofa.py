import numpy as np
import os

# indir = '/Users/ricard/data/MOFA/simulations/26Aug/data'
indir = '/hps/nobackup/stegle/users/ricard/MOFA/simulations/data/sparsity'

# outdir = '/Users/ricard/data/MOFA/simulations/26Aug/results'
outdir = '/hps/nobackup/stegle/users/ricard/MOFA/simulations/results/sparsity'

# scriptDir="/Users/ricard/MOFA/MOFA/run"
scriptDir="/homes/ricard/MOFA/MOFA/run"

iterations = 5000
ntrials = 10


###############
## Varying D ##
###############

M=1
D_vals = [ 5000, 10000 ]

# Sparse model
for d in D_vals:
    for trial in xrange(ntrials):
        inFiles = " ".join([ "%s/D/trial%d/%d_%d.txt" % (indir, trial, d, m) for m in xrange(M) ])
        likelihoods = " ".join(["gaussian"]*M)
        learnTheta = " ".join(["1"]*M)
        initTheta = " ".join(["1"]*M)
        views = " ".join([str(m) for m in xrange(M)])
        initialFactors = 10
        # startDrop=10
        outFile = "%s/sparse/D/d_%s_%d.hdf5" % (outdir, d, trial)
        cmd = "python %s/template_run.py --inFiles %s --outFile %s --likelihoods %s --views %s --factors %d --learnTheta %s --initTheta %s --iter %d --tolerance 0.01 --schedule Y SW Z AlphaW Theta Tau --center_features" % (scriptDir, inFiles, outFile, likelihoods, views, initialFactors, learnTheta, initTheta, iterations)
        cmd = "bsub -M 2048 -n 1 -q highpri -o /homes/ricard/tmp/simulations_sparse.out %s" % cmd
        os.system(cmd)

# Non-sparse model
for d in D_vals:
    for trial in xrange(ntrials):
        inFiles = " ".join([ "%s/D/trial%d/%d_%d.txt" % (indir, trial, d, m) for m in xrange(M) ])
        likelihoods = " ".join(["gaussian"]*M)
        learnTheta = " ".join(["0"]*M)
        initTheta = " ".join(["1"]*M)
        views = " ".join([str(m) for m in xrange(M)])
        initialFactors = 10
        # startDrop=10
        outFile = "%s/nonsparse/D/d_%s_%d.hdf5" % (outdir, d, trial)
        cmd = "python %s/template_run.py --inFiles %s --outFile %s --likelihoods %s --views %s --factors %d --learnTheta %s --initTheta %s --iter %d --tolerance 0.01 --schedule Y SW Z AlphaW Theta Tau --center_features" % (scriptDir, inFiles, outFile, likelihoods, views, initialFactors, learnTheta, initTheta, iterations)
        cmd = "bsub -M 2048 -n 1 -q highpri -o /homes/ricard/tmp/simulations_nonsparse.out %s" % cmd
        os.system(cmd)

exit()

###############
## Varying M ##
###############

M_vals = [ 1, 3, 5, 10, 15, 30 ]

# Sparse model
for m in M_vals:
    for trial in xrange(ntrials):
        inFiles = " ".join([ "%s/M/trial%d/%d_%d.txt" % (indir, trial, m, mm) for mm in xrange(m) ])
        likelihoods = " ".join(["gaussian"]*m)
        learnTheta = " ".join(["1"]*m)
        initTheta = " ".join(["0.5"]*m)
        views = " ".join([str(mm) for mm in xrange(m)])
        initialFactors = 9
        # startDrop=10
        for trial in xrange(ntrials):
            outFile = "%s/sparse/M/m_%s_%d.hdf5" % (outdir, d, trial)
            cmd = "python %s/template_run.py --inFiles %s --outFile %s --likelihoods %s --views %s --factors %d --learnTheta %s --initTheta %s --startSparsity 200 --iter %d --tolerance 0.001 --schedule Y SW Z AlphaW Theta Tau --center_features --scale_features" % (scriptDir, inFiles, outFile, likelihoods, views, initialFactors, learnTheta, initTheta, iterations)
            cmd = "bsub -M 1024 -n 1 -q research -o /homes/ricard/tmp/simulations_sparse.out %s" % cmd

            print cmd
            os.system(cmd)


# Non-sparse model
for m in M_vals:
    for trial in xrange(ntrials):
        inFiles = " ".join([ "%s/M/trial%d/%d_%d.txt" % (indir, trial, m, mm) for mm in xrange(m) ])
        likelihoods = " ".join(["gaussian"]*m)
        learnTheta = " ".join(["1"]*m)
        initTheta = " ".join(["1"]*m)
        views = " ".join([str(mm) for mm in xrange(m)])
        initialFactors = 9
        # startDrop=10
        for trial in xrange(ntrials):
            outFile = "%s/nonsparse/M/m_%s_%d.hdf5" % (outdir, d, trial)
            cmd = "python %s/template_run.py --inFiles %s --outFile %s --likelihoods %s --views %s --factors %d --learnTheta %s --initTheta %s --iter %d --tolerance 0.001 --schedule Y SW Z AlphaW Theta Tau --center_features --scale_features" % (scriptDir, inFiles, outFile, likelihoods, views, initialFactors, learnTheta, initTheta, iterations)
            cmd = "bsub -M 1024 -n 1 -q research -o /homes/ricard/tmp/simulations_nonsparse.out %s" % cmd

            print cmd
            os.system(cmd)
