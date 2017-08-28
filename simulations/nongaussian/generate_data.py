########################################################
## Generate data for testing non-gaussian likelihoods ##
########################################################

from time import time
import scipy as s
import scipy.stats as stats
import os

# Import manually defined functions
from MOFA.core.simulate import Simulate

def sampleAlpha(K, M, active=1., inactive=1e6):
  alpha_tmp = [s.ones(M)*inactive]*K
  for k in xrange(K):
    while s.all(alpha_tmp[k]==inactive):
      alpha_tmp[k] = s.random.choice([active,inactive], size=M, replace=True)
  alpha = [ s.array(alpha_tmp)[:,m] for m in xrange(M) ]
  return alpha

def generate_data(outfile, M=3, N=100, K=10, D=5000, missingness=0.0, likelihoods="gaussian"):

  # Sanity checks
  if not os.path.isdir(os.path.dirname(outfile)):
    os.makedirs(os.path.dirname(outfile))

  # Dimensionality
  if isinstance(D, (int, long, float)):
    D = s.array([D]*M)
  else:
    assert len(D) == M, 'wrong shape for D'

  # Likelihoods
  if type(likelihoods) == str:
    likelihoods = [likelihoods]*M
  for i in likelihoods: assert i in ["gaussian","bernoulli","poisson"], 'wrong likelihood'

  # Simulate data 
  data = {}
  tmp = Simulate(M=M, N=N, D=D, K=K)

  data['Z'] = stats.norm.rvs(loc=0, scale=1, size=(N,K))

  # data['alpha'] = [s.random.choice([1., 1e6], K) for m in xrange(M)]
  # data['alpha'] = [ s.ones(K) for m in xrange(M) ]
  data['alpha'] = sampleAlpha(K=K, M=M, active=1, inactive=1e6)

  # data['theta'] = [ s.ones((D[m],K))*1.0 for m in xrange(M) ]
  # data['theta'] = sampleTheta(K=K, M=M, a=1, b=1)
  data['theta'] = [ s.ones(K)*1.0 for m in xrange(M) ]

  data['S'], data['W'], data['W_hat'], _ = tmp.initW_spikeslab(theta=data['theta'], alpha=data['alpha'])

  data['mu'] = [ s.ones(D[m])*0. for m in xrange(M)]
  data['tau']= [ stats.uniform.rvs(loc=1,scale=3,size=D[m]) for m in xrange(M) ]
  # data['tau']= [ stats.uniform.rvs(loc=0.1,scale=3,size=D[m]) for m in xrange(M) ]

  # Y_warp = tmp.generateData(W=data['W'], Z=data['Z'], Tau=data['tau'], Mu=data['mu'],
  #   likelihood="warp", missingness=missingness, missing_view=missing_view)
  Y_gaussian = tmp.generateData(W=data['W'], Z=data['Z'], Tau=data['tau'], Mu=data['mu'],
    likelihood="gaussian", missingness=missingness)
  Y_poisson = tmp.generateData(W=data['W'], Z=data['Z'], Tau=data['tau'], Mu=data['mu'],
  	likelihood="poisson", missingness=missingness)
  Y_bernoulli = tmp.generateData(W=data['W'], Z=data['Z'], Tau=data['tau'], Mu=data['mu'],
  	likelihood="bernoulli", missingness=missingness)
  # Y_binomial = tmp.generateData(W=data['W'], Z=data['Z'], Tau=data['tau'], Mu=data['mu'],
  # 	likelihood="binomial", min_trials=10, max_trials=50, missingness=missingness)

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
    if likelihoods[m] == "gaussian":
      s.savetxt(outfile+"_"+str(m)+".txt", data["Y"][m], fmt='%.2f', delimiter=' ')
    else:
      s.savetxt(outfile+"_"+str(m)+".txt", data["Y"][m], fmt='%d', delimiter=' ')



if __name__ == "__main__":

  # outdir = '/Users/ricard/data/MOFA/simulations/data3'
  outdir = '/hps/nobackup/stegle/users/ricard/MOFA/simulations/data/nongaussian'

  ntrials = 10
  M = 3
  D = 5000
  K = 10
  N = 100
  
  # Generate binary data
  print "Generating binary data..."
  for trial in xrange(ntrials):
    outprefix = "%s/binary/trial%d" % (outdir, trial)
    generate_data(outprefix, N=N, M=M, K=K, D=D, likelihoods="bernoulli")

  # Generate count data
  print "Generating count data..."
  for trial in xrange(ntrials):
    outprefix = "%s/poisson/trial%d" % (outdir, trial)
    generate_data(outprefix, N=N, M=M, K=K, D=D, likelihoods="poisson")  
