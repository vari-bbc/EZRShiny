# ___________________ ----
# Nav Inputs ----

#' Add an information tooltip to a label
#'
#' Puts an info icon after the label. Hovering over the label or the icon shows
#' `tooltipText`. Every `nav*()` input and output function calls this for you
#' through its `tooltipText` argument. Call it directly only when building your
#' own inputs.
#'
#' @param label The label: a string or a 'shiny' tag.
#' @param tooltipText Text to show on hover. `NA` or `NULL` means no tooltip,
#'   and the label is returned unchanged.
#'
#' @return The label, with a tooltip if one was given.
#' @export
#' @examples
#' addTooltip("Upload data", "CSV files only")
#' addTooltip("Upload data", NA)
addTooltip <- function(label, tooltipText){
  if (!hasText(tooltipText)){
    return(label)
  } else {
    return(list(bslib::tooltip(trigger = list(label, bsicons::bs_icon("info-circle")),
                               tooltipText)))
  }
}

# TRUE if x holds text to show (not NULL, NA or "")
hasText <- function(x){
  !is.null(x) && !all(is.na(x)) && !identical(x, "")
}

# Stops with a helpful message if value isn't TRUE or FALSE
checkTrueFalse <- function(value, argName){
  if (!isTRUE(value) && !isFALSE(value)){
    stop("`", argName, "` must be TRUE or FALSE, not ", deparse(value)[1], ". ",
         "(The old \"Single\"/\"Multi\", \"Create\"/\"Locked\" and \"T\"/\"F\" ",
         "arguments are now TRUE/FALSE arguments. See ?navInputs.)", call. = FALSE)
  }
}

#' Standard inputs
#'
#' Full-width inputs for sidebars and tabs. Each is a thin wrapper around a
#' 'shiny', 'bslib', 'shinyWidgets' or 'colourpicker' input, uses the same
#' argument names, and takes an optional `tooltipText` that adds an info icon
#' to the label (see [addTooltip()]).
#'
#' | Function        | Builds                                   | Read in the server as |
#' |-----------------|------------------------------------------|-----------------------|
#' | `navButton()`   | [bslib::input_task_button()]             | `input$id` (click count) |
#' | `navSelect()`   | [shiny::selectizeInput()]                | `input$id` (chosen values) |
#' | `navUpload()`   | [shiny::fileInput()]                     | `input$id$datapath`, `input$id$name` |
#' | `navDownload()` | [shiny::downloadButton()]                | pair with `output$id <- downloadHandler(...)` |
#' | `navCheckbox()` | [bslib::input_switch()]                  | `input$id` (`TRUE`/`FALSE`) |
#' | `navText()`     | [shiny::textInput()]                     | `input$id` |
#' | `navNumeric()`  | [shiny::numericInput()]                  | `input$id` |
#' | `navColor()`    | [colourpicker::colourInput()]            | `input$id` (hex color) |
#' | `navDate()`     | [shinyWidgets::airDatepickerInput()]     | `input$id` (one or two dates) |
#'
#' @param inputId The input's ID. Read it in the server as `input$<inputId>`.
#' @param label Label shown above or beside the input.
#' @param tooltipText Optional text for an info tooltip on the label.
#' @param choices Choices to offer. Can be left `NULL` and filled in later
#'   from the server with [shiny::updateSelectizeInput()].
#' @param selected Choices selected at start. Defaults to the first choice.
#' @param multiple `TRUE` to allow more than one choice (`navSelect()`) or
#'   file (`navUpload()`).
#' @param create `TRUE` to let the user type in options that aren't in
#'   `choices`.
#' @param value Starting value: text for `navText()`, a number for
#'   `navNumeric()`, `TRUE`/`FALSE` for whether `navCheckbox()` starts on, and a
#'   color name or hex code for `navColor()`.
#' @param min,max Smallest and largest allowed values. `NA` for no limit.
#' @param range `TRUE` to pick a start and end date, `FALSE` for one date.
#'
#' @return A 'shiny' tag (or tag list) to place in the UI.
#' @name navInputs
#' @examples
#' navButton("runData", "Run analysis", tooltipText = "Upload data first")
#' navSelect("groups", "Pick groups", choices = c("Control", "Treated"),
#'           multiple = TRUE)
#' navUpload("dataUpload", "Upload a CSV")
#' navDownload("resultsDownload", "Download results")
#' navCheckbox("logScale", "Use a log scale")
#' navText("plotTitle", "Plot title")
#' navNumeric("alpha", "Significance cutoff", value = 0.05, min = 0, max = 1)
#' navColor("pointColor", "Point color", value = "#D55E00")
#' navDate("dates", "Date range", range = TRUE)
NULL

#' @rdname navInputs
#' @export
navButton <- function(inputId, label, tooltipText = NA){
  bslib::input_task_button(inputId, addTooltip(label, tooltipText),
                           width = "100%", type = "default")
}

#' @rdname navInputs
#' @export
navSelect <- function(inputId, label, choices = NULL, selected = choices[1],
                      multiple = FALSE, create = FALSE, tooltipText = NA){
  checkTrueFalse(multiple, "multiple")
  checkTrueFalse(create, "create")

  shiny::selectizeInput(inputId, addTooltip(label, tooltipText), choices = choices,
                        selected = selected, multiple = multiple, width = "100%",
                        options = list(create = create))
}

#' @rdname navInputs
#' @export
navUpload <- function(inputId, label, multiple = FALSE, tooltipText = NA){
  checkTrueFalse(multiple, "multiple")

  shiny::fileInput(inputId, addTooltip(label, tooltipText), multiple = multiple,
                   width = "100%")
}

#' @rdname navInputs
#' @export
navCheckbox <- function(inputId, label, value = FALSE, tooltipText = NA){
  checkTrueFalse(value, "value")

  bslib::input_switch(inputId, addTooltip(label, tooltipText), value = value,
                      width = "100%")
}

#' @rdname navInputs
#' @export
navDownload <- function(inputId, label, tooltipText = NA){
  shiny::downloadButton(inputId, addTooltip(label, tooltipText), width = "100%")
}

#' @rdname navInputs
#' @export
navText <- function(inputId, label, value = "", tooltipText = NA){
  shiny::textInput(inputId, addTooltip(label, tooltipText), value = value,
                   width = "100%")
}

#' @rdname navInputs
#' @export
navNumeric <- function(inputId, label, value = 1, min = NA, max = NA, tooltipText = NA){
  shiny::numericInput(inputId, addTooltip(label, tooltipText), value = value,
                      min = min, max = max, width = "100%")
}

#' @rdname navInputs
#' @export
navColor <- function(inputId, label, value = "white", tooltipText = NA){
  colourpicker::colourInput(inputId, addTooltip(label, tooltipText), value = value,
                            width = "100%")
}

#' @rdname navInputs
#' @export
navDate <- function(inputId, label, range = FALSE, tooltipText = NA){
  checkTrueFalse(range, "range")

  shinyWidgets::airDatepickerInput(inputId, addTooltip(label, tooltipText), range = range,
                                   clearButton = TRUE, separator = " to ", addon = "none")
}

#' Text with an information tooltip
#'
#' Plain text followed by an info icon. Hovering over the icon shows
#' `tooltipText` below it. Useful for explaining a section of a page.
#'
#' @param text Text to show.
#' @param tooltipText Text to show when hovering over the icon.
#'
#' @return A 'shiny' `span` tag.
#' @export
#' @examples
#' navSpanText("Quality control", "Samples with over 20% missing values are removed.")
navSpanText <- function(text, tooltipText = NA){
  shiny::span(text,
              bslib::tooltip(bsicons::bs_icon("info-circle"), tooltipText, placement = "bottom"))
}
