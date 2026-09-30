# Default height of the card holding a tab's contents
cardHeight <- function(){
  getOption("EZRShiny.cardHeight", "85vh")
}


# ___________________ ----
# Nav Tab Levels ----

#' Top-level tabs
#'
#' Tabs that go directly inside [UINav()]. Pick one by how much the tab holds:
#'
#' | Function            | Holds                                  | Put inside it |
#' |---------------------|----------------------------------------|---------------|
#' | `singleTab()`       | one page                               | inputs and outputs |
#' | `sidebarLevelTab()` | one page with a sidebar                | inputs and outputs |
#' | `biLevelTab()`      | a row of sub tabs                      | [subTab()], [subSidebarTab()] |
#' | `triLevelTab()`     | a drop-down menu of tabs with sub tabs | [triSubTab()], [triSubSidebarTab()] |
#'
#' @param title Tab name shown in the navigation bar.
#' @param ... Contents. See the table above.
#' @param sidebarElements A `list()` of inputs for the sidebar.
#' @param icon Optional icon shown before the title, for example
#'   `bsicons::bs_icon("table")`.
#' @param id ID of the row of sub tabs, used with [showNavTabs()] and
#'   [hideNavTabs()]. Defaults to the title with spaces removed.
#' @param height Height of the card holding the tab's contents. Change the
#'   default for every tab with `options(EZRShiny.cardHeight = "70vh")`.
#'
#' @return A 'bslib' navigation panel or menu.
#' @name topTabs
#' @examples
#' singleTab("About", shiny::p("This app explores the Titanic data."))
#'
#' sidebarLevelTab("Plot",
#'   sidebarElements = list(navButton("makePlot", "Make plot")),
#'   navOutputPlot("thePlot")
#' )
#'
#' biLevelTab("Explore",
#'   subTab("Summary", navOutputTable("summaryTable")),
#'   subTab("Plots", navOutputPlot("summaryPlot"))
#' )
#'
#' triLevelTab("Analyses",
#'   triSubTab("Group A",
#'     subTab("Table", navOutputTable("tableA"))
#'   ),
#'   triSubTab("Group B",
#'     subTab("Table", navOutputTable("tableB"))
#'   )
#' )
NULL

#' @rdname topTabs
#' @export
triLevelTab <- function(title, ..., icon = NULL){
  bslib::nav_menu(title, icon = icon, ...)
}

#' @rdname topTabs
#' @export
biLevelTab <- function(title, ..., icon = NULL, id = title, height = cardHeight()){
  id <- gsub(" ","", id)
  bslib::nav_panel(title, icon = icon,
                   bslib::navset_card_underline( height = height, id = id, ...))
}

#' @rdname topTabs
#' @export
sidebarLevelTab <- function(title, sidebarElements = NULL, ..., icon = NULL,
                            height = cardHeight()){
  bslib::nav_panel(title = title, icon = icon, bslib::card( height = height,
    bslib::layout_sidebar(
      sidebar = bslib::sidebar(
        sidebarElements
      ),
      ...
    )
  ))
}

#' @rdname topTabs
#' @export
singleTab <- function(title, ..., icon = NULL, height = cardHeight()){
  bslib::nav_panel(title, icon = icon, bslib::card( height = height, ...))
}


# ___________________ ----
# Nav Sub Tabs ----

#' Sub tabs
#'
#' Tabs that go inside a [biLevelTab()] or a [triLevelTab()]:
#'
#' | Function             | Goes inside       | Holds |
#' |----------------------|-------------------|-------|
#' | `subTab()`           | `biLevelTab()`, `triSubTab()`, `triSubSidebarTab()` | inputs and outputs |
#' | `subSidebarTab()`    | `biLevelTab()`, `triSubTab()`, `triSubSidebarTab()` | a sidebar plus inputs and outputs |
#' | `triSubTab()`        | `triLevelTab()`   | `subTab()`, `subSidebarTab()` |
#' | `triSubSidebarTab()` | `triLevelTab()`   | a sidebar plus `subTab()`, `subSidebarTab()` |
#'
#' `subTwoColPage()` isn't a tab: it splits a page into two equal columns and
#' can go inside any tab.
#'
#' @param title Tab name shown in the tab strip or menu.
#' @param ... Contents. See the table above.
#' @param sidebarElements A `list()` of inputs for the sidebar.
#' @param value ID of the tab, used with [showNavTabs()], [hideNavTabs()] and
#'   [bslib::nav_select()]. Defaults to the title with spaces removed.
#' @param id ID of the row of sub tabs inside the tab. Defaults to the title
#'   with spaces removed.
#' @param icon Optional icon shown before the title.
#' @param height Height of the card holding the tab's contents.
#' @param leftSide,rightSide Contents of the left and right columns. Wrap
#'   several items in `shiny::tagList()`.
#'
#' @return A 'bslib' navigation panel, or for `subTwoColPage()` a column layout.
#' @name subTabs
#' @examples
#' biLevelTab("Explore",
#'   subSidebarTab("PCA",
#'     sidebarElements = list(navButton("runPCA", "Create PCA")),
#'     navOutputPlotly("pcaPlot")
#'   ),
#'   subTab("Table",
#'     subTwoColPage(navOutputTable("tableLeft"), navOutputTable("tableRight"))
#'   )
#' )
NULL

#' @rdname subTabs
#' @export
triSubTab <- function(title, ..., icon = NULL, id = title, height = cardHeight()){
  id <- gsub(" ","", id)
  bslib::nav_panel(title, icon = icon, bslib::navset_card_underline( height = height, id = id,
    navItem(shiny::strong(paste0("- ",title," -"))), ...))
}

#' @rdname subTabs
#' @export
subTab <- function(title, ..., value = title){
  value <- gsub(" ","", value)
  bslib::nav_panel(title, value = value, ...)
}

#' @rdname subTabs
#' @export
subSidebarTab <- function(title, sidebarElements = NULL, ..., value = title, icon = NULL){
  value <- gsub(" ","", value)
  bslib::nav_panel(title = title, value = value, icon = icon,
    bslib::layout_sidebar(
      sidebar = bslib::sidebar(
        sidebarElements
      ),
      ...
    )
  )
}

#' @rdname subTabs
#' @export
triSubSidebarTab <- function(title, sidebarElements = NULL, ..., icon = NULL, id = title,
                             height = cardHeight()){
  id <- gsub(" ","", id)
  bslib::nav_panel(title = title, icon = icon,
    bslib::layout_sidebar(
      sidebar = bslib::sidebar(
        sidebarElements
      ),
      bslib::navset_card_underline( height = height, id = id,
        navItem(shiny::strong(paste0("- ",title," -"))), ...
      )
    )
  )
}

#' @rdname subTabs
#' @export
subTwoColPage <- function(leftSide, rightSide) {
  bslib::layout_columns(
    col_widths = c(6, 6),
    fillable = FALSE,
    bslib::nav_item(leftSide),
    bslib::nav_item(rightSide)
  )
}
