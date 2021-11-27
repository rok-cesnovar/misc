expose_cmdstanr_function <- function(model_path){
  if (cmdstanr::cmdstan_version() < "2.26.0") {
    stop("Please install CmdStan version 2.26 or newer.", call. = FALSE)
  }
  get_cmdstan_flags <- function(flag_name) {
    cmdstan_path <- cmdstanr::cmdstan_path()
    flags <- processx::run(
      "make", 
      args = c(paste0("print-", flag_name)),
      wd = cmdstan_path
    )$stdout
    flags <- gsub(
      pattern = paste0(flag_name, " ="),
      replacement = "", x = flags, fixed = TRUE
    )
    flags <- gsub(
      pattern = " stan/", replacement = paste0(" ", cmdstan_path, "/stan/"),
      x = flags, fixed = TRUE
    )
    flags <- gsub(
      pattern = "-I lib/", replacement = paste0("-I ", cmdstan_path, "/lib/"),
      x = flags, fixed = TRUE
    )
    flags <- gsub(
      pattern = "-I src", replacement = paste0("-I ", cmdstan_path, "/src"),
      x = flags, fixed = TRUE
    )
    gsub("\n", "", flags)
  }
  temp_stan_file <- tempfile(pattern = "model-", fileext = ".stan")
  temp_cpp_file <- paste0(tools::file_path_sans_ext(temp_stan_file), ".cpp")
  file.copy(model_path, temp_stan_file, overwrite = TRUE)
  if (isTRUE(.Platform$OS.type == "windows")) {
    stanc3 <- "./bin/stanc.exe"
  } else {
    stanc3 <- "./bin/stanc"
  }
  processx::run(
    stanc3,
    args = c(
      temp_stan_file,
      "--standalone-functions",
      paste0("--o=",temp_cpp_file)
    ),
    wd = cmdstanr::cmdstan_path()
  )
  
  code <- paste(readLines(temp_cpp_file), collapse = "\n")
  code <- paste("// [[Rcpp::depends(RcppEigen)]]",
                "#include <stan/math/prim/fun/Eigen.hpp>",
                "
#include <RcppCommon.h>
#include <boost/random/additive_combine.hpp>
#include <iostream>

namespace Rcpp {
  SEXP wrap(boost::ecuyer1988 RNG);
  SEXP wrap(boost::ecuyer1988& RNG);
  SEXP wrap(std::ostream stream);
  template <> boost::ecuyer1988 as(SEXP ptr_RNG);
  template <> boost::ecuyer1988& as(SEXP ptr_RNG);
  template <> std::ostream* as(SEXP ptr_stream);
  namespace traits {
    template <> class Exporter<boost::ecuyer1988&>;
    template <> struct input_parameter<boost::ecuyer1988&>;
  }
}


#include <Rcpp.h>

namespace Rcpp {
  SEXP wrap(boost::ecuyer1988 RNG){
    boost::ecuyer1988* ptr_RNG = &RNG;
    Rcpp::XPtr<boost::ecuyer1988> Xptr_RNG(ptr_RNG);
    return Xptr_RNG;
  }

  SEXP wrap(boost::ecuyer1988& RNG){
    boost::ecuyer1988* ptr_RNG = &RNG;
    Rcpp::XPtr<boost::ecuyer1988> Xptr_RNG(ptr_RNG);
    return Xptr_RNG;
  }

  SEXP wrap(std::ostream stream) {
    std::ostream* ptr_stream = &stream;
    Rcpp::XPtr<std::ostream> Xptr_stream(ptr_stream);
    return Xptr_stream;
  }

  template <> boost::ecuyer1988 as(SEXP ptr_RNG) {
    Rcpp::XPtr<boost::ecuyer1988> ptr(ptr_RNG);
    boost::ecuyer1988& RNG = *ptr;
 		return RNG;
  }

  template <> boost::ecuyer1988& as(SEXP ptr_RNG) {
    Rcpp::XPtr<boost::ecuyer1988> ptr(ptr_RNG);
    boost::ecuyer1988& RNG = *ptr;
 		return RNG;
  }

  template <> std::ostream* as(SEXP ptr_stream) {
    Rcpp::XPtr<std::ostream> ptr(ptr_stream);
    return ptr;
  }


  namespace traits {
    template <> class Exporter<boost::ecuyer1988&> {
    public:
      Exporter( SEXP x ) : t(Rcpp::as<boost::ecuyer1988&>(x)) {}
      inline boost::ecuyer1988& get(){ return t ; }
    private:
      boost::ecuyer1988& t ;
    } ;

    template <>
    struct input_parameter<boost::ecuyer1988&> {
      typedef typename Rcpp::ConstReferenceInputParameter<boost::ecuyer1988&> type ;
      //typedef typename boost::ecuyer1988& type ;
    };
  }

}

RcppExport SEXP get_stream_() {
  std::ostream* pstream(&Rcpp::Rcout);
  Rcpp::XPtr<std::ostream> ptr(pstream, false);
  return ptr;
}

RcppExport SEXP get_rng_(SEXP seed) {
  int seed_ = Rcpp::as<int>(seed);
  boost::ecuyer1988* rng = new boost::ecuyer1988(seed_);
  Rcpp::XPtr<boost::ecuyer1988> ptr(rng, true);
  return ptr;
}
",
"#include <RcppEigen.h>",
code, sep = "\n")
  code <- gsub("// [[stan::function]]",
               "// [[Rcpp::export]]", code, fixed = TRUE)
  code <- gsub("stan::math::accumulator<double>& lp_accum__, std::ostream* pstream__ = nullptr){",
               "std::ostream* pstream__ = nullptr){\nstan::math::accumulator<double> lp_accum__;",
               code, fixed = TRUE)
  code <- gsub("= nullptr", "= 0", code, fixed = TRUE)
  
  backup_USE_CXX14 <- Sys.getenv("USE_CXX14")
  backup_PKG_CXXFLAGS <- Sys.getenv("PKG_CXXFLAGS")
  backup_PKG_LIBS <- Sys.getenv("PKG_LIBS")
  
  Sys.setenv(USE_CXX14 = 1)
  Sys.setenv("PKG_CXXFLAGS" = get_cmdstan_flags("CXXFLAGS"))
  Sys.setenv("PKG_LIBS" = paste0(
    get_cmdstan_flags("LDLIBS"), 
    get_cmdstan_flags("LIBSUNDIALS"),
    get_cmdstan_flags("TBB_TARGETS")
  ))
  get_stream <- function() {
    return(.Call('get_stream_'))
  }
  get_rng <- function(seed=0L) {
    if (!identical(seed, 0L)) {
      if (length(seed) != 1)
        stop("Seed must be a length-1 integer vector.")
    }
    return(.Call('get_rng_', seed))
  }
  compiled <- Rcpp::sourceCpp(code = code)
  for (x in compiled$functions) {
    FUN <- get(x, envir = globalenv())
    args <- formals(FUN)
    args$pstream__ <- get_stream()
    if ("lp__" %in% names(args)) args$lp__ <- 0
    if ("base_rng__" %in% names(args)) args$base_rng__ <- get_rng()
    formals(FUN) <- args
    assign(x, FUN, envir = globalenv())
  }
}