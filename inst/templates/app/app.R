# ___________________ ----
# App Startup ----

## 1.0 Load Libraries ----
library(shiny)
library(bslib)
library(shinyjs)
library(EZRShiny)
# Add the packages your analysis needs here, for example:
# library(DT)
# library(plotly)


## 2.0 Load Basics ----
# Allow uploads of up to 300 MB (the default is 5 MB)
options(shiny.maxRequestSize = 300 * 1024^2)

# Loads every .R file in the Functions folder
sourceFunctions("Functions")


## 3.0 Universal Vars ----
# App Name here:
appName <- "{{appName}}"
# Necessary Files here:
# template <- read.csv("Necessary_Files/Template.csv")


# ___________________ ----
# UI ----
# Ensure use of document outline and preloading as many inputs as possible
# Tool tips are last in nav item and should be specified with tooltipText = "..."
ui <- UINav(

  # Logo files must be placed in the www folder and must include ".{type}"
  # logoFile = c("myLogo.png"),
  appName = appName,
  # barColor = "#005596",

  ## 1.0 Section 1 ----
  singleTab("Upload your Data",
    navUpload("dataUpload", "Upload your data",
              tooltipText = "Please upload a CSV file."),
    navButton("doThings1", "Run", tooltipText = "Upload data first."),
    navOutputText("statusText")
  ),

  ## 2.0 Section 2 ----
  biLevelTab("Results",
    subSidebarTab("Table",
      sidebarElements = list(
        navDownload("downloadFile", "Download table")
      ),
      navOutputTable("resultsTable")
    ),
    subTab("Notes",
      navOutputText("notesText")
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
      rawData = NULL
    )
  )


  ## 2.0 Run on Start ----
  # Hide pages and deactivate buttons that should not be used yet
  observe({
    startSection("Run on Start")

    # Hide sub Tabs for tabs we don't want shown at start
    hideNavTabs(rootID = "Results",
                tabIDs = c("Table",
                           "Notes"))

    # Deactivate buttons that need other things to function
    deactivateItems(c("doThings1"))

    # Deactivate all downloads since there is nothing to download at start
    deactivateItems(c(
      "downloadFile"
    ))

    endSection("Run on Start")
  })


  ## 3.0 File Imports ----
  observeEvent(input$dataUpload, {
    isCsv <- grepl("\\.csv$", input$dataUpload$name, ignore.case = TRUE)

    if (isCsv) {
      activateItems(c("doThings1"))
      output$statusText <- renderText({ "" })
    } else {
      deactivateItems(c("doThings1"))
      output$statusText <- renderText({ "Please upload a CSV file." })
    }
  })


  ## 4.0 Do App Things ----
  # ALWAYS try to tie this to a button
  # If you don't the app will run this *every single time* the input changes
  observeEvent(input$doThings1, {
    startSection("Do the Thing")

    ## Inputs
    rawData <- read.csv(input$dataUpload$datapath)

    ## Do things
    # Replace this with your analysis
    theFile <- rawData

    ## App interactions
    # activate downloads/buttons, set up downloads, deactivate downloads/buttons,
    # update inputs/outputs
    output$resultsTable <- DT::renderDT({ theFile })
    output$notesText <- renderText({
      paste0("Read ", nrow(rawData), " rows and ", ncol(rawData), " columns.")
    })

    activateItems(c("downloadFile"))

    output$downloadFile <- downloadHandler(
      filename = function() {
        paste("TheFile.csv")
      },
      content = function(file) {
        write.csv(theFile, file, row.names = FALSE)
      }
    )

    showNavTabs(rootID = "Results", tabIDs = c("Table", "Notes"))
    nav_select("root", "Results")

    ## Save globals
    global$datasets$rawData <- rawData

    endSection("Do the Thing")
  })

}


# ___________________ ----
# Run App ----
shinyApp(ui = ui, server = server)
