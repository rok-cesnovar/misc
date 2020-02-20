functions {
  
  vector solve_quadprog(matrix G, vector g0, matrix CE, vector ce0,
                        matrix CI, vector ci0);
  
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
}

transformed data{
  
}

parameters{
  real y;
}
model {
  y ~ normal(0,1);
}
generated quantities {
  vector[N] x = solve_quadprog(G, g0, CE, ce0, CI, ci0);
}
