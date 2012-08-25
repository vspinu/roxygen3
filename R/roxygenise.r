#' @param roccer a list of roccers that you want to use.  By default these
#'   will just be the roccers provided by roxygen3.
#' @param path path to package
#' @auto_imports
roxygenise <- function(path, roccers = base_roccers()) {
  pkg <- as.package(path)
  
  load_all(pkg)
  in_dir(pkg$path, {
    rocblocks <- parse_directory("R", ns_env(pkg))

    # Roccers need to be run in a specific order and later roccers need to be
    # able to see results of earlier roccers.
    for (roccer in roccers) {
      rocblocks <- parse_rocblocks(roccer$parser, rocblocks)
    }

    # Rocouts can be run in any order and are completely independent.
    write_out(roccers, rocblocks, ".")
    
  })
}

#' @importFrom digest digest
block_parse <- function(text, roccers = base_roccers()) {
  pkg_dummy <- structure(
    list(path = tempfile(), package = "temp", version = 0.01), 
    class = "package")  
  env <- devtools:::create_ns_env(pkg_dummy)
  on.exit(unload(pkg_dummy))
  
  src <- srcfilecopy(digest(text), text)
  expr <- parse(text = text, srcfile = src)
  eval(expr, env = env)
  
  lines <- str_split(text, "\n")[[1]]
  
  rocblocks <- parse_text(lines, env, src)
  for (roccer in roccers) {
    rocblocks <- parse_rocblocks(roccer$parser, rocblocks)
  }
  
  rocblocks[[1]]$roc
}

block_out <- function(text, roccers = base_roccers()) {
  parsed <- block_parse(text, roccers)
  generate_output(roccers, list(list(roc = parsed)))
}