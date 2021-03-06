\name{split_df}
\alias{is.split_df}
\alias{split_df}
\title{Create a "split_df" object.}
\usage{
split_df(data, split, env = NULL)

is.split_df(x)
}
\arguments{
  \item{data}{A data frame.}

  \item{split}{A quoted expression or list of quoted
  expressions which, when evaluated with \code{data} (and
  optionally \code{env}), specifies the split groups.}

  \item{env}{An enclosing environment in which to evaluate
  \code{split}.}

  \item{x}{object to test for split_df-ness}
}
\description{
  An split_df object represents a data frame that has been
  split into multiple pieces according to the value of some
  variable (or variables, or functions of variables).
}
\details{
  This function is designed to create \code{split_df}
  objects by hand: generally, users of ggvis should create
  these objects with the helper \code{\link{by_group}}
  function.
}
\keyword{internal}

