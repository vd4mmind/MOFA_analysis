###################
## Generate data ##
###################

from time import time
import scipy as s
import scipy.stats as stats
import os

# Import manually defined functions
from MOFA.core.simulate import Simulate


# def sampleAlpha(K, M, active=1., inactive=1e6):
def sampleAlpha(K, M, active=1., inactive=1e4):
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
  data['alpha'] = sampleAlpha(K=K, M=M, active=1, inactive=1e4)

  data['theta'] = [ s.ones((D[m],K))*0.5 for m in xrange(M) ]
  # data['theta'] = sampleTheta(K=K, M=M, a=1, b=1)

  data['S'], data['W'], data['W_hat'], _ = tmp.initW_spikeslab(theta=data['theta'], alpha=data['alpha'])
  data['mu'] = [ s.ones(D[m])*0. for m in xrange(M) ]
  data['tau']= [ stats.uniform.rvs(loc=1,scale=3,size=D[m]) for m in xrange(M) ]

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
    s.savetxt(outfile+"_W_"+str(m)+".txt", data["W"][m], fmt='%.3f', delimiter=' ')
    s.savetxt(outfile+"_"+str(m)+".txt", data["Y"][m], fmt='%.3f', delimiter=' ')




if __name__ == "__main__":

  # outdir = '/Users/ricard/data/MOFA/simulations/26Aug/data'
  outdir = '/hps/nobackup/stegle/users/ricard/MOFA/simulations/data/sparsity'

  ntrials = 10
  
  # Varying number of dimensions
  # D_vals = [ 500, 1000, 2000, 2500, 3000, 3500, 4000, 4500, 5000, 5500, 6000, 6500, 7000, 7500, 8000, 8500, 9000, 9500, 10000 ]
  D_vals = [ 5000, 10000 ]
  # D_vals = s.linspace(500.0, 10000.0, num=20, dtype=int)
  M=1
  K=10
  N=100
  print "Generating D..."
  for d in D_vals:
    for trial in xrange(ntrials):
      outprefix = "%s/D/trial%d/%d" % (outdir, trial, d)
      generate_data(outprefix, N=N, M=M, K=K, D=d)
  exit()


  # Varying number of views
  M_vals = [ 1, 3, 5, 10, 15, 30 ]
  # M_vals = s.linspace(2.0, 20.0, num=20, dtype=int)
  D = 5000
  K = 9
  N = 100
  print "Generating M..."
  for m in M_vals:
    for trial in xrange(ntrials):
      outprefix = "%s/M/trial%d/%d" % (outdir, trial, m)
      # generate_data(outprefix, N=N, M=m, K=K, D=D)
