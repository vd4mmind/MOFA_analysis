
##########################################
## Script to train multiple MOFA models ##
##########################################

import numpy as np
import os

# indir = '/Users/ricard/data/MOFA/simulations/data'
# indir = '/homes/ricard/CLL/simulations/data'
indir = '/hps/nobackup/stegle/users/ricard/MOFA/simulations/data/learnK'

# outdir = '/Users/ricard/test'
# outdir = '/homes/ricard/CLL/simulations/results'
outdir = '/hps/nobackup/stegle/users/ricard/MOFA/simulations/results/learnK'

# scriptDir="/Users/ricard/MOFA/MOFA/run"
scriptDir="/homes/ricard/MOFA/MOFA/run"

iterations = 2000
ntrials = 10


# Varying the number of factors (K)
M=3
# K_vals = [ 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25 ]
K_vals = range(5,75+1,2)
for factors in K_vals:
    for trial in xrange(ntrials):
        inFiles = " ".join([ "%s/K/trial%d/%d_%d.txt" % (indir, trial, factors, m) for m in xrange(M) ])
        likelihoods = " ".join(["gaussian"]*M)
        views = " ".join([str(m) for m in xrange(M)])
        initialFactors = 50
        outFile = "%s/K/k_%s_%d.hdf5" % (outdir, factors, trial)
        cmd = "python %s/template_run.py --inFiles %s --outFile %s --likelihoods %s --views %s --factors %d --iter %d --startDrop 1 --freqDrop 1 --dropR2 0.01 --tolerance 0.05 --schedule Y SW Z AlphaW Theta Tau --center_features --scale_views" % (scriptDir, inFiles, outFile, likelihoods, views, initialFactors, iterations)
        cmd = "bsub -M 2048 -n 1 -q research -o /homes/ricard/tmp/simulations_learnK_varyK.out %s" % cmd
        # print cmd
        # os.system(cmd)


# Varying the number of features (D)
M = 3
# D_vals = [ 100, 500, 1000, 1500, 2000, 2500, 3000, 3500, 4000, 4500, 5000, 5500, 6000, 6500, 7000, 7500, 8000, 8500, 9000, 9500, 10000 ]
D_vals = [ 10000, 15000, 20000, 25000 ]
for d in D_vals:
    for trial in xrange(ntrials):
        inFiles = " ".join([ "%s/D/trial%d/%d_%d.txt" % (indir, trial, d, m) for m in xrange(M) ])
        likelihoods = " ".join(["gaussian"]*M)
        views = " ".join([str(m) for m in xrange(M)])
        initialFactors = 50
        outFile = "%s/D/%d_%d.hdf5" % (outdir, d, trial)
        cmd = "python %s/template_run.py --inFiles %s --outFile %s --likelihoods %s --views %s --factors %d --iter %d --startDrop 1 --freqDrop 1 --dropR2 0.03 --tolerance 0.05 --schedule Y SW Z AlphaW Theta Tau --center_features --scale_views" % (scriptDir, inFiles, outFile, likelihoods, views, initialFactors, iterations)
        cmd = "bsub -M 4096 -n 1 -q research -o /homes/ricard/tmp/simulations_learnK_varyD.out %s" % cmd
        # print cmd
        os.system(cmd)


# Varying the number of views (M)
# M_vals = [ 1, 3, 5, 7, 9, 11, 13, 15, 17, 19, 21, 23, 25 ]
M_vals = [ 30, 35, 40, 45, 50 ]
for m in M_vals:
    for trial in xrange(ntrials):
        inFiles = " ".join([ "%s/M/trial%d/%d_%d.txt" % (indir, trial, m, mm) for mm in xrange(m) ])
        likelihoods = " ".join(["gaussian"]*m)
        views = " ".join([str(mm) for mm in xrange(m)])
        initialFactors = 50
        outFile = "%s/M/%d_%d.hdf5" % (outdir, m, trial)
        cmd = "python %s/template_run.py --inFiles %s --outFile %s --likelihoods %s --views %s --factors %d --iter %d --startDrop 1 --freqDrop 1 --dropR2 0.03 --tolerance 0.05 --schedule Y SW Z AlphaW Theta Tau --center_features --scale_views" % (scriptDir, inFiles, outFile, likelihoods, views, initialFactors, iterations)
        cmd = "bsub -M 4096 -n 1 -q highpri -o /homes/ricard/tmp/simulations_learnK_varyM.out %s" % cmd
        # print cmd
        os.system(cmd)

# Varying the fraction of missing values
M=3
# NA_vals = np.linspace(0, 0.95, num=20, dtype=float)
NA_vals = np.linspace(0, 0.90, num=10, dtype=float)
for na in NA_vals:
    for trial in xrange(ntrials):
        inFiles = " ".join([ "%s/NA/trial%d/%0.02f_%d.txt" % (indir, trial, na, m) for m in xrange(M) ])
        likelihoods = " ".join(["gaussian"]*M)
        views = " ".join([str(m) for m in xrange(M)])
        initialFactors = 50
        outFile = "%s/NA/%0.02f_%d.hdf5" % (outdir, na, trial)
        cmd = "python %s/template_run.py --inFiles %s --outFile %s --likelihoods %s --views %s --factors %d --iter %d --startDrop 1 --freqDrop 1 --dropR2 0.03 --tolerance 0.05 --schedule Y SW Z AlphaW Theta Tau --center_features --scale_views" % (scriptDir, inFiles, outFile, likelihoods, views, initialFactors, iterations)
        cmd = "bsub -M 2048 -n 1 -q research -o /homes/ricard/tmp/simulations_learnK_varyNA.out %s" % cmd
        # print cmd
        # os.system(cmd)

# Varying N
# M=3
# N_vals = [ 25, 50, 75, 100, 125, 150, 175, 200, 225, 250, 275, 300, 325, 350, 375, 400, 425, 450, 475, 500 ]
# for n in N_vals:
#     for trial in xrange(ntrials):
#         inFiles = " ".join([ "%s/N/trial%d/%d_%d.txt" % (indir, trial, n, m) for m in xrange(M) ])
#         likelihoods = " ".join(["gaussian"]*m)
#         views = " ".join([str(m) for m in xrange(M)])
#         initialFactors = 50
#         outFile = "%s/N/%d_%d.hdf5" % (outdir, n, trial)
#         cmd = "python %s/template_run.py --inFiles %s --outFile %s --likelihoods %s --views %s --factors %d --iter %d --startDrop 1 --freqDrop 1 --dropR2 0.03 --tolerance 0.05 --schedule Y SW Z AlphaW Theta Tau --center_features --scale_views" % (scriptDir, inFiles, outFile, likelihoods, views, initialFactors, iterations)
#         cmd = "bsub -M 2048 -n 1 -q highpri -o /homes/ricard/tmp/simulations_learnK_varyN.out %s" % cmd
#         # print cmd
#         # os.system(cmd)