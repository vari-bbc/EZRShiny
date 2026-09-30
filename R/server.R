# ___________________ ----
# Deactivate and Activate Items ----

#' Switch inputs on and off
#'
#' Greys out inputs so they can't be used, or makes them usable again. Use this
#' in the server to stop users clicking a button or download before the app is
#' ready for it, for example deactivating every download at start and
#' activating each one once there is something to download.
#'
#' Needs `shinyjs::useShinyjs()` in the UI, which [UINav()] adds for you.
#'
#' @param itemIDs IDs of the inputs to switch, as a character vector.
#'
#' @return `NULL`, invisibly. Called for its effect on the page.
#' @export
#' @examples
#' if (interactive()) {
#'   shiny::shinyApp(
#'     ui = UINav(
#'       appName = "Demo",
#'       singleTab("Home",
#'         navCheckbox("ready", "Ready to download?"),
#'         navDownload("theDownload", "Download")
#'       )
#'     ),
#'     server = function(input, output, session) {
#'       shiny::observe({
#'         if (isTRUE(input$ready)) {
#'           activateItems("theDownload")
#'         } else {
#'           deactivateItems("theDownload")
#'         }
#'       })
#'     }
#'   )
#' }
deactivateItems <- function(itemIDs){
  for (itemID in itemIDs){
    shinyjs::toggleState(id = itemID, condition = FALSE)
  }
  invisible(NULL)
}

#' @rdname deactivateItems
#' @export
activateItems <- function(itemIDs){
  for (itemID in itemIDs){
    shinyjs::toggleState(id = itemID, condition = TRUE)
  }
  invisible(NULL)
}


# ___________________ ----
# Hide and Show Tabs ----

#' Hide and show tabs
#'
#' Hides tabs until they are useful, for example the results tabs before any
#' data has been uploaded, and shows them again from the server.
#'
#' `rootID` is the `id` of the [biLevelTab()], [triSubTab()] or
#' [triSubSidebarTab()] holding the tabs, or `"root"` for the top-level tabs in
#' the navigation bar. `tabIDs` are the tabs to hide or show:
#'
#' * Sub tabs: their `value`s. These default to the title with spaces removed,
#'   and spaces are removed here too, so the titles themselves work.
#' * Top-level tabs (`rootID = "root"`): their titles, exactly as written,
#'   spaces included.
#'
#' `showNavTabs()` also selects the first tab in `tabIDs`, briefly selecting
#' the second first, so the tab's contents are drawn straight away.
#'
#' @param rootID ID of the row of tabs.
#' @param tabIDs IDs of the tabs to hide or show, as a character vector.
#'
#' @return `NULL`, invisibly. Called for its effect on the page.
#' @export
#' @examples
#' if (interactive()) {
#'   shiny::shinyApp(
#'     ui = UINav(
#'       appName = "Demo",
#'       biLevelTab("Results",
#'         subTab("Start", navButton("go", "Show the results")),
#'         subTab("Table", navOutputText("tableText")),
#'         subTab("Plot", navOutputText("plotText"))
#'       )
#'     ),
#'     server = function(input, output, session) {
#'       hideNavTabs("Results", c("Table", "Plot"))
#'       shiny::observeEvent(input$go, {
#'         showNavTabs("Results", c("Table", "Plot"))
#'       })
#'     }
#'   )
#' }
hideNavTabs <- function(rootID, tabIDs){
  rootID <- gsub(" ","", rootID)
  tabIDs <- tabValues(rootID, tabIDs)

  for (tabID in tabIDs){
    bslib::nav_hide(rootID, tabID)
  }
  invisible(NULL)
}

#' @rdname hideNavTabs
#' @export
showNavTabs <- function(rootID, tabIDs){

  rootID <- gsub(" ","", rootID)
  tabIDs <- tabValues(rootID, tabIDs)

  for (tabID in tabIDs){
    bslib::nav_show(rootID, tabID)
  }
  # Gets it to load
  if (length(tabIDs) > 1){
    bslib::nav_select(rootID, tabIDs[2])
  }
  if (length(tabIDs) > 0){
    bslib::nav_select(rootID, tabIDs[1])
  }
  invisible(NULL)
}

# Top-level tabs keep their title as their value; sub tabs have spaces removed
tabValues <- function(rootID, tabIDs){
  if (rootID == "root") tabIDs else gsub(" ", "", tabIDs)
}
