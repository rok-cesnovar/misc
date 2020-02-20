library(rstan)

setwd("~/Desktop/misc/quadprog")

model <- stan_model(file = "quadprog_test_model.stan",
               allow_undefined = TRUE,
               includes = paste0('\n#include "', file.path(getwd(), 'quadprog.hpp'), '"\n'))
print(model@model_name)

# Quadprog formulation
library(quadprog)
## Assume we want to minimize: -(0 5 0) %*% b + 1/2 b^T b
## under the constraints: A^T b >= b0
## with b0 = (-8,2,0)^T
## and       (-4 2 0)
## A = (-3 1 -2)
##     ( 0 0 1)
## we can use solve.QP as follows:
Dmat <- matrix(0,3,3)
diag(Dmat) <- 1
dvec <- c(0,5,0)
Amat <- matrix(c(-4,-3,0,2,1,0,0,-2,1),3,3)
bvec <- c(-8,2,0)
solve.QP(Dmat,dvec,Amat,bvec=bvec)

# stan formulation
# min 0.5 * x G x + g0 x
# s.t.
# CE^T x + ce0 = 0
# CI^T x + ci0 >= 0
# 
# The matrix and vectors dimensions are as follows:
#   G: n * n
# g0: n
# 
# CE: n * p
# ce0: p
# 
# CI: n * m
# ci0: m
# 
# x: n
G = Dmat
g0 = dvec
CI = Amat
ci0 = -bvec
CE = matrix(0, 3, 3)
ce0 = c(0,0,0)
x = bvec

# dimensionality checks
0.5 * x %*% G %*% x + g0 %*% x
CE %*% x + ce0
CI %*% x + ci0

stan_data = list(
  N = 3,
  G = G,
  g0 = g0,
  CI = CI,
  ci0 = ci0,
  CE = CE,
  ce0 = ce0,
  x = x
)

idk = sampling(
  model,
  stan_data,
  iter = 1
)

idfk = extract(idk)






