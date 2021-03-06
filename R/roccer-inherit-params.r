inherit_params <- function(rocblocks) {
  
  for(i in seq_along(rocblocks)) {
    obj <- rocblocks[[i]]$obj
    roc <- rocblocks[[i]]$roc
    
    if (!is.function(obj$value)) next
    
    inherit_from <- roc$inheritParams
    if (is.null(inherit_from)) next
    
    inherited <- unlist(lapply(inherit_from, find_params, rocblocks))
    if (is.null(inherited)) {
      message("@inheritParams: can't find topic ", inherit_from)
      next
    }
    
    params <- names(formals(obj$value))
    missing_params <- setdiff(params, names(roc$param))
    matching_params <- intersect(missing_params, names(inherited))

    rocblocks[[i]]$roc$param <- c(roc$param, inherited[matching_params])
  }
  rocblocks
}

#' Inherit parameters from another function.
#'
#' This tag will bring in all documentation for parameters that are
#' undocumented in the current function, but documented in the source
#' function. The source can be a function in the current package,
#' \code{function}, or another package \code{package::function}.
#'
#' @usage @@inheritParams source_function
add_roccer("inheritParams", rocblock_parser(inherit_params))
base_prereqs[["inheritParams"]] <- c("param", "name")


find_params <- function(name, rocblocks) {
  if (str_detect(name, fixed("::"))) {
    # Reference to another package
    pieces <- str_split(name, fixed("::"))[[1]]
    rd <- get_rd(pieces[2], pieces[1])
    if (is.null(rd)) return(NULL)

    rd_arguments(rd)
  } else {
    # Reference within this package
    matching_alias <- function(x) name %in% x$roc$aliases
    matches <- Filter(matching_alias, rocblocks)
    
    if (length(matches) != 1) return(null)
    matches[[1]]$roc$param
  }
}


get_rd <- function(topic, package = NULL) {
  help_call <- substitute(help(t, p), list(t = topic, p = package))
  top <- eval(help_call)
  if (length(top) == 0) return()
  
  utils:::.getHelpFile(top)
}

# rd_arguments(get_rd("mean"))
rd_arguments <- function(rd) {
  arguments <- get_tags(rd, "\\arguments")[[1]]
  items <- get_tags(arguments, "\\item")
  
  values <- lapply(items, function(x) rd2rd(x[[2]]))
  params <- vapply(items, function(x) rd2rd(x[[1]]), character(1))
  
  setNames(values, params)
}

get_tags <- function(rd, tag) {
  rd_tag <- function(x) attr(x, "Rd_tag")

  Filter(function(x) rd_tag(x) == tag, rd)
}

rd2rd <- function(x) {
  paste(unlist(tools:::as.character.Rd(x)), collapse = "")
}
