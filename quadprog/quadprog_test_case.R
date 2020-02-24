library(rstan)

setwd("~/Desktop/misc/quadprog")


model <- stan_model(file = "quadprog_test_model.stan",
               allow_undefined = TRUE,
               includes = paste0('\n#include "', file.path(getwd(), 'quadprog.hpp'), '"\n'),
               verbose = FALSE)
print(model@model_name)


# test that matches the one in quadprog.cpp

G <- t(matrix(c(2.1, 0.0, 1.0,
    1.5, 2.2, 0.0,
    1.2, 1.3, 3.1), 3,3))

g0 <- c(6, 1, 1);

CE <- matrix(c(1, 2, -1),3,1);

ce0 <- c(-4);
dim(ce0) <- c(1)

# I had to be careful here so that the matrix actually looks like this: 
#      [,1] [,2] [,3] [,4]
# [1,]    1    0    0   -1
# [2,]    0    1    0   -1
# [3,]    0    0    1    0
CI <- t(matrix(c(1, 0, 0, -1,
        0, 1, 0, -1,
        0, 0, 1,  0), 4,3))

ci0 <- c(0, 0, 0, 10);

stan_data = list(
  N = 3,
  P = 1,
  M = 4,
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

print(idfk)
