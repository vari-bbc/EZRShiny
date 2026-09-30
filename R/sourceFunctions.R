# ___________________ ----
# Load functions ----

#' Source every R file in a folder
#'
#' Loads all of an app's helper functions in one call, so `app.R` doesn't need
#' a `source()` line per file. Every file ending in `.R` in the folder is
#' sourced, in alphabetical order. Subfolders are not searched.
#'
#' A relative path is looked up from the working directory first. If it isn't
#' found there, it is looked up from the project root with [here::here()].
#'
#' @param functionFolderPath Path to the folder holding the `.R` files, for
#'   example `"Functions"`.
#' @param envir Environment to load the functions into. Defaults to the one
#'   `sourceFunctions()` is called from, which in `app.R` is the global
#'   environment.
#'
#' @return The paths of the sourced files, invisibly.
#' @export
#' @examples
#' folder <- file.path(tempdir(), "Functions")
#' dir.create(folder, showWarnings = FALSE)
#' writeLines("addOne <- function(x) x + 1", file.path(folder, "addOne.R"))
#'
#' sourceFunctions(folder)
#' addOne(1)
sourceFunctions <- function(functionFolderPath, envir = parent.frame()) {
  # Updates the function path to ensure it ends with a "/"
  if (!grepl("/$", functionFolderPath)){
    functionFolderPath <- paste0(functionFolderPath, "/")
  }

  # If the folder isn't found from the working directory, look from the project root
  if (!isAbsolutePath(functionFolderPath) && !dir.exists(functionFolderPath)){
    functionFolderPath <- here::here(functionFolderPath)
  }

  # List all R files in the specified folder
  rFiles <- list.files(path = functionFolderPath, pattern = "\\.R$", full.names = TRUE)
  # Collapse doubled slashes, but keep the leading "//" of a network path
  rFiles <- gsub("([^/])//+", "\\1/", rFiles)

  # Source each R file
  for (file in rFiles) {
    source(file, local = envir)
  }

  invisible(rFiles)
}

# TRUE for "/x", "~/x", "C:/x", "C:\x" and "\\server\x"
isAbsolutePath <- function(path){
  grepl("^(/|~|[A-Za-z]:|\\\\)", path)
}
