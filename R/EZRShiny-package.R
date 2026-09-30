#' EZRShiny: Build Consistent 'shiny' App Layouts with Less Code
#'
#' EZRShiny wraps 'shiny', 'bslib' and 'shinyjs' so every app shares the same
#' layout and behaviour with far less code.
#'
#' The functions fall into five groups:
#'
#' * **Page:** [UINav()] builds the whole page: navigation bar, logos, app
#'   name and dark mode switch.
#' * **Tabs:** [singleTab()], [sidebarLevelTab()], [biLevelTab()] and
#'   [triLevelTab()] make top-level tabs. [subTab()], [subSidebarTab()],
#'   [triSubTab()], [triSubSidebarTab()] and [subTwoColPage()] go inside them.
#' * **Inputs:** [navButton()], [navSelect()], [navUpload()], [navDownload()],
#'   [navCheckbox()], [navText()], [navNumeric()], [navColor()] and
#'   [navDate()]. Each accepts a `tooltipText`.
#' * **Outputs:** [navOutputTable()], [navOutputPlot()], [navOutputPlotly()],
#'   [navOutputGirafe()], [navOutputPic()], [sideNavOutputPic()] and
#'   [navOutputText()].
#' * **Server helpers:** [activateItems()], [deactivateItems()],
#'   [showNavTabs()], [hideNavTabs()], [startSection()] and [endSection()].
#'
#' To start a new app, run [createEZApp()]. To see a complete working app, run
#' [runExampleApp()]. The "Getting started" vignette walks through both:
#' `vignette("getting-started", package = "EZRShiny")`.
#'
#' @section Options:
#' * `EZRShiny.cardHeight`: default height of the card that holds each tab's
#'   contents. Defaults to `"85vh"` (85% of the window height).
#'
#' @keywords internal
"_PACKAGE"
