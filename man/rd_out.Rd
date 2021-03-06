\name{rd_out}

\alias{rd_out}

\title{[DEV] Output to Rd files in the man directory.}

\usage{
  rd_out(tag, name = NULL)
}

\arguments{
  \item{tag}{a function that takes a single argument (tag)
  as input, and returns a list of \code{rd_commands} as
  output}

  \item{name}{input tag name, usually set by
  \code{\link{roccer}}.}
}

\description{
  This function is useful only for developers

  This uses the \code{@rdname} tag to determine which file
  the output from each rocblock is sent to.
}

\details{
  Only one of \code{tag} and \code{out} can be supplied.
}

% Generated by roxygen from [R/output-rd.r]
