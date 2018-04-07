from time import time
import numpy as np
import os

indir = '/hps/nobackup/stegle/users/ricard/MOFA/rebuttal/scalability/input'
outdir = '/hps/nobackup/stegle/users/ricard/MOFA/rebuttal/scalability/output/mofa'


# Default values
M = 3
K = 10
ntrials = 10
tmpFile="/hps/nobackup/stegle/users/ricard/MOFA/rebuttal/scalability/output/tmp/tmp.txt"


# Varying K
K_vals = [ 5, 10, 15, 20, 25, 30, 35, 40, 45, 50 ]
# K_vals = [ 5, 10 ]
for k in K_vals:
    inFiles = " ".join([ "%s/K/%s_%d.txt" % (indir, k, m) for m in xrange(M) ])
    likelihoods = " ".join(["gaussian"]*M)
    initTheta = " ".join(["1"]*M)
    learnTheta = " ".join(["0"]*M)
    views = " ".join([str(m) for m in xrange(M)])
    for trial in xrange(ntrials):
        outFile = "%s/K/K_%d.txt" % (outdir,k)
        cmd = "mofa --inFiles %s --outFile %s --likelihoods %s --views %s --factors %s --nostop --tolerance 0.1 --center_features" % (inFiles, outFile, likelihoods, views, k)
        cmd = "bsub -M 4096 -n 1 -q research -o %s %s" % (tmpFile, cmd)
        os.system(cmd)

# Varying D
D_vals = [ 1000, 1500, 2000, 2500, 3000, 3500, 4000, 4500, 5000 ]
for d in D_vals:
    inFiles = " ".join([ "%s/D/%s_%d.txt" % (indir, d, m) for m in xrange(M) ])
    likelihoods = " ".join(["gaussian"]*M)
    initTheta = " ".join(["1"]*M)
    learnTheta = " ".join(["0"]*M)
    views = " ".join([str(m) for m in xrange(M)])
    for trial in xrange(ntrials):
        outFile = "%s/D/D_%d.txt" % (outdir,d)
        cmd = "mofa --inFiles %s --outFile %s --likelihoods %s --views %s --factors %s --nostop --tolerance 0.1 --center_features" % (inFiles, outFile, likelihoods, views, K)
        cmd = "bsub -M 4096 -n 1 -q research -o %s %s" % (tmpFile, cmd)
        os.system(cmd)


# Varying M
M_vals = [ 1, 3, 5, 7, 9, 11, 13, 15 ]
for m in M_vals:
    inFiles = " ".join([ "%s/M/%s_%d.txt" % (indir, m, i) for i in xrange(m) ])
    likelihoods = " ".join(["gaussian"]*m)
    initTheta = " ".join(["1"]*m)
    learnTheta = " ".join(["0"]*m)
    views = " ".join([str(i) for i in xrange(m)])
    for trial in xrange(ntrials):
        outFile = "%s/M/M_%d.txt" % (outdir,m)
        cmd = "mofa --inFiles %s --outFile %s --likelihoods %s --views %s --factors %s --nostop --tolerance 0.1 --center_features" % (inFiles, outFile, likelihoods, views, K)
        cmd = "bsub -M 4096 -n 1 -q research -o %s %s" % (tmpFile, cmd)
        os.system(cmd)


# Varying N
N_vals = [ 50, 100, 150, 200, 250, 300, 350, 400, 450, 500 ]
for n in N_vals:
    inFiles = " ".join([ "%s/N/%s_%d.txt" % (indir, n, m) for m in xrange(M) ])
    likelihoods = " ".join(["gaussian"]*M)
    initTheta = " ".join(["1"]*M)
    learnTheta = " ".join(["0"]*M)
    views = " ".join([str(m) for m in xrange(M)])
    for trial in xrange(ntrials):
        outFile = "%s/N/N_%d.txt" % (outdir,n)
        cmd = "mofa --inFiles %s --outFile %s --likelihoods %s --views %s --factors %s --nostop --tolerance 0.1 --center_features" % (inFiles, outFile, likelihoods, views, K)
        cmd = "bsub -M 4096 -n 1 -q research -o %s %s" % (tmpFile, cmd)
        os.system(cmd)

