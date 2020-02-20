library(rstan)

setwd("~/Desktop/misc/quadprog")

model <- stan_model(file = "quadprog_test_model.stan",
               allow_undefined = TRUE,
               includes = paste0('\n#include "', file.path(getwd(), 'quadprog.hpp'), '"\n'))

print(model@model_name)