#include "eiquadprog.hpp"
#include <iostream>
//g++ eiquadprog.cpp -I"/home/rok/R/x86_64-pc-linux-gnu-library/3.5/Rcpp/include/"  -I"/home/rok/R/x86_64-pc-linux-gnu-library/3.5/RcppEigen/include/"  -I"/home/rok/R/x86_64-pc-linux-gnu-library/3.5/RcppEigen/include/unsupported"  -I"/home/rok/R/x86_64-pc-linux-gnu-library/3.5/BH/include" -I"/home/rok/R/x86_64-pc-linux-gnu-library/3.5/StanHeaders/include/src/"  -I"/home/rok/R/x86_64-pc-linux-gnu-library/3.5/StanHeaders/include/"  -I"/home/rok/R/x86_64-pc-linux-gnu-library/3.5/rstan/include"
//g++ eiquadprog.cpp -I"/Library/Frameworks/R.framework/Versions/3.5/Resources/library/Rcpp/include/"  -I"/Library/Frameworks/R.framework/Versions/3.5/Resources/library/RcppEigen/include/"  -I"/Library/Frameworks/R.framework/Versions/3.5/Resources/library/RcppEigen/include/unsupported"  -I"/Library/Frameworks/R.framework/Versions/3.5/Resources/library/BH/include" -I"/Library/Frameworks/R.framework/Versions/3.5/Resources/library/StanHeaders/include/src/"  -I"/Library/Frameworks/R.framework/Versions/3.5/Resources/library/StanHeaders/include/"  -I"/Library/Frameworks/R.framework/Versions/3.5/Resources/library/rstan/include"

void test_case_1(){
  Eigen::MatrixXd G(3,3); 
  Eigen::VectorXd g0(3);
  Eigen::MatrixXd CE(3,1);
  Eigen::VectorXd ce0(1);
  Eigen::MatrixXd CI(3,4); 
  Eigen::VectorXd ci0(4);
  
  G << 2.1, 0.0, 1.0,
       1.5, 2.2, 0.0,
       1.2, 1.3, 3.1;
  
  g0 << 6, 1, 1;
  
  CE << 1, 2, -1;
  
  ce0(0)=-4;
  
  CI << 1, 0, 0, -1,
        0, 1, 0, -1,
        0, 0, 1,  0;
  
  
  ci0 << 0, 0, 0, 10;
  

  Eigen::VectorXd x(g0.size());
  double f = solve_quadprog(G, g0,  CE, ce0,  CI, ci0, x);
  std::cout << "test case 1 - x: ";
  for (int i = 0; i < x.size(); i++)
    std::cout << x(i) << ' ';
  std::cout << std::endl;
}

void test_case_2(){
  Eigen::MatrixXd G(2,2); 
  Eigen::VectorXd g0(2);
  Eigen::MatrixXd CE(2,2);
  Eigen::VectorXd ce0(2);
  Eigen::MatrixXd CI(2,2); 
  Eigen::VectorXd ci0(2);
  
  G << 2.0, 0.0,
       0.0, 2.0;
  
  g0 << 6, -6;
  
  CE << 0, 0, 0, 0;
  
  ce0 << 0, 0;
  
  CI << 1, 0,
        0, 1;
  
  ci0 << 0, 0;
  
  Eigen::VectorXd x(g0.size());
  double f = solve_quadprog(G, g0,  CE, ce0,  CI, ci0, x);
  std::cout << "test case 2 - x: ";
  for (int i = 0; i < x.size(); i++)
    std::cout << x(i) << ' ';
  std::cout << std::endl;
}

int main(int argc, char** argv){
  test_case_1();
  test_case_2();
  return(0);
}
