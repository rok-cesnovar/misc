# the script requires the following packages:
# Rcpp and RcppEigen, cmdstanr

setwd("~/Desktop/misc/expose_cmdstanr_functions/")
source("./expose_cmdstanr_functions.R")

model_code <- "
functions {
  vector foo(vector a, vector b) {
    return a + b;
  }
}
"
model_path <- cmdstanr::write_stan_file(model_code)
expose_cmdstanr_function(model_path)

a <- foo(c(1, 2, 3), c(4, 5, 6))