# ___________________ ----
# Logs ----

#' Mark the start and end of a section of server code in the log
#'
#' Writes a short marker to the console so the app's log shows which part of
#' the server is running. Put `startSection()` at the top of an
#' `observeEvent()` and `endSection()` at the bottom, using the same name.
#' Markers are sent as messages, so `suppressMessages()` hides them.
#'
#' @param sectionName Name of the section, shown in the log.
#'
#' @return `NULL`, invisibly. Called for the message it writes.
#' @export
#' @examples
#' startSection("Read in data")
#' endSection("Read in data")
startSection <- function(sectionName){
  message("")
  message(paste0("----", sectionName, " Start"))
  invisible(NULL)
}

#' @rdname startSection
#' @export
endSection <- function(sectionName){
  message(paste0("----", sectionName, " Done"))
  invisible(NULL)
}
