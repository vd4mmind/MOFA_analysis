###################
## Generate data ##
###################

from time import time
import scipy as s
import scipy.stats as stats
import os

# Import manually defined functions
from MOFA.core.simulate import Simulate


def generate_data(outfile, M=5, N=100, K=20, D=5000):

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
  outdir = '/Users/ricard/MOFA/MOFA/test/scalability/data'

  K_vals = [ 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 ]
  # K_vals = s.linspace(5.0, 99.0, num=20, dtype=int)
  D_vals = [ 100 500 1000 1500 2000 2500 3000 3500 4000 4500 5000 5500 6000 6500 7000 7500 8000 8500 9000 9500 10000 ]
  # D_vals = s.linspace(500.0, 10000.0, num=20, dtype=int)
  N_vals = [ 25 50 75 100 125 150 175 200 225 250 275 300 325 350 375 400 425 450 475 500 ]
  # N_vals = s.linspace(100.0, 2000.0, num=20, dtype=int)
  M_vals = [ 1 3 5 7 10 12 15 17 20 22 25 27 30 ]
  # M_vals = s.linspace(2.0, 20.0, num=20, dtype=int)

  for k in K_vals:
    print "Generating K..."
    outprefix = "%s/K/%d" % (outdir, k)
    generate_data(outprefix, K=k)

  for d in D_vals:
    print "Generating D..."
    outprefix = "%s/D/%d" % (outdir, d)
    generate_data(outprefix, D=d)

  for m in M_vals:
    print "Generating M..."
    outprefix = "%s/M/%d" % (outdir, m)
    generate_data(outprefix, M=m)

  for n in N_vals:
    print "Generating N..."
    outfile = "%s/N/%d.txt" % (outdir, n)
    generate_data(outfile, N=n)