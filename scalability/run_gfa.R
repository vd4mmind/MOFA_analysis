library(GFA)
attach(loadNamespace("GFA"), name = "GFA_all")

# avoid dropping of components for timing in K
gfa_nodrop <- function (Y, opts, K = NULL, projection = NULL, filename = "") 
{
    if (file.exists(filename)) {
        print("Part of the sampling done already.")
        load(filename)
        print(paste("Continuing from iteration", iter))
        ptm <- proc.time()[1] - time
    }
    else {
        ptm <- proc.time()[1]
        init <- initializeParameters(Y = Y, opts = opts, K = K, 
            projection = projection)
        for (param in init$unlist) {
            eval(parse(text = paste0(param, " <- init$", param)))
            eval(parse(text = paste0("init$", param, " <- NULL")))
        }
        gc()
        V <- length(Y)
        ov <- V:1
        gr <- init$gr
        M <- sapply(gr, length)
        N <- sapply(Y, nrow)
        D <- sapply(Y, ncol)
        opts$K <- opts$initK <- init$K
        opts$missingValues <- init$missingValues
        opts$projection.fixed <- init$projection.fixed
        posterior <- NULL
        iter <- 1
    }
    for (iter in iter:opts$iter.max) {
        if (!opts$projection.fixed) {
            for (v in 1:V) {
                tmpY <- Y[[v]]
                if (V == 2) {
                  tmpY[, gr[[v]][[1]]] <- tmpY[, gr[[v]][[1]]] - 
                    t(tcrossprod(X[[ov[v]]], W[[ov[v]]][gr[[ov[v]]][[1]], 
                      ]))
                }
                groups <- if (opts$spikeW == "group") 
                  gr[[v]]
                else NULL
                up <- updateSpikeAndSlab(Y = tmpY, A = W[[v]], 
                  Z = Z[[v]], mode = 2, B = X[[v]], BB = XX[[v]], 
                  alpha = alpha[[v]], r = r[[v]], tau = tau[[v]], 
                  gr = groups, na.inds = list(V = init$na[[v]], 
                    Y = init$na$Y[[v]]), opts = opts, updateSpike = iter > 
                    opts$sampleZ)
                W[[v]] <- up$A
                Z[[v]] <- up$Z
            }
        }
        if ((iter <= opts$iter.burnin | opts$iter.saved == 0) & 
            !opts$projection.fixed) {
            for (v in 1:V) {
                keep <- 1:ncol(Z[[v]])
                if (length(keep) == 0) {
                  print(paste0("All components shut down (mode ", 
                    v, "), returning a NULL model."))
                  return(list())
                }
                if (length(keep) != opts$K[v]) {
                  opts$K[v] <- length(keep)
                  for (param in c("X", "W", "Z", "alpha", "beta", 
                    "r", "rz")) {
                    eval(parse(text = paste0(param, "[[v]] <- ", 
                      param, "[[v]][,keep,drop=FALSE]")))
                  }
                }
                mm <- ""
                if (V == 2) 
                  mm <- paste0(" (mode ", v, ")")
                if (iter == opts$iter.burnin & opts$K[v] <= opts$initK[v] * 
                  0.4 & opts$initK[v] > 10) 
                  warning(paste0("Over 60% of the initial components shut down", 
                    mm, ". Excessive amount of\n  initial components may result in a bad initialization for the model parameters.\n  Rerun the model with K=", 
                    length(keep) + 5, "."))
            }
        }
        for (v in 1:V) {
            if (iter > opts$sampleZ & !opts$projection.fixed) {
                r[[v]] <- updateBernoulli(r[[v]], Z[[v]], gr[[v]], 
                  opts)
            }
            if (iter > opts$sampleZ & !opts$normalLatents) {
                tmpY <- Y[[v]]
                if (V == 2) {
                  tmpY[, gr[[v]][[1]]] <- tmpY[, gr[[v]][[1]]] - 
                    t(tcrossprod(X[[ov[v]]], W[[ov[v]]][gr[[ov[v]]][[1]], 
                      ]))
                }
                up <- updateSpikeAndSlab(Y = tmpY, A = X[[v]], 
                  Z = NULL, mode = 1, B = W[[v]], BB = crossprod(W[[v]] * 
                    sqrt(tau[[v]])), alpha = beta[[v]], r = rz[[v]], 
                  tau = tau[[v]], gr = NULL, na.inds = list(V = init$na[[v]], 
                    Y = init$na$Y[[v]]), opts = opts, updateSpike = iter > 
                    opts$sampleZ)
                X[[v]] <- up$A
                if (!opts$projection.fixed) {
                  for (k in 1:opts$K[v]) rz[[v]][, k] <- (sum(up$Z[, 
                    k]) + opts$prior.betaX[1])/(N[v] + sum(opts$prior.betaX))
                }
            }
            else {
                tmpY <- Y[[v]]
                if (V == 2) {
                  tmpY[, gr[[v]][[1]]] <- tmpY[, gr[[v]][[1]]] - 
                    t(tcrossprod(X[[ov[v]]], W[[ov[v]]][gr[[ov[v]]][[1]], 
                      ]))
                }
                X[[v]] <- updateNormal(Y = tmpY, W = W[[v]], 
                  tau = tau[[v]], na.inds = list(V = init$na[[v]], 
                    Y = init$na$Y[[v]], Nlist = init$na$Nlist[[v]]), 
                  opts = opts)
            }
            XX[[v]] <- crossprod(X[[v]])
            if (!opts$normalLatents) {
                groups <- if (opts$ARDLatent == "shared") 
                  list(1:N[v])
                else as.list(1:N[v])
                beta[[v]] <- updateGamma(alpha = beta[[v]], A = X[[v]], 
                  Z = (X[[v]] != 0) * 1, alpha_0 = init$prior.alpha_0X[v], 
                  beta_0 = init$prior.beta_0X[[v]], gr = groups)
            }
            if (!opts$projection.fixed) {
                groups <- if (opts$ARDW == "shared") 
                  list(1:D[v])
                else if (opts$ARDW == "grouped") 
                  gr[[v]]
                else as.list(1:D[v])
                alpha[[v]] <- updateGamma(alpha = alpha[[v]], 
                  A = W[[v]], Z = Z[[v]], alpha_0 = init$alpha_0[[v]], 
                  beta_0 = init$beta_0[[v]], gr = groups)
                tmp <- updateTau(tau = tau[[v]], Y = Y[[v]], 
                  X = X[[v]], W = W[[v]], a_tau = init$a_tau, 
                  b_tau = b_tau[[v]], alpha_0t = init$alpha_0t[[v]], 
                  beta_0t = init$beta_0t[[v]], gr = gr[[v]], 
                  na.inds = init$na[[v]], opts, V = V, v = v, 
                  iter = iter)
                tau[[v]] <- tmp$tau
                b_tau[[v]] <- tmp$b_tau
                cost[iter] <- cost[iter] + N[v] * sum(log(tau[[v]][tmp$id]))/2 - 
                  crossprod(b_tau[[v]][tmp$id], tau[[v]][tmp$id])
            }
        }
        if (!opts$projection.fixed & V == 2) {
            XW <- tcrossprod(X[[1]], W[[1]][gr[[1]][[1]], ]) + 
                t(tcrossprod(X[[2]], W[[2]][gr[[2]][[1]], ]))
            if (opts$missingValues && length(init$na[[3]])) {
                XW <- Y[[1]][, gr[[1]][[1]]] - XW
                XW[init$na[[3]]] <- 0
                b_tau[[1]][gr[[1]][[1]]] <- colSums(XW[, gr[[1]][[1]]]^2)/2
            }
            else {
                b_tau[[1]][gr[[v]][[1]]] <- colSums((Y[[1]][, 
                  gr[[1]][[1]]] - XW)^2)/2
            }
            if (opts$tauGrouped) {
                tau[[1]][gr[[1]][[1]]] <- rgamma(1, shape = init$alpha_0t[[1]][1], 
                  rate = init$beta_0t[[1]][1] + sum(b_tau[[1]][gr[[1]][[1]]]))
                tau[[2]][gr[[2]][[1]]] <- tau[[1]][gr[[1]][[1]][1]]
            }
            else {
                stop("Tau needs to be grouped: otherwise the noise prior for the shared view is ill-defined")
            }
            cost[iter] <- cost[iter] + N[1] * sum(log(tau[[1]][gr[[1]][[1]]]))/2 - 
                crossprod(b_tau[[1]][gr[[1]][[1]]], tau[[1]][gr[[1]][[1]]])
        }
        aic[iter] <- 2 * cost[iter]
        for (v in 1:V) aic[iter] <- aic[iter] - (D[v] * (opts$K[v] + 
            1) - opts$K[v] * (opts$K[v] - 1)/2) * 2
        if (filename != "" & iter%%100 == 0) {
            time <- proc.time()[1] - ptm
            save(list = ls(), file = filename)
            if (opts$verbose > 0) 
                print(paste0("Iter ", iter, ", saved chain to '", 
                  filename, "'"))
        }
        if (opts$projection.fixed) {
            for (v in 1:V) {
                tautmp <- (init$Yconst[[v]] + rowSums((W[[v]] %*% 
                  XX[[v]]) * W[[v]]) - 2 * rowSums(crossprod(Y[[v]], 
                  X[[v]]) * W[[v]]))/2
                for (m in which(opts$prediction[[v]] == F)) {
                  cost[iter] <- cost[iter] + N[v] * sum(log(tautmp[gr[[v]][[m]]]))/2 - 
                    crossprod(b_tau[[v]][gr[[v]][[m]]], tautmp[gr[[v]][[m]]])
                }
            }
        }
        for (v in 1:V) {
            if (any(opts$prediction[[v]])) {
                if (iter%%10 == 0 & opts$verbose > 1) 
                  print(paste0("Predicting: ", iter, "/", opts$iter.max))
                if (iter > opts$iter.burnin & ((iter - opts$iter.burnin)%%init$mod.saved) == 
                  0) {
                  init$i.pred <- init$i.pred + 1/V
                  for (m in which(opts$prediction[[v]])) prediction[[v]][[m]] <- prediction[[v]][[m]] + 
                    tcrossprod(X[[v]], W[[v]][gr[[v]][[m]], ])
                }
            }
            else if (!any(unlist(opts$prediction))) {
                if (((iter%%10 == 0 & opts$verbose > 1) | (iter%%100 == 
                  0 & opts$verbose > 0)) & v == 1) {
                  print(paste0("Learning: ", iter, "/", opts$iter.max, 
                    " - K=", paste0(opts$K, collapse = ","), 
                    " - ", Sys.time()))
                }
                if (opts$iter.saved > 0 && iter > opts$iter.burnin && 
                  ((iter - opts$iter.burnin)%%init$mod.saved) == 
                    0) {
                  if (iter - opts$iter.burnin == init$mod.saved) {
                    if (v == 1) 
                      posterior <- NULL
                    posterior <- initializePosterior(posterior = posterior, 
                      Y = Y[[v]], V = V, v = v, N = N[v], D = D[v], 
                      M = M[v], S = init$S, opts = opts)
                    if (v == 1) {
                      gr.start <- list()
                    }
                    gr.start[[v]] = vector(mode = "integer", 
                      length = length(gr[[v]]))
                    for (m in 1:length(gr[[v]])) {
                      gr.start[[v]][m] = gr[[v]][[m]][1]
                    }
                  }
                  s <- (iter - opts$iter.burnin)/init$mod.saved
                  if (!opts$projection.fixed) {
                    if (opts$save.posterior$W | (opts$convergenceCheck && 
                      s %in% c(init$psStart, init$psEnd))) 
                      posterior$W[[v]][s, , ] <- W[[v]]
                    posterior$tau[[v]][s, ] <- tau[[v]]
                    posterior$rz[[v]][s, ] <- rz[[v]][1, ]
                    posterior$r[[v]][s, , ] <- r[[v]][gr.start[[v]], 
                      ]
                    posterior$beta[[v]][s, , ] <- beta[[v]]
                  }
                  if (opts$save.posterior$X | (opts$convergenceCheck && 
                    s %in% c(init$psStart, init$psEnd))) 
                    posterior$X[[v]][s, , ] <- X[[v]]
                }
            }
        }
    }
    if (opts$convergenceCheck && opts$iter.saved >= 8 && !opts$projection.fixed) {
        conv <- checkConvergence(posterior = posterior, V = V, 
            N = N, D = D, start = init$psStart, end = init$psEnd, 
            opts = opts)
        if (!opts$save.posterior$X) 
            posterior$X[[v]] <- NULL
        if (!opts$save.posterior$W) 
            posterior$W[[v]] <- NULL
        gc()
    }
    else {
        conv <- NA
    }
    if (filename != "" & opts$iter.max >= 10) 
        file.remove(filename)
    if (opts$projection.fixed) {
        for (v in 1:V) {
            if (any(opts$prediction[[v]])) {
                for (m in which(opts$prediction[[v]])) prediction[[v]][[m]] <- prediction[[v]][[m]]/init$i.pred
                prediction[[v]]$cost <- cost
            }
        }
        return(prediction)
    }
    else {
        for (v in 1:V) {
            d1 <- unlist(lapply(gr[[v]], function(x) {
                x[1]
            }))
            if (opts$ARDW == "grouped") 
                alpha[[v]] <- alpha[[v]][d1, ]
            if (opts$spikeW == "group") 
                Z[[v]] <- Z[[v]][d1, ]
        }
        for (v in 1:V) {
            rownames(X[[v]]) <- rownames(Y[[v]])
            rownames(W[[v]]) <- colnames(Y[[v]])
        }
        if (V == 1) {
            params <- c("W", "X", "Z", "r", "rz", "tau", "alpha", 
                "beta", "gr")
            if (!is.null(posterior)) 
                params <- c(params, paste0("posterior$", names(posterior)))
            for (param in params) eval(parse(text = paste0(param, 
                " <- ", param, "[[1]]")))
            D <- D[1]
            opts$K <- opts$K[1]
        }
        time <- proc.time()[1] - ptm
        return(list(W = W, X = X, Z = Z, r = r, rz = rz, tau = tau, 
            alpha = alpha, beta = beta, groups = gr, D = D, K = opts$K, 
            cost = cost, aic = aic, posterior = posterior, opts = opts, 
            conv = conv, time = time))
    }
}

run_gfa <- function(Y,nfac){
norm <- GFA::normalizeData(train=Y, type="center")           #Centering
opts <- getDefaultOpts()                          #Model options
res <- gfa_nodrop(norm$train, opts=opts, K = nfac) 
}

#slurmidx <- 1
slurmidx <- as.numeric(Sys.getenv('SLURM_ARRAY_TASK_ID'))-1
idx <- slurmidx %% 37+1
trial <- slurmidx %/% 37 +1

indir = '/g/huber/users/bvelten/tmp/MOFA/runtime/withNAs/data'
outdir = '/g/huber/users/bvelten/tmp/MOFA/runtime/withNAs/out_gfa_rep2'
if(!dir.exists(outdir)) dir.create(outdir)
for(letter in c("K","M","N","D"))
    if(!dir.exists(file.path(outdir, letter))) dir.create(file.path(outdir, letter))

# Default values
M = 3
K=10

if(idx<11){
  # Varying K
  k = c(5, 10, 15, 20, 25, 30, 35, 40, 45, 50,60,70,80,90,100,150,200)[idx]
  inFiles = file.path(indir, "K", paste0(paste(k, 0:(M-1), sep="_"),".txt"))
  Y = lapply(inFiles, function(fnm) as.matrix(read.table(fnm)))
  tmp <- Sys.time()
  run_gfa(Y,k)
  tmp <- difftime(Sys.time(),tmp, units="secs")
  outFile = file.path(outdir, "K", paste0(paste("K",k, trial, sep="_"),".txt"))
  write.table(tmp,file=outFile, row.names=F, col.names=F)
} else if(idx<20) {
  # Varying D
  d = c(1000, 1500, 2000, 2500, 3000, 3500, 4000, 4500, 5000)[idx-10]
  inFiles = file.path(indir, "D", paste0(paste(d, 0:(M-1), sep="_"),".txt"))
  Y = lapply(inFiles, function(fnm) as.matrix(read.table(fnm)))
  tmp <- Sys.time()
  run_gfa(Y,K)
  tmp <- difftime(Sys.time(),tmp, units="secs")
  outFile = file.path(outdir, "D", paste0(paste("D",d, trial, sep="_"),".txt"))
  write.table(tmp,file=outFile, row.names=F, col.names=F)
} else if (idx<28){
  m = c(1, 3, 5, 7, 9, 11, 13, 15)[idx-19]
  inFiles = file.path(indir, "M", paste0(paste(m, 0:(m-1), sep="_"),".txt"))
  Y = lapply(inFiles, function(fnm) as.matrix(read.table(fnm)))
  tmp <- Sys.time()
  run_gfa(Y,K)
  tmp <- difftime(Sys.time(),tmp, units="secs")
  outFile = file.path(outdir, "M", paste0(paste("M",m, trial, sep="_"),".txt"))
  write.table(tmp,file=outFile, row.names=F, col.names=F)
}else if(idx<38){
  # Varying N
  n = c(50, 100, 150, 200, 250, 300, 350, 400, 450, 500)[idx-27]
  inFiles = file.path(indir, "N", paste0(paste(n, 0:(M-1), sep="_"),".txt"))
  Y = lapply(inFiles, function(fnm) as.matrix(read.table(fnm)))
  tmp <- Sys.time()
  run_gfa(Y,K)
  tmp <- difftime(Sys.time(),tmp, units="secs")
  outFile = file.path(outdir, "N", paste0(paste("N",n, trial, sep="_"),".txt"))
  write.table(tmp,file=outFile, row.names=F, col.names=F)
} else stop("Error: Index too high")   
