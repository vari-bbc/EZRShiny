# Example EZRShiny app: explore who survived the Titanic
# Run it with EZRShiny::runExampleApp()
#
# Folder layout:
#   app.R              this file: packages, UI and server
#   Functions/         helper functions, all loaded by sourceFunctions()
#   Necessary_Files/   files the app needs at start (the Titanic data)
#   www/               images for the page (the logo)

# ___________________ ----
# App Startup ----

## 1.0 Load Libraries ----
library(shiny)
library(bslib)
library(shinyjs)
library(DT)
library(plotly)
library(ggiraph)
library(EZRShiny)


## 2.0 Load Basics ----
options(shiny.maxRequestSize = 300 * 1024^2)
sourceFunctions("Functions")


## 3.0 Universal Vars ----
# App Name Here:
appName <- "Titanic Explorer"

# Necessary Files Here:
titanicDataPath <- "Necessary_Files/titanic.csv"

# Necessary Vars Here:
groupOptions <- c("Class", "Sex", "Age")


# ___________________ ----
# UI ----
# Ensure use of document outline and preloading as many inputs as possible
# Tool tips are last in nav item and should be specified with tooltipText = "..."
ui <- UINav(

  # Logo files must be placed in the www folder and must include ".{type}"
  logoFile = "logo.svg",
  appName = appName,
  barColor = "#1F4E79",

  ## 1.0 Load Data (singleTab: one page) ----
  singleTab("Load Data", icon = bsicons::bs_icon("upload"),
    navSpanText("Start here",
                "Use the built-in Titanic data, or upload your own copy in the same layout."),
    navDownload("dataDownload", "Download the Titanic Data",
                tooltipText = "One row per person on board: Class, Sex, Age and Survived."),
    navCheckbox("useBuiltIn", "Use the built-in Titanic data", value = TRUE),
    navUpload("dataUpload", "Or upload your own copy",
              tooltipText = "Needs Class, Sex, Age and Survived columns. Switch off the
              built-in data to use it."),
    navButton("loadData", "Load Data"),
    navOutputText("loadText")
  ),

  ## 2.0 Passengers (sidebarLevelTab: one page with a sidebar) ----
  sidebarLevelTab("Passengers",
    sidebarElements = list(
      navSelect("classFilter", "Class", multiple = TRUE),
      navSelect("sexFilter", "Sex", multiple = TRUE),
      navSelect("ageFilter", "Age", multiple = TRUE),
      navButton("applyFilters", "Apply Filters"),
      navDownload("filteredDownload", "Download These Passengers")
    ),
    navOutputText("filterText"),
    navOutputTable("passengerTable",
                   tooltipText = "Type in the boxes above each column to search within it.")
  ),

  ## 3.0 Survival (biLevelTab: a row of sub tabs) ----
  biLevelTab("Survival",
    ### 3.1 Survival Plot ----
    subSidebarTab("Survival Plot",
      sidebarElements = list(
        navSelect("groupBy", "Group people by", groupOptions),
        navColor("survivedColor", "Color for survived", "#2E86AB"),
        navColor("diedColor", "Color for died", "#C0392B"),
        navText("plotTitle", "Plot title (optional)"),
        navButton("makePlot", "Make Plot"),
        navDownload("plotDownload", "Download Plot")
      ),
      navOutputPlot("survivalPlot")
    ),
    ### 3.2 Survival Table ----
    subTab("Survival Table",
      navOutputTable("survivalTable", label = "Survival by group",
                     tooltipText = "SurvivalRate is the percent of People who Survived.")
    ),
    ### 3.3 Interactive Plot ----
    subTab("Interactive Plot",
      navOutputPlotly("survivalPlotly",
                      tooltipText = "Hover over a bar to see its count. Drag to zoom in, and
                      double-click to zoom back out.")
    )
  ),

  ## 4.0 Compare Groups (triLevelTab: a menu of tabs with sub tabs) ----
  triLevelTab("Compare Groups",
    ### 4.1 By Class ----
    triSubTab("By Class",
      subTab("Class and Sex",
        navOutputGirafe("classSexPlot", label = "Survival rate by class and sex",
                        tooltipText = "Hover over a bar to see how many people it represents.")
      ),
      subTab("Class and Age",
        navOutputGirafe("classAgePlot", label = "Survival rate by class and age",
                        tooltipText = "Hover over a bar to see how many people it represents.")
      )
    ),
    ### 4.2 Custom Comparison ----
    triSubSidebarTab("Custom Comparison",
      sidebarElements = list(
        navSelect("compareOne", "First grouping", groupOptions,
                  selected = "Sex"),
        navSelect("compareTwo", "Second grouping", groupOptions,
                  selected = "Age"),
        navButton("runCompare", "Compare")
      ),
      subTab("Side by Side",
        navOutputText("compareText"),
        subTwoColPage(
          navOutputPlot("compareOnePlot", label = "First grouping"),
          navOutputPlot("compareTwoPlot", label = "Second grouping")
        )
      ),
      subTab("Counts",
        navOutputTable("compareTable")
      )
    )
  )
)


# ___________________ ----
# Server ----

server <- function(input, output, session) {

  ## 1.0 Global Vars ----
  # Any variables here that need to carry across app, but should be local to the user
  # Try to keep all variables inside a list to help with debugging later
  global <- reactiveValues(
    datasets = list(
      allPassengers = NULL,
      filteredPassengers = NULL
    ),
    survivalPlot = NULL
  )


  ## 2.0 Run on Start ----
  # Hide pages and deactivate buttons that should not be used yet
  observe({
    startSection("Run on Start")

    # Hide top-level tabs until there is data to show in them
    hideNavTabs(rootID = "root",
                tabIDs = c("Passengers", "Survival", "Compare Groups"))

    # Hide sub Tabs for tabs we don't want shown at start
    hideNavTabs(rootID = "Survival",
                tabIDs = c("Survival Table", "Interactive Plot"))

    # Deactivate all downloads since there is nothing to download at start
    deactivateItems(c(
      "filteredDownload", "plotDownload"
    ))

    endSection("Run on Start")
  })


  ## 3.0 File Imports ----
  output$dataDownload <- downloadHandler(
    filename = function() {
      "titanic.csv"
    },
    content = function(file) {
      file.copy(titanicDataPath, file, overwrite = TRUE)
    }
  )

  # Only allow loading once there is data to load
  observeEvent(list(input$dataUpload, input$useBuiltIn), {
    if (isTRUE(input$useBuiltIn) || !is.null(input$dataUpload)) {
      activateItems(c("loadData"))
    } else {
      deactivateItems(c("loadData"))
    }
  }, ignoreInit = TRUE)


  ## 4.0 Load Data ----
  observeEvent(input$loadData, {
    startSection("Load Data")

    ## Inputs
    filePath <- if (isTRUE(input$useBuiltIn)) titanicDataPath else input$dataUpload$datapath

    ## Do things
    readIn <- ReadFile(filePath)

    # If the check doesn't pass, write the error message and stop here
    if (readIn$error != "") {
      output$loadText <- renderText({ readIn$error })
      endSection("Load Data")
      return()
    }
    allPassengers <- readIn$TheData

    ## App interactions
    output$loadText <- renderText({
      paste0("Loaded ", nrow(allPassengers), " people.")
    })

    # Fill in the filters, with every option selected
    for (column in groupOptions) {
      choices <- levels(allPassengers[[column]])
      updateSelectizeInput(session, paste0(tolower(column), "Filter"),
                           choices = choices, selected = choices)
    }

    output$passengerTable <- renderDT({
      datatable(allPassengers, rownames = FALSE, filter = "top")
    })
    output$filterText <- renderText({ paste0("Showing all ", nrow(allPassengers), " people.") })

    output$classSexPlot <- renderGirafe({ SurvivalRatePlot(allPassengers, "Class", "Sex") })
    output$classAgePlot <- renderGirafe({ SurvivalRatePlot(allPassengers, "Class", "Age") })

    activateItems(c("filteredDownload"))

    # Show the other tabs and move the user to the first of them
    showNavTabs(rootID = "root",
                tabIDs = c("Passengers", "Survival", "Compare Groups"))

    ## Save globals
    global$datasets$allPassengers <- allPassengers
    global$datasets$filteredPassengers <- allPassengers

    endSection("Load Data")
  })


  ## 5.0 Filter Passengers ----
  observeEvent(input$applyFilters, {
    startSection("Filter Passengers")

    ## Load globals
    allPassengers <- global$datasets$allPassengers

    ## Do things
    filteredPassengers <- FilterData(allPassengers, input$classFilter,
                                     input$sexFilter, input$ageFilter)

    ## App interactions
    output$passengerTable <- renderDT({
      datatable(filteredPassengers, rownames = FALSE, filter = "top")
    })
    output$filterText <- renderText({
      paste0("Showing ", nrow(filteredPassengers), " of ", nrow(allPassengers), " people.")
    })

    ## Save globals
    global$datasets$filteredPassengers <- filteredPassengers

    endSection("Filter Passengers")
  })

  output$filteredDownload <- downloadHandler(
    filename = function() {
      "Titanic_Passengers.csv"
    },
    content = function(file) {
      write.csv(global$datasets$filteredPassengers, file, row.names = FALSE)
    }
  )


  ## 6.0 Survival Plot ----
  # ALWAYS try to tie this to a button
  # If you don't the app will run this *every single time* the input changes
  observeEvent(input$makePlot, {
    startSection("Survival Plot")

    ## Load globals
    allPassengers <- global$datasets$allPassengers

    ## Inputs
    groupBy <- input$groupBy

    ## Do things
    survivalPlot <- SurvivalBarPlot(allPassengers, groupBy, input$survivedColor,
                                    input$diedColor, input$plotTitle)
    survivalTable <- SurvivalSummary(allPassengers, groupBy)

    ## App interactions
    output$survivalPlot <- renderPlot({ survivalPlot })
    output$survivalTable <- renderDT({ datatable(survivalTable, rownames = FALSE) })
    output$survivalPlotly <- renderPlotly({ ggplotly(survivalPlot) })

    activateItems(c("plotDownload"))

    # The table and interactive plot only make sense once there is a plot
    showNavTabs(rootID = "Survival",
                tabIDs = c("Survival Plot", "Survival Table", "Interactive Plot"))

    ## Save globals
    global$survivalPlot <- survivalPlot

    endSection("Survival Plot")
  })

  output$plotDownload <- downloadHandler(
    filename = function() {
      "Survival_Plot.png"
    },
    content = function(file) {
      ggplot2::ggsave(file, global$survivalPlot, width = 7, height = 5, dpi = 150)
    }
  )


  ## 7.0 Custom Comparison ----
  observeEvent(input$runCompare, {
    startSection("Custom Comparison")

    ## Load globals
    allPassengers <- global$datasets$allPassengers

    ## Inputs
    compareOne <- input$compareOne
    compareTwo <- input$compareTwo
    survivedColor <- input$survivedColor
    diedColor <- input$diedColor

    if (compareOne == compareTwo) {
      output$compareText <- renderText({ "Please pick two different groupings." })
      endSection("Custom Comparison")
      return()
    }
    output$compareText <- renderText({ "" })

    ## App interactions
    output$compareOnePlot <- renderPlot({
      SurvivalBarPlot(allPassengers, compareOne, survivedColor, diedColor)
    })
    output$compareTwoPlot <- renderPlot({
      SurvivalBarPlot(allPassengers, compareTwo, survivedColor, diedColor)
    })
    output$compareTable <- renderDT({
      datatable(SurvivalSummary(allPassengers, c(compareOne, compareTwo)), rownames = FALSE)
    })

    endSection("Custom Comparison")
  })

}


# ___________________ ----
# Run App ----
shinyApp(ui = ui, server = server)
