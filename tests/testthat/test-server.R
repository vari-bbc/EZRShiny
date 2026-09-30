test_that("activate and deactivate work with one, several or no IDs", {
  shiny::testServer(function(input, output, session) {
    expect_no_error(deactivateItems(c("a", "b")))
    expect_no_error(activateItems("a"))
    expect_no_error(deactivateItems(character(0)))
  }, {})
})

test_that("showNavTabs and hideNavTabs work with any number of tabs", {
  shiny::testServer(function(input, output, session) {
    expect_no_error(hideNavTabs("Some Tabs", c("Tab One", "Tab Two")))
    expect_no_error(showNavTabs("Some Tabs", c("Tab One", "Tab Two")))
    expect_no_error(showNavTabs("Some Tabs", "Tab One"))
    expect_no_error(showNavTabs("Some Tabs", character(0)))
  }, {})
})

test_that("startSection and endSection write messages", {
  expect_message(startSection("Loading"), "----Loading Start")
  expect_message(endSection("Loading"), "----Loading Done")
})
