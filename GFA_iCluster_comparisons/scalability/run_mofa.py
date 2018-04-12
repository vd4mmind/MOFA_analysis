from time import time
import numpy as np
import os
import sys
import argparse

indir = '/g/huber/users/bvelten/tmp/MOFA/runtime/withNAs/data'
outdir = '/g/huber/users/bvelten/tmp/MOFA/runtime/withNAs/out_mofa'


# Default values
M = 3
K = 10

p = argparse.ArgumentParser()
p.add_argument('--idx',type=int, required=True)
#p.add_argument('--trial',type=int, required=True)

args = p.parse_args()
#trial = args.trial
slurmidx = args.idx - 1 
idx = (slurmidx % 37)+1
trial = slurmidx // 37 +1
print(trial)
print(idx)

if idx<11:
# Varying K
    k = [ 5, 10, 15, 20, 25, 30, 35, 40, 45, 50 ][idx-1]
    inFiles = " ".join([ "%s/K/%s_%d.txt" % (indir, k, m) for m in xrange(M) ])
    likelihoods = " ".join(["gaussian"]*M)
    initTheta = " ".join(["1"]*M)
    learnTheta = " ".join(["0"]*M)
    views = " ".join([str(m) for m in xrange(M)])
    outFile = "%s/K/K_%d_%d.txt" % (outdir,k,trial)
    cmd = "mofa --inFiles %s --outFile %s --likelihoods %s --views %s --factors %s --nostop --tolerance 0.1 --center_features" % (inFiles, outFile, likelihoods, views, k)
    os.system(cmd)

elif idx<20:
# Varying D
    d = [ 1000, 1500, 2000, 2500, 3000, 3500, 4000, 4500, 5000 ][idx-11]
    inFiles = " ".join([ "%s/D/%s_%d.txt" % (indir, d, m) for m in xrange(M) ])
    likelihoods = " ".join(["gaussian"]*M)
    initTheta = " ".join(["1"]*M)
    learnTheta = " ".join(["0"]*M)
    views = " ".join([str(m) for m in xrange(M)])
    outFile = "%s/D/D_%d_%d.txt" % (outdir,d,trial)
    cmd = "mofa --inFiles %s --outFile %s --likelihoods %s --views %s --factors %s --nostop --tolerance 0.1 --center_features" % (inFiles, outFile, likelihoods, views, K)
    os.system(cmd)


elif idx<28:
    m = [ 1, 3, 5, 7, 9, 11, 13, 15 ][idx-20]
    inFiles = " ".join([ "%s/M/%s_%d.txt" % (indir, m, i) for i in xrange(m) ])
    likelihoods = " ".join(["gaussian"]*m)
    initTheta = " ".join(["1"]*m)
    learnTheta = " ".join(["0"]*m)
    views = " ".join([str(i) for i in xrange(m)])
    outFile = "%s/M/M_%d_%d.txt" % (outdir,m,trial)
    cmd = "mofa --inFiles %s --outFile %s --likelihoods %s --views %s --factors %s --nostop --tolerance 0.1 --center_features" % (inFiles, outFile, likelihoods, views, K)
    os.system(cmd)

elif idx<38:
    # Varying N
    n = [ 50, 100, 150, 200, 250, 300, 350, 400, 450, 500 ][idx-28]
    inFiles = " ".join([ "%s/N/%s_%d.txt" % (indir, n, m) for m in xrange(M) ])
    likelihoods = " ".join(["gaussian"]*M)
    initTheta = " ".join(["1"]*M)
    learnTheta = " ".join(["0"]*M)
    views = " ".join([str(m) for m in xrange(M)])
    outFile = "%s/N/N_%d_%d.txt" % (outdir,n,trial)
    cmd = "mofa --inFiles %s --outFile %s --likelihoods %s --views %s --factors %s --nostop --tolerance 0.1 --center_features" % (inFiles, outFile, likelihoods, views, K)
    os.system(cmd)

else:    
    print "Error: Index too high"
    exit()

