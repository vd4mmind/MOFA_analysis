import numpy as np
import os

indir = '/homes/ricard/MOFA/MOFA/test/scalability/data'
outdir = '/homes/ricard/MOFA/MOFA/test/scalability/results'


iterations = 100
ntrials = 5
scriptDir="/homes/ricard/MOFA/MOFA/run"


# Varying K
M=3
K_vals = np.linspace(5.0, 99.0, num=20, dtype=int)
for factors in K_vals:
    inFiles = " ".join([ "%s/K/%s_%d.txt" % (indir, factors, m) for m in xrange(M) ])
    likelihoods = " ".join(["gaussian"]*M)
    initTheta = " ".join(["1"]*M)
    learnTheta = " ".join(["0"]*M)
    views = " ".join([str(m) for m in xrange(M)])
    for trial in xrange(ntrials):
        outFile = "%s/K/k_%s_%d.txt" % (outdir,factors, trial)
        cmd = "python %s/template_run.py --inFiles %s --outFile %s --likelihoods %s --views %s --factors %s --iter %d --nostop --schedule Y SW AlphaW Theta Tau" % (scriptDir, inFiles, outFile, likelihoods, views, factors, iterations)
        cmd = "bsub -M 1024 -n 1 -q research %s" % cmd
        print cmd
        os.system(cmd)


print "\n"


# Varying M
M_vals = np.linspace(2.0, 20.0, num=20, dtype=int)
factors = 20
for M in M_vals:
    inFiles = " ".join([ "%s/M/%s_%d.txt" % (indir, M, m) for m in xrange(M) ])
    likelihoods = " ".join(["gaussian"]*M)
    initTheta = " ".join(["1"]*M)
    learnTheta = " ".join(["0"]*M)
    views = " ".join([str(m) for m in xrange(M)])
    for trial in xrange(ntrials):
        outFile = "%s/M/M_%d_%d.txt" % (outdir,M,trial)
        cmd = "python %s/template_run.py --inFiles %s --outFile %s --likelihoods %s --views %s --factors %s --iter %d --nostop --schedule Y SW AlphaW Theta Tau" % (scriptDir, inFiles, outFile, likelihoods, views, factors, iterations)
        cmd = "bsub -M 1024 -n 1 -q research %s" % cmd
        print cmd
        os.system(cmd)


print "\n"


# Varying N
N_vals = np.linspace(100.0, 2000.0, num=20, dtype=int)
M=3
for N in N_vals:
    inFiles = " ".join([ "%s/N/%s_%d.txt" % (indir, N, m) for m in xrange(M) ])
    likelihoods = " ".join(["gaussian"]*M)
    initTheta = " ".join(["1"]*M)
    learnTheta = " ".join(["0"]*M)
    views = " ".join([str(m) for m in xrange(M)])
    for trial in xrange(ntrials):
        outFile = "%s/N/N_%d_%d.txt" % (outdir,N,trial)
        cmd = "python %s/template_run.py --inFiles %s --outFile %s --likelihoods %s --views %s --factors %s --iter %d --nostop --schedule Y SW AlphaW Theta Tau" % (scriptDir, inFiles, outFile, likelihoods, views, factors, iterations)
        cmd = "bsub -M 1024 -n 1 -q research %s" % cmd
        print cmd
        os.system(cmd)


print "\n"


# Varying D
D_vals = np.linspace(500.0, 10000.0, num=20, dtype=int)
M=3
for D in D_vals:
    inFiles = " ".join([ "%s/D/%s_%d.txt" % (indir, D, m) for m in xrange(M) ])
    likelihoods = " ".join(["gaussian"]*M)
    initTheta = " ".join(["1"]*M)
    learnTheta = " ".join(["0"]*M)
    views = " ".join([str(m) for m in xrange(M)])
    for trial in xrange(ntrials):
        outFile = "%s/D/D_%d_%d.txt" % (outdir,D,trial)
        cmd = "python %s/template_run.py --inFiles %s --outFile %s --likelihoods %s --views %s --factors %s --iter %d --nostop --schedule Y SW AlphaW Theta Tau" % (scriptDir, inFiles, outFile, likelihoods, views, factors, iterations)
        cmd = "bsub -M 1024 -n 1 -q research %s" % cmd
        print cmd
        os.system(cmd)


