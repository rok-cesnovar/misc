data {
    int N;
    int M;

    int a[N];
    array[N] int a_new;

    vector[M] b[N];
    array[N] vector[M] b_new;

    matrix[M, M] c[N];
    array[N] matrix[M, M] c;

    int d[N, N, 1, 2, 3];
    array[N, N, 1, 2, 3] int d;
}