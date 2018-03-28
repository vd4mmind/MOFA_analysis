#!/bin/bash
#SBATCH -p 1week                  # partition (queue)
#SBATCH -n 12                        # number of cores
#SBATCH -N 1 # on one node
#SBATCH -t 7-00:00:00 
#SBATCH --mem 20000M 
#SBATCH -o slurm.%N.%j.out          # STDOUT
#SBATCH -e slurm.%N.%j.err          # STDERR
#SBATCH --mail-type=END,FAIL        # notifications for job done & fail
#SBATCH --mail-user=bvelten@embl.de # send-to address

#module load R
#export R_LIBS="/g/huber/users/bvelten/R-lib/3.4.3-foss-2017b-X11-20171023"
script="/g/huber/users/bvelten/tmp/iCluster/CLL/imputed/iClusterPlus_CLL_imputed.R"

Rscript  $script
