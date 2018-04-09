indir <- '/hps/nobackup/stegle/users/ricard/MOFA/rebuttal/scalability/input'
outdir <- '/hps/nobackup/stegle/users/ricard/MOFA/rebuttal/scalability/output/gfa'

# Default values
M = 5
K = 10
ntrials = 10
tmpFile = "/hps/nobackup/stegle/users/ricard/MOFA/rebuttal/scalability/output/tmp/tmp_gfa.txt"

## Varying the number of latent factors
K_vals = c(5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75)
for (k in K_vals) {
  inFiles <- paste(sprintf("%s/K/%d_%d.txt", indir, k, 0:(M-1)), collapse=" ")
  for (trial in 0:(ntrials-1)) {
    outFile = sprintf("%s/K/K_%d.txt", outdir,k)
    cmd <- sprintf("Rscript run_gfa_template.R -i %s -o %s -f %s", inFiles, outFile, k)
    cmd <- sprintf("bsub -M 4096 -n 1 -q highpri -o %s %s", tmpFile, cmd)
  }
  system(cmd)
}

## Varying the number of features
D_vals = c( 1000, 1500, 2000, 2500, 3000, 3500, 4000, 4500, 5000, 5500, 6000, 6500, 7000, 7500, 8000, 8500, 9000, 9500, 10000 )
for (d in D_vals) {
  inFiles <- sprintf("%s/D/%d_%d.txt", indir, d, 0:(M-1))
  for (trial in 0:(ntrials-1)) {
    outFile = sprintf("%s/D/D_%d.txt", outdir,d)
    cmd <- sprintf("Rscript run_gfa_template.R -i %s -o %s -f %s", inFiles, outFile, K)
    cmd <- sprintf("bsub -M 4096 -n 1 -q highpri -o %s %s", tmpFile, cmd)
  }
  system(cmd)
}

## Varying the number of views
M_vals = c( 1, 5, 10, 15, 20, 25, 30 )
for (m in M_vals) {
  inFiles <- sprintf("%s/M/%d_%d.txt", indir, m, 0:(m-1))
  for (trial in 0:(ntrials-1)) {
    outFile = sprintf("%s/M/M_%d.txt", outdir,m)
    cmd <- sprintf("Rscript run_gfa_template.R -i %s -o %s -f %s", inFiles, outFile, K)
    cmd <- sprintf("bsub -M 4096 -n 1 -q highpri -o %s %s", tmpFile, cmd)
  }
  system(cmd)
}

## Varying the number of samples
N_vals = c( 25, 50, 75, 100, 125, 150, 175, 200, 225, 250, 275, 300, 325, 350, 375, 400, 425, 450, 475, 500 )
for (n in N_vals) {
  inFiles <- sprintf("%s/N/%d_%d.txt", indir, n, 0:(M-1))
  for (trial in 0:(ntrials-1)) {
    outFile = sprintf("%s/N/N_%d.txt", outdir,d)
    cmd <- sprintf("Rscript run_gfa_template.R -i %s -o %s -f %s", inFiles, outFile, K)
    cmd <- sprintf("bsub -M 4096 -n 1 -q highpri -o %s %s", tmpFile, cmd)
  }
  system(cmd)
}