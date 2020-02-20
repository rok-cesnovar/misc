functions {
  
  real solve_quadprog(matrix G, vector g0, matrix CE, vector ce0,
                        matrix CI, vector ci0, vector x);
  
}

data {
  int N;
  int P;
  int M;
  matrix[N,N] G; 
  vector[N] g0;
  matrix[N,P] CE;
  vector[P] ce0;
  matrix[N,M] CI;
  vector[M] ci0;
  vector[N] x;
}

transformed data{
  real res = solve_quadprog(G, g0, CE, ce0, CI, ci0, x);
}

parameters{
  real y;
}
model {
 y ~ normal(0,1);
}
