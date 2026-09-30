test_that("sourceFunctions loads every R file in a folder", {
  folder <- withr::local_tempdir()
  writeLines("addOne <- function(x) x + 1", file.path(folder, "a.R"))
  writeLines("addTwo <- function(x) x + 2", file.path(folder, "b.R"))
  writeLines("notLoaded <- TRUE", file.path(folder, "c.txt"))

  loadInto <- new.env()
  sourced <- sourceFunctions(folder, envir = loadInto)

  expect_length(sourced, 2)
  expect_equal(loadInto$addOne(1), 2)
  expect_equal(loadInto$addTwo(1), 3)
  expect_false(exists("notLoaded", envir = loadInto))
})

test_that("sourceFunctions finds a folder relative to the working directory", {
  folder <- withr::local_tempdir()
  dir.create(file.path(folder, "Functions"))
  writeLines("addThree <- function(x) x + 3", file.path(folder, "Functions", "a.R"))
  withr::local_dir(folder)

  loadInto <- new.env()
  sourceFunctions("Functions", envir = loadInto)
  expect_equal(loadInto$addThree(1), 4)
})

test_that("createEZApp makes a working app folder", {
  appFolder <- file.path(withr::local_tempdir(), "newApp")
  expect_message(appFile <- createEZApp(appFolder, appName = 'The "Best" App'))

  expect_true(file.exists(appFile))
  expect_true(all(dir.exists(file.path(appFolder, c("Functions", "www", "Necessary_Files")))))

  appCode <- readLines(appFile)
  expect_true(any(grepl('appName <- "The \\"Best\\" App"', appCode, fixed = TRUE)))
  expect_no_error(parse(appFile))
})

test_that("createEZApp won't overwrite an app unless asked", {
  appFolder <- withr::local_tempdir()
  suppressMessages(createEZApp(appFolder))
  expect_error(createEZApp(appFolder), "already an app.R")
  expect_no_error(suppressMessages(createEZApp(appFolder, overwrite = TRUE)))
})

test_that("the template app's server runs", {
  appFolder <- file.path(withr::local_tempdir(), "templateApp")
  suppressMessages(createEZApp(appFolder))

  suppressMessages(shiny::testServer(appFolder, {
    dataFile <- tempfile(fileext = ".csv")
    write.csv(data.frame(x = 1:3, y = 4:6), dataFile, row.names = FALSE)

    session$setInputs(dataUpload = data.frame(name = "data.csv", datapath = dataFile))
    session$setInputs(doThings1 = 1)

    expect_equal(nrow(global$datasets$rawData), 3)
    expect_match(output$notesText, "Read 3 rows")
  }))
})
