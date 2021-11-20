functions {
  (int, array[] (int, real)) foo(int x, array[,] (array[] (int,int), array[,] int) x2) {
      // ...
  }
}
transformed data {
  (int, real) x;

  (array[10] int, real) y;
  
  array[5] (array[10] (int, array[1,2,3] real), real) y2;
  
  (int, real, array[2] (int, int)) d = (1, 2.5, {(1,2), (3,4)});
}

transformed parameters {
   matrix[N, N] a;
   vector[N] L;
   vector[U] U;
   (L, U) = svd(a);
}