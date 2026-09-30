test_that("addTooltip returns the label unchanged without tooltip text", {
  expect_identical(addTooltip("Label", NA), "Label")
  expect_identical(addTooltip("Label", NULL), "Label")
  expect_identical(addTooltip("Label", ""), "Label")
})

test_that("addTooltip adds a tooltip and info icon", {
  html <- as.character(shiny::tagList(addTooltip("Label", "Helpful text")))
  expect_match(html, "Helpful text")
  expect_match(html, "info-circle|<svg")
})

test_that("navSelect uses multiple and create", {
  single <- as.character(navSelect("a", "A", c("x", "y")))
  multi <- as.character(navSelect("b", "B", c("x", "y"), multiple = TRUE, create = TRUE))

  expect_no_match(single, "multiple")
  expect_match(multi, "multiple")
  expect_match(single, '"create":false')
  expect_match(multi, '"create":true')
})

test_that("navSelect selects the first choice by default", {
  html <- as.character(navSelect("a", "A", c("x", "y")))
  expect_match(html, '<option value="x" selected>')

  html <- as.character(navSelect("a", "A", c("x", "y"), selected = "y"))
  expect_match(html, '<option value="y" selected>')
})

test_that("navUpload, navCheckbox and navDate use TRUE/FALSE arguments", {
  expect_no_match(as.character(navUpload("a", "A")), "multiple")
  expect_match(as.character(navUpload("a", "A", multiple = TRUE)), "multiple")
  expect_no_match(as.character(navCheckbox("a", "A")), "checked")
  expect_match(as.character(navCheckbox("a", "A", value = TRUE)), "checked")
  expect_match(as.character(navDate("a", "A", range = TRUE)), 'data-range="true"|range')
})

test_that("old short word arguments give a helpful error", {
  expect_error(navUpload("a", "A", "Single"), "must be TRUE or FALSE")
  expect_error(navCheckbox("a", "A", "T"), "must be TRUE or FALSE")
  expect_error(navSelect("a", "A", c("x"), multiple = "Multi"), "old")
  # The old navSelect("id", "Label", "Single", "Locked", choices) order
  expect_error(navSelect("a", "A", "Single", "Locked", c("x", "y")), "must be TRUE or FALSE")
})

test_that("navNumeric and navText set their starting values", {
  expect_match(as.character(navNumeric("a", "A", value = 5)), 'value="5"')
  expect_no_match(as.character(navNumeric("a", "A", value = 5)), "max=")
  expect_match(as.character(navNumeric("a", "A", value = 5, min = 0, max = 10)), 'max="10"')
  expect_match(as.character(navText("a", "A", value = "hello")), 'value="hello"')
})

test_that("every input builds with and without a tooltip", {
  inputs <- list(
    function(tt) navButton("a", "A", tooltipText = tt),
    function(tt) navSelect("a", "A", c("x"), tooltipText = tt),
    function(tt) navUpload("a", "A", tooltipText = tt),
    function(tt) navCheckbox("a", "A", tooltipText = tt),
    function(tt) navDownload("a", "A", tooltipText = tt),
    function(tt) navText("a", "A", tooltipText = tt),
    function(tt) navNumeric("a", "A", tooltipText = tt),
    function(tt) navColor("a", "A", tooltipText = tt),
    function(tt) navDate("a", "A", range = TRUE, tooltipText = tt)
  )
  for (makeInput in inputs) {
    expect_no_match(as.character(makeInput(NA)), "Tip text")
    expect_match(as.character(makeInput("Tip text")), "Tip text")
  }
})

test_that("outputs use the given ID and show their label and tooltip", {
  outputs <- list(navOutputTable, navOutputPlot, navOutputPlotly, navOutputGirafe,
                  navOutputPic, sideNavOutputPic, navOutputText)
  for (makeOutput in outputs) {
    plain <- as.character(makeOutput("myOutput"))
    expect_match(plain, 'id="myOutput"')
    expect_no_match(plain, "ezr-output-label")

    labelled <- as.character(makeOutput("myOutput", label = "My label",
                                        tooltipText = "Tip text"))
    expect_match(labelled, 'id="myOutput"')
    expect_match(labelled, "My label")
    expect_match(labelled, "Tip text")

    tooltipOnly <- as.character(makeOutput("myOutput", tooltipText = "Tip text"))
    expect_match(tooltipOnly, "ezr-output-label")
    expect_match(tooltipOnly, "Tip text")

    labelOnly <- as.character(makeOutput("myOutput", label = "My label"))
    expect_match(labelOnly, "My label")
    expect_no_match(labelOnly, "info-circle")
  }
})
