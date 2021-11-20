data {
  int<lower=0> N;
  array[N] complex x;
  array[N] complex y;
}
parameters {
  complex alpha;
  complex beta;
  vector[2] sigma;
}
model {
  for (n in 1:N) {
    complex eps_n = y[n] - (alpha + beta * x[n]);  // error
    get_real(eps_n) ~ normal(0, sigma[1]);
    get_imag(eps_n) ~ normal(0, sigma[2]);
    sigma ~ //...hyperprior...
  }
}