###################
## Generate data ##
###################

from time import time
import scipy as s
import scipy.stats as stats
import os

# Import manually defined functions
from mofa.core.simulate import Simulate


def generate_data(outfile, M=3, N=100, K=10, D=1000):

  # Sanity checks
  if not os.path.isdir(os.path.dirname(outfile)):
    print "Error: Output directory does not exist"
    exit()

  # Dimensionality
  if isinstance(D, (int, long, float)):
    D = s.array([D]*M)
  else:
    assert len(D) == M, 'wrong shape for D'


  # Simulate data 
  data = {}
  tmp = Simulate(M=M, N=N, D=D, K=K)

  # data['Z'] = s.zeros((N,K))
  # data['Z'][:,0] = s.sin(s.arange(N)/(N/20))
  # data['Z'][:,1] = s.cos(s.arange(N)/(N/20))
  # data['Z'][:,2] = 2*(s.arange(N)/N-0.5)
  # data['Z'][:,3] = stats.norm.rvs(loc=0, scale=1, size=N)
  # data['Z'][:,4] = stats.norm.rvs(loc=0, scale=1, size=N)
  # data['Z'][:,5] = stats.norm.rvs(loc=0, scale=1, size=N)
  data['Z'] = stats.norm.rvs(loc=0, scale=1, size=(N,K))

  data['alpha'] = [s.random.choice([1., 1e6], K) for m in xrange(M)]

  data['theta'] = [ s.ones((D[m],K))*1.0 for m in xrange(M) ]
  data['S'], data['W'], data['W_hat'], _ = tmp.initW_spikeslab(theta=data['theta'], alpha=data['alpha'])

  data['mu'] = [ s.ones(D[m])*0. for m in xrange(M)]
  data['tau']= [ stats.uniform.rvs(loc=1,scale=3,size=D[m]) for m in xrange(M) ]
  # data['tau']= [ stats.uniform.rvs(loc=0.1,scale=3,size=D[m]) for m in xrange(M) ]

  missingness = 0.0
  missing_view = 0.0
  # Y_warp = tmp.generateData(W=data['W'], Z=data['Z'], Tau=data['tau'], Mu=data['mu'],
  #   likelihood="warp", missingness=missingness, missing_view=missing_view)
  Y_gaussian = tmp.generateData(W=data['W'], Z=data['Z'], Tau=data['tau'], Mu=data['mu'],
    likelihood="gaussian", missingness=missingness, missing_view=missing_view)
  # Y_poisson = tmp.generateData(W=data['W'], Z=data['Z'], Tau=data['tau'], Mu=data['mu'],
  	# likelihood="poisson", missingness=missingness, missing_view=missing_view)
  # Y_bernoulli = tmp.generateData(W=data['W'], Z=data['Z'], Tau=data['tau'], Mu=data['mu'],
  	# likelihood="bernoulli", missingness=missingness, missing_view=missing_view)
  # Y_binomial = tmp.generateData(W=data['W'], Z=data['Z'], Tau=data['tau'], Mu=data['mu'],
  # 	likelihood="binomial", min_trials=10, max_trials=50, missingness=missingness)

  likelihoods = ['gaussian']*M

  data["Y"] = [None] * M
  for i in range(M):
    lik = likelihoods[i]
    if lik == 'gaussian':
      data["Y"][i] = Y_gaussian[i]
    elif lik == 'poisson':
      data["Y"][i] = Y_poisson[i]
    elif lik == 'bernoulli':
      data["Y"][i] = Y_bernoulli[i]

  # Save data
  for m in xrange(M):
    s.savetxt(outfile+"_"+str(m)+".txt", data["Y"][m], fmt='%.3e', delimiter=' ')




if __name__ == "__main__":

  outdir = '/hps/nobackup/stegle/users/ricard/MOFA/rebuttal/scalability/input'

  K_vals = [ 5, 10, 15, 20, 25, 30, 35, 40, 45, 50 ]
  # K_vals = s.linspace(5.0, 99.0, num=20, dtype=int)
  print "Generating K..."
  for k in K_vals:
    outprefix = "%s/K/%d" % (outdir, k)
    # generate_data(outprefix, K=k)


  D_vals = [ 1000, 1500, 2000, 2500, 3000, 3500, 4000, 4500, 5000 ]
  # D_vals = [ 1000, 1500, 2000, 2500, 3000, 3500, 4000, 4500, 5000, 5500, 6000, 6500, 7000, 7500, 8000, 8500, 9000, 9500, 10000 ]
  # D_vals = s.linspace(500.0, 10000.0, num=20, dtype=int)
  print "Generating D..."
  for d in D_vals:
    outprefix = "%s/D/%d" % (outdir, d)
    # generate_data(outprefix, D=d)


  M_vals = [ 1, 3, 5, 7, 9, 11, 13, 15 ]
  # M_vals = s.linspace(2.0, 20.0, num=20, dtype=int)
  print "Generating M..."
  for m in M_vals:
    outprefix = "%s/M/%d" % (outdir, m)
    # generate_data(outprefix, M=m)


  N_vals = [ 50, 100, 150, 200, 250, 300, 350, 400, 450, 500 ]
  # N_vals = [ 25, 50, 75, 100, 125, 150, 175, 200, 225, 250, 275, 300, 325, 350, 375, 400, 425, 450, 475, 500 ]
  # N_vals = s.linspace(100.0, 2000.0, num=20, dtype=int)
  print "Generating N..."
  for n in N_vals:
    outprefix = "%s/N/%d" % (outdir, n)
    generate_data(outprefix, N=n)