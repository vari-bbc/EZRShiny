# EZRShiny

EZRShiny helps you build multi-page 'shiny' apps that all look and work the same way, with far less code. Describe your app as a set of tabs, fill them with inputs and outputs, and EZRShiny builds the page: navigation bar, logos, app name, sidebars, tooltips and a dark mode switch.

```r
library(EZRShiny)

ui <- UINav(
  appName = "My App",
  barColor = "#1F4E79",

  singleTab("Upload",
    navUpload("dataUpload", "Upload a CSV",
              tooltipText = "CSV files only"),
    navButton("runData", "Run")
  ),

  biLevelTab("Results",
    subSidebarTab("Table",
      sidebarElements = list(navDownload("tableDownload", "Download table")),
      navOutputTable("resultsTable")
    ),
    subTab("Plot",
      navOutputPlot("resultsPlot")
    )
  )
)
```

## Installation

Once EZRShiny is on CRAN:

```r
install.packages("EZRShiny")
```

Until then, install the latest version from GitHub:

```r
# install.packages("remotes")
remotes::install_github("vari-bbc/EZRShiny")
```

This skips the "Getting started" guide by default. To install the guide too,
so `vignette("getting-started", package = "EZRShiny")` works (this needs
[pandoc](https://pandoc.org/installing.html), which RStudio includes):

```r
remotes::install_github("vari-bbc/EZRShiny", build_vignettes = TRUE)
```

Or install from a local copy of the folder:

```r
# install.packages("devtools")
devtools::install("path/to/EZRShiny")
```

## Getting started

Start a new app from the template:

```r
EZRShiny::createEZApp("myApp", appName = "My App")
shiny::runApp("myApp")
```

Or open the example app, which explores who survived the Titanic and uses
every kind of tab:

```r
EZRShiny::runExampleApp()
```

Then read the guide, which covers the folder layout, every tab, input and
output function, and the server helpers:

```r
vignette("getting-started", package = "EZRShiny")
```

## What's included

| Group | Functions |
|-------|-----------|
| Page | `UINav()` |
| Top-level tabs | `singleTab()`, `sidebarLevelTab()`, `biLevelTab()`, `triLevelTab()` |
| Sub tabs | `subTab()`, `subSidebarTab()`, `triSubTab()`, `triSubSidebarTab()`, `subTwoColPage()` |
| Inputs | `navButton()`, `navSelect()`, `navUpload()`, `navDownload()`, `navCheckbox()`, `navText()`, `navNumeric()`, `navColor()`, `navDate()`, `navSpanText()` |
| Outputs | `navOutputTable()`, `navOutputPlot()`, `navOutputPlotly()`, `navOutputGirafe()`, `navOutputPic()`, `sideNavOutputPic()`, `navOutputText()` |
| Server | `activateItems()`, `deactivateItems()`, `showNavTabs()`, `hideNavTabs()`, `startSection()`, `endSection()` |
| Files | `sourceFunctions()`, `createEZApp()`, `runExampleApp()` |
