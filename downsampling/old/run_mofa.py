import numpy as np
import os

indir = '/hps/nobackup/stegle/users/ricard/downsample/data'
# indir = '/Users/ricard/data/CLL/out/downsample/data'

outdir = '/hps/nobackup/stegle/users/ricard/downsample/results'
# outdir = '/Users/ricard/data/CLL/out/downsample/results'

iterations = 2000
ntrials = 25
views = ["mRNA","Methylation","Drugs"]
likelihoods = ["gaussian","gaussian","gaussian"]

## Downsampled mRNA view ##
range_downsample = range(0,75+1,5)
for n in range_downsample:
    for trial in xrange(1,ntrials+1):
        inFiles = " ".join([ "%s/mRNA/%d_%d_%s.txt" % (indir, n, trial, view) for view in views])
        initialFactors = 15

        # Incomplete data set
        outFile = "%s/mRNA/all_%d_%d.hdf5" % (outdir, n, trial)
        cmd = "mofa --inFiles %s --delimiter ' ' --header_cols --header_rows --outFile %s --likelihoods %s --views %s --factors %d --iter %d --tolerance 0.01 --center_features --dropR2 0.05 --startDrop 3 --freqDrop 1 " % (inFiles, outFile, " ".join(likelihoods), " ".join(views), initialFactors, iterations)
        cmd = "bsub -M 2048 -n 1 -q research -o /homes/ricard/tmp/simulations_downsample_mRNA.out %s" % cmd
        # print cmd
        os.system(cmd)

        # Complete data set
        outFile = "%s/mRNA/common_%d_%d.hdf5" % (outdir, n, trial)
        cmd = "mofa --RemoveIncompleteSamples --inFiles %s --delimiter ' ' --header_cols --header_rows --outFile %s --likelihoods %s --views %s --factors %d --iter %d --tolerance 0.01 --center_features --dropR2 0.05 --startDrop 3 --freqDrop 1 " % (inFiles, outFile, " ".join(likelihoods), " ".join(views), initialFactors, iterations)
        cmd = "bsub -M 2048 -n 1 -q research -o /homes/ricard/tmp/simulations_downsample_mRNA.out %s" % cmd
        # print cmd
        os.system(cmd)

exit()

## Downsampled Methylation view ##
# range_downsample = range(5,100+1,5)
# for n in range_downsample:
#     for trial in xrange(1,ntrials+1):
#         inFiles = " ".join([ "%s/Methylation/%d_%d_%s.txt" % (indir, n, trial, view) for view in views])
#         initialFactors = 15

#         # Incomplete data set
#         outFile = "%s/Methylation/learnK_all_%d_%d.hdf5" % (outdir, n, trial)
#         cmd = "python %s/template_run.py --inFiles %s --delimiter ' ' --header_cols --header_rows --outFile %s --likelihoods %s --views %s --factors %d --iter %d --tolerance 0.01 --center_features --dropR2 0.05 --startDrop 3 --freqDrop 1 " % (scriptDir, inFiles, outFile, " ".join(likelihoods), " ".join(views), initialFactors, iterations)
#         cmd = "bsub -M 4096 -n 1 -q research -o /homes/ricard/tmp/simulations_downsample_Methylation.out %s" % cmd
#         # print cmd
#         os.system(cmd)

#         # Complete data set
#         outFile = "%s/Methylation/learnK_common_%d_%d.hdf5" % (outdir, n, trial)
#         cmd = "python %s/template_run.py --RemoveIncompleteSamples --inFiles %s --delimiter ' ' --header_cols --header_rows --outFile %s --likelihoods %s --views %s --factors %d --iter %d --tolerance 0.01 --center_features --dropR2 0.05 --startDrop 3 --freqDrop 1 " % (scriptDir, inFiles, outFile, " ".join(likelihoods), " ".join(views), initialFactors, iterations)
#         cmd = "bsub -M 4096 -n 1 -q research -o /homes/ricard/tmp/simulations_downsample_Methylation.out %s" % cmd
#         # print cmd
#         os.system(cmd)

