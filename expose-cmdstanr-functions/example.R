# the script requires the following packages:
# Rcpp and RcppEigen, cmdstanr

source("./expose_cmdstanr_functions.R")

model_code <- "
functions {
  vector foo(vector a, vector b) {
    return a + b;
  }
}
"
model_path <- cmdstanr::write_stan_file(model_code)
udfs <- expose_cmdstanr_functions(model_path)

a <- udfs$foo(c(1, 2, 3), c(4, 5, 6))
