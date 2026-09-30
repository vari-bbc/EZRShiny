pageHTML <- function(page) {
  as.character(htmltools::renderTags(page)$html)
}

test_that("UINav shows the appName argument", {
  html <- pageHTML(UINav(appName = "My Test App", singleTab("Home", "Hello")))
  expect_match(html, "My Test App")
  expect_match(html, "Home")
  expect_match(html, 'id="root"')
})

test_that("UINav falls back to a global appName", {
  assign("appName", "Global App Name", envir = globalenv())
  on.exit(rm("appName", envir = globalenv()))

  expect_match(pageHTML(UINav(singleTab("Home", "Hello"))), "Global App Name")
  expect_match(pageHTML(UINav(appName = "Argument Wins", singleTab("Home", "Hello"))),
               "Argument Wins")
})

test_that("UINav works with no appName anywhere", {
  skip_if(exists("appName", envir = globalenv(), inherits = FALSE))
  expect_no_error(UINav(singleTab("Home", "Hello")))
})

test_that("UINav only shows logos that are given", {
  expect_no_match(pageHTML(UINav(appName = "A")), "<img")
  expect_no_match(pageHTML(UINav(appName = "A", logoFile = "")), "<img")

  html <- pageHTML(UINav(appName = "A", logoFile = c("one.png", "two.svg"),
                         logoHeight = c("30px", "40px")))
  expect_match(html, 'src="one.png" height="30px"')
  expect_match(html, 'src="two.svg" height="40px"')
})

test_that("UINav colors the navigation bar", {
  expect_match(pageHTML(UINav(appName = "A", barColor = "#005596")), "#005596")
})

test_that("tab functions build with the default and a custom card height", {
  expect_match(as.character(singleTab("A", "x")), "85vh")

  withr::local_options(EZRShiny.cardHeight = "50vh")
  expect_match(as.character(singleTab("A", "x")), "50vh")
  expect_match(as.character(singleTab("A", "x", height = "20vh")), "20vh")
})

test_that("tab IDs and values have spaces removed", {
  bi <- as.character(biLevelTab("Explore Data", subTab("Sub Tab One", "x")))
  expect_match(bi, 'data-tabsetid|id="ExploreData"')
  expect_match(bi, 'data-value="SubTabOne"')

  side <- as.character(biLevelTab("A", subSidebarTab("Side Tab", list(navText("t", "T")), "x")))
  expect_match(side, 'data-value="SideTab"')
})

test_that("nested tabs build", {
  expect_no_error(
    UINav(appName = "A",
      triLevelTab("Menu",
        triSubTab("Level Two", subTab("Level Three", "x")),
        triSubSidebarTab("With Sidebar", list(navButton("b", "B")),
                         subTab("Inside", "y"))
      ),
      sidebarLevelTab("Side", list(navButton("c", "C")), "z"),
      singleTab("Cols", subTwoColPage("left", "right"))
    )
  )
})
