exampleDir <- function() {
  system.file("examples", "titanicExplorer", package = "EZRShiny")
}

test_that("the example app's UI builds", {
  skip_if_not_installed("ggplot2")
  expect_s3_class(shiny::shinyAppDir(exampleDir()), "shiny.appobj")
})

test_that("the example app runs from loading data to comparisons", {
  skip_if_not_installed("ggplot2")

  suppressMessages(shiny::testServer(exampleDir(), {
    # Load the built-in data
    session$setInputs(useBuiltIn = TRUE)
    session$setInputs(loadData = 1)

    allPassengers <- global$datasets$allPassengers
    expect_equal(nrow(allPassengers), sum(datasets::Titanic))
    expect_match(output$loadText, "Loaded 2201 people")

    # Filter to first class children
    session$setInputs(classFilter = "1st", sexFilter = c("Male", "Female"),
                      ageFilter = "Child", applyFilters = 1)
    expect_equal(nrow(global$datasets$filteredPassengers),
                 sum(datasets::Titanic["1st", , "Child", ]))
    expect_match(output$filterText, "Showing 6 of 2201")

    # Survival plot
    session$setInputs(groupBy = "Sex", survivedColor = "#2E86AB", diedColor = "#C0392B",
                      plotTitle = "", makePlot = 1)
    expect_s3_class(global$survivalPlot, "ggplot")

    # Every plot actually draws (reading an output renders it)
    expect_no_error(output$survivalPlot)
    expect_no_error(output$survivalPlotly)
    expect_no_error(output$classSexPlot)
    expect_no_error(output$classAgePlot)

    # Picking the same grouping twice gives a message
    session$setInputs(compareOne = "Sex", compareTwo = "Sex", runCompare = 1)
    expect_match(output$compareText, "two different groupings")

    # Two different groupings draw both plots and the table
    session$setInputs(compareTwo = "Age", runCompare = 2)
    expect_equal(output$compareText, "")
    expect_no_error(output$compareOnePlot)
    expect_no_error(output$compareTwoPlot)
    expect_no_error(output$compareTable)
  }))
})

test_that("the example app's survival summary matches the Titanic table", {
  helpers <- new.env()
  sourceFunctions(file.path(exampleDir(), "Functions"), envir = helpers)
  passengers <- helpers$ReadFile(file.path(exampleDir(), "Necessary_Files", "titanic.csv"))$TheData

  bySex <- helpers$SurvivalSummary(passengers, "Sex")
  expect_equal(bySex$People, as.integer(margin.table(datasets::Titanic, 2)))
  expect_equal(bySex$Survived, as.integer(margin.table(datasets::Titanic, c(2, 4))[, "Yes"]))
})

test_that("the example app rejects data in the wrong layout", {
  skip_if_not_installed("ggplot2")

  suppressMessages(shiny::testServer(exampleDir(), {
    badFile <- tempfile(fileext = ".csv")
    write.csv(data.frame(a = 1:3, b = 4:6), badFile, row.names = FALSE)

    session$setInputs(useBuiltIn = FALSE,
                      dataUpload = data.frame(name = "bad.csv", datapath = badFile))
    session$setInputs(loadData = 1)

    expect_match(output$loadText, "missing these columns")
    expect_null(global$datasets$allPassengers)
  }))
})
