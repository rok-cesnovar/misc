library("cmdstanr")

setwd("~/Desktop/misc/quadprog")
set_cmdstan_path('~/Desktop/cmdstan')

my_stan_program <- "../quadprog_test_model.stan"
mod <- cmdstan_model(stan_file = my_stan_program, quiet = FALSE)
