#' Start a new app from the EZRShiny template
#'
#' Creates a folder holding a ready-to-edit app laid out the standard way:
#'
#' * `app.R`: the app, with numbered sections for loading packages, the UI and
#'   the server, and comments explaining what goes where.
#' * `Functions/`: put your helper `.R` files here. `app.R` loads them all
#'   with [sourceFunctions()].
#' * `www/`: put images such as logos here. Give just the file name to
#'   `UINav(logoFile = ...)`.
#' * `Necessary_Files/`: put files the app needs at start, such as a data
#'   template users can download.
#'
#' Open `app.R` and run it with `shiny::runApp("<path>")` or the Run App button.
#'
#' @param path Folder to create the app in. It is created if needed.
#' @param appName Name shown in the app's navigation bar.
#' @param overwrite `TRUE` to replace an existing `app.R` in `path`.
#'
#' @return The path to the new `app.R`, invisibly.
#' @export
#' @examples
#' appFolder <- file.path(tempdir(), "myFirstApp")
#' createEZApp(appFolder, appName = "My First App")
#' list.files(appFolder)
#'
#' if (interactive()) {
#'   shiny::runApp(appFolder)
#' }
createEZApp <- function(path, appName = "My App", overwrite = FALSE){
  appFile <- file.path(path, "app.R")
  if (file.exists(appFile) && !overwrite){
    stop("There is already an app.R in '", path, "'. ",
         "Pick a new folder, or use overwrite = TRUE to replace it.", call. = FALSE)
  }

  for (folder in c("Functions", "www", "Necessary_Files")){
    dir.create(file.path(path, folder), recursive = TRUE, showWarnings = FALSE)
  }

  template <- readLines(system.file("templates", "app", "app.R", package = "EZRShiny"))
  template <- gsub("{{appName}}", gsub('"', '\\\\"', appName), template, fixed = TRUE)
  writeLines(template, appFile)

  message("Created a new app in '", path, "'. Open app.R to start building.")
  invisible(appFile)
}

#' Run the example Titanic app
#'
#' Opens "Titanic Explorer", a complete example app built with EZRShiny that
#' explores who survived the Titanic, using R's built-in [datasets::Titanic]
#' data. It uses every kind of tab (a single page, a page with a sidebar, a
#' row of sub tabs and a drop-down menu of tabs), hides tabs until they are
#' useful, switches buttons on and off, and follows the standard folder layout:
#'
#' * `app.R`: packages, UI and server.
#' * `Functions/`: helper functions, loaded with [sourceFunctions()].
#' * `Necessary_Files/`: the Titanic data as a CSV, one row per person.
#' * `www/`: the logo shown in the navigation bar.
#'
#' Its code is a good starting point for your own app. Find it with
#' `system.file("examples", "titanicExplorer", package = "EZRShiny")`.
#'
#' Needs the 'ggplot2' package.
#'
#' @param ... Passed to [shiny::runApp()], for example `launch.browser = TRUE`.
#'
#' @return Does not return while the app is running.
#' @export
#' @examples
#' # Where the example app's files are:
#' list.files(system.file("examples", "titanicExplorer", package = "EZRShiny"),
#'            recursive = TRUE)
#'
#' if (interactive()) {
#'   runExampleApp()
#' }
runExampleApp <- function(...){
  if (!requireNamespace("ggplot2", quietly = TRUE)){
    stop("The example app needs the 'ggplot2' package. ",
         "Install it with install.packages(\"ggplot2\").", call. = FALSE)
  }
  shiny::runApp(system.file("examples", "titanicExplorer", package = "EZRShiny"), ...)
}
