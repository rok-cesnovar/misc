library(rstan)

setwd("~/Desktop/misc/quadprog")


model <- stan_model(file = "quadprog_test_model.stan",
               allow_undefined = TRUE,
               includes = paste0('\n#include "', file.path(getwd(), 'quadprog.hpp'), '"\n'),
               verbose = FALSE)
print(model@model_name)




# stan formulation
# min 0.5 * x G x + g0 x
# s.t.
# CE^T x + ce0 = 0
# CI^T x + ci0 >= 0
# 
# The matrix and vectors dimensions are as follows:
# G: n * n
# g0: n
# 
# CE: n * p
# ce0: p
# 
# CI: n * m
# ci0: m
# 
# x: n

# a simple example to make things easier
# say we have x1 = -3 and x3 = 3
# we want to find xhat s.t. we minimize (x-xhat)^2
# while constraining xhat >= 0

#    (x1 - xhat1)^2 + (x2 - xhat2)^2
# => (-3 - xhat1)^2 + ( 3 - xhat2)^2
# => 9 + 6xhat1 + xhat1^2 + 9 - 6xhat2 + xhat2^2
# removing constants
# => xhat1^2 + xhat2^2 + 6xhat1 - 6xhat2

confirmfn = function(par) {
  xhat1 = par[1]
  xhat2 = par[2]
  xhat1^2 + xhat2^2 + 6*xhat1 - 6*xhat2
}

optim(c(0,0), confirmfn)$par

# => G  = [2   0]
#         [0   2]
#    g0 = [6  -6]

# because 
#                     [2   0] [xhat1]          [xhat1]
# 0.5 * [xhat1 xhat2] [0   2] [xhat2] + [6 -6] [xhat2]
# is equal to 
# xhat1^2 + xhat2^2 + 6xhat1 - 6xhat2

confirmfn2 = function(par) {
  xhat1 = par[1]
  xhat2 = par[2]
  G = diag(2, 2, 2)
  g0 = c(6, -6)
  x = matrix(c(xhat1, xhat2), 1, 2)
  
  0.5 * x %*% G %*% t(x) + g0 %*% t(x)
}

optim(c(0,0), confirmfn2)$par

G = diag(1, 2, 2) * 2
g0 = c(6, -6)
xstart = c(-3, 3) 
CE = matrix(0, 2, 2)
ce0 = rep(0, 2)
CI = diag(1, 2, 2)
ci0 = rep(0, 2)

stan_data = list(
  N = 2,
  P = 2,
  M = 2,
  G = G,
  g0 = g0,
  CI = CI,
  ci0 = ci0,
  CE = CE,
  ce0 = ce0
)

idk = sampling(
  model,
  stan_data,
  iter = 1,
  chains = 1
)

idfk = extract(idk)
xhat = idfk$x[1, ]

all(t(CI) %*% xhat + ci0 >= rep(0, 2))
