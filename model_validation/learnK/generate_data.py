###################
## Generate data ##
###################

from time import time
import scipy as s
import scipy.stats as stats
import os

# Import manually defined functions
from MOFA.core.simulate import Simulate


def sampleTheta(K, M, a=1, b=1):
  # return [ stats.uniform.rvs(loc=_min, scale=_max, size=K) for m in xrange(M) ]
  return [ s.random.beta(a,b, size=K) for m in xrange(M) ]


# def sampleAlpha(K, M, active=1., inactive=1e6):
def sampleAlpha(K, M, active=1., inactive=1e5):
  alpha_tmp = [s.ones(M)*inactive]*K
  for k in xrange(K):
    while s.all(alpha_tmp[k]==inactive):
      alpha_tmp[k] = s.random.choice([active,inactive], size=M, replace=True)
  alpha = [ s.array(alpha_tmp)[:,m] for m in xrange(M) ]
  return alpha

def generate_data(outfile, M=3, N=100, K=10, D=5000, missingness=0.0):

  # Sanity checks
  if not os.path.isdir(os.path.dirname(outfile)):
    os.makedirs(os.path.dirname(outfile))

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

  # data['alpha'] = [s.random.choice([1., 1e6], K) for m in xrange(M)]
  # data['alpha'] = [ s.ones(K) for m in xrange(M) ]
  data['alpha'] = sampleAlpha(K=K, M=M, active=1, inactive=1e6)

  data['theta'] = [ s.ones((D[m],K)) for m in xrange(M) ]
  # data['theta'] = sampleTheta(K=K, M=M, a=1, b=1)

  data['S'], data['W'], data['W_hat'], _ = tmp.initW_spikeslab(theta=data['theta'], alpha=data['alpha'])

  data['mu'] = [ s.ones(D[m])*0. for m in xrange(M)]
  data['tau']= [ stats.uniform.rvs(loc=1,scale=3,size=D[m]) for m in xrange(M) ]
  # data['tau']= [ stats.uniform.rvs(loc=0.1,scale=3,size=D[m]) for m in xrange(M) ]

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

  # likelihoods = s.random.choice(['gaussian', 'bernoulli', "poisson"], M)
  # likelihoods = ['gaussian', 'bernoulli', "poisson"]
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
    s.savetxt(outfile+"_"+str(m)+".txt", data["Y"][m], fmt='%.3f', delimiter=' ')




if __name__ == "__main__":
  # outdir = '/Users/ricard/CLL/simulations/data'
  # outdir = '/Users/ricard/data/MOFA/simulations/18Aug/data'
  outdir = '/hps/nobackup/stegle/users/ricard/MOFA/simulations/data/learnK'

  ntrials = 10
  

  # Varying number of factors
  # K_vals = [ 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25 ]
  K_vals = range(5,75+1,2)
  M=3
  N=100
  D=5000
  print "Generating K..."
  for k in K_vals:
    for trial in xrange(ntrials):
      outprefix = "%s/K/trial%d/%d" % (outdir, trial, k)
      # generate_data(outprefix, K=k, M=M, N=N, D=D)


  # Varying fraction of missing values
  NA_vals = s.linspace(0, 0.90, num=10, dtype=float)
  M=3
  N=100
  K=10
  D=5000
  print "Generating NA..."
  for na in NA_vals:
    for trial in xrange(ntrials):
      outprefix = "%s/NA/trial%d/%0.02f" % (outdir, trial, na)
      # generate_data(outprefix, missingness=na, M=M, N=N, K=K, D=D)

  # Varying number of dimensions
  # D_vals = [ 100, 500, 1000, 1500, 2000, 2500, 3000, 3500, 4000, 4500, 5000, 5500, 6000, 6500, 7000, 7500, 8000, 8500, 9000, 9500, 10000 ]
  # D_vals = s.linspace(500.0, 10000.0, num=20, dtype=int)
  D_vals = [ 10000, 15000, 20000, 25000 ]
  M=3
  K=10
  N=100
  print "Generating D..."
  for d in D_vals:
    for trial in xrange(ntrials):
      outprefix = "%s/D/trial%d/%d" % (outdir, trial, d)
      generate_data(outprefix, N=N, M=M, K=K, D=d)


  # Varying number of views
  # M_vals = [ 1, 3, 5, 7, 9, 11, 13, 15, 17, 19, 21, 23, 25 ]
  # M_vals = s.linspace(2.0, 20.0, num=20, dtype=int)
  M_vals = [ 30, 35, 40, 45, 50 ]
  D = 5000
  K = 10
  N = 100
  print "Generating M..."
  for m in M_vals:
    for trial in xrange(ntrials):
      outprefix = "%s/M/trial%d/%d" % (outdir, trial, m)
      generate_data(outprefix, N=N, M=m, K=K, D=D)

  # Varying number of samples
  N_vals = [ 25, 50, 75, 100, 125, 150, 175, 200, 225, 250, 275, 300, 325, 350, 375, 400, 425, 450, 475, 500 ]
  # N_vals = s.linspace(100.0, 2000.0, num=20, dtype=int)
  M=3
  K=10
  D=5000
  print "Generating N..."
  for n in N_vals:
    for trial in xrange(ntrials):
      outprefix = "%s/N/trial%d/%d" % (outdir, trial, n)
      # generate_data(outprefix, N=n, M=M, K=K, D=D)
