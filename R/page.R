# ___________________ ----
# Shiny Nav Base ----

#' Build the app's page
#'
#' The outermost UI function: use it as `ui <- UINav(...)`. It builds a page
#' with a navigation bar across the top holding, from left to right, any
#' logos, the app name, one entry per tab you pass in, and a dark mode switch
#' on the far right.
#'
#' Pass tabs made with [singleTab()], [sidebarLevelTab()], [biLevelTab()] or
#' [triLevelTab()]. The navigation bar has the ID `"root"`, so the server can
#' change tab with `bslib::nav_select("root", "<tab title>")`.
#'
#' @param ... Tabs to show in the navigation bar.
#' @param logoFile File names of images to show at the left of the navigation
#'   bar, in order. Put the images in the app's `www` folder and give just the
#'   file name, for example `"logo.png"` (png, svg, jpg or gif). `NULL` (the
#'   default) or `""` shows no logo.
#' @param appName App name shown after the logos. If left `NULL`, a global
#'   variable called `appName` is used, or no name if there isn't one.
#' @param logoHeight Height of each logo, as a CSS size. A single value is used
#'   for every logo.
#' @param barColor Background color of the navigation bar, as a color name or
#'   hex code, for example `"#005596"`. `NULL` uses the theme's default. Text
#'   color switches between light and dark to stay readable.
#' @param theme A [bslib::bs_theme()] to style the whole app, for example
#'   `bslib::bs_theme(primary = "#005596", preset = "cosmo")`.
#'
#' @return A 'shiny' page to use as the app's UI.
#' @export
#' @examples
#' ui <- UINav(
#'   appName = "My App",
#'   barColor = "#005596",
#'   singleTab("Upload",
#'     navUpload("dataUpload", "Upload a CSV")
#'   ),
#'   singleTab("Results",
#'     navOutputTable("resultsTable")
#'   )
#' )
#'
#' if (interactive()) {
#'   shiny::shinyApp(ui, function(input, output, session) {})
#' }
UINav <- function( ...,logoFile = NULL, appName = NULL, logoHeight = "40vh",
                   barColor = NULL, theme = bslib::bs_theme()){
  # If appName is not given, look for a global appName variable (blank if none)
  if (is.null(appName)){
    appName <- get0("appName", envir = globalenv(), inherits = FALSE, ifnotfound = "")
  }

  # Logo(s) (Must be: png, svg, jpg, or gif)
  logoFile <- logoFile[!is.na(logoFile) & nzchar(logoFile)]
  logoHeight <- rep_len(logoHeight, length(logoFile))
  logoItems <- lapply(seq_along(logoFile), function(i){
    navItem(shiny::img(src = logoFile[i], height = logoHeight[i]))
  })

  navContents <- c(
    # Logo and title
    logoItems,
    list(navItem(shiny::h3(appName))),

    # App Contents
    list(...),

    # Dark Mode
    list(bslib::nav_spacer(),
         navDarkSwitch())
  )

  bslib::page_fluid(
    theme = theme,
    shinyjs::useShinyjs(),
    navPadding(),
    do.call(navBar, c(navContents, list(barColor = barColor)))
  )
}


# ___________________ ----
# Basic Nav Pieces ----

#' Building blocks of the navigation bar
#'
#' [UINav()] puts these together for you. They're exported so you can build a
#' custom page from the same pieces.
#'
#' * `navPadding()`: a small spacer above the navigation bar.
#' * `navBar()`: the navigation bar itself, with the ID `"root"`.
#' * `navDarkSwitch()`: the light/dark mode switch.
#' * `navItem()`: wraps anything (an image, a heading, a link) so it can sit in
#'   the navigation bar or a tab strip without being a tab.
#'
#' @param ... Contents: tabs for `navBar()`, anything for `navItem()`.
#' @param barColor Background color of the bar. `NULL` uses the theme's default.
#' @param mode Starting mode for the switch: `"dark"` or `"light"`.
#'
#' @return A 'shiny' tag or 'bslib' navigation object.
#' @name navPieces
#' @examples
#' navItem(shiny::strong("Version 1.0"))
#' navDarkSwitch("light")
NULL

#' @rdname navPieces
#' @export
navPadding <- function(){
  shiny::div(style = "padding: 5px 0px;")
}

#' @rdname navPieces
#' @export
navBar <- function(..., barColor = NULL){
  # bslib 0.9.0 moved the bar's color into navbar_options()
  if (utils::packageVersion("bslib") >= "0.9.0"){
    navbarOptions <- getExportedValue("bslib", "navbar_options")
    bslib::navset_bar(id = "root", padding = c("10px","0px"),
                      navbar_options = navbarOptions(bg = barColor),
      ...
    )
  } else {
    bslib::navset_bar(id = "root", padding = c("10px","0px"), bg = barColor,
      ...
    )
  }
}

#' @rdname navPieces
#' @export
navDarkSwitch <- function(mode = "dark"){
  bslib::nav_item( bslib::input_dark_mode(mode = mode) )
}

#' @rdname navPieces
#' @export
navItem <- function(...){
  bslib::nav_item(shiny::div(style="padding: 0px 10px", ...))
}
