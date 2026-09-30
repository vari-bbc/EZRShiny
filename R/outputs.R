# ___________________ ----
# Nav Outputs ----

#' Standard outputs
#'
#' Placeholders in the UI that the server fills in. Each is paired with a
#' render function in the server, assigned to `output$<outputId>`:
#'
#' | Function             | Fill it in the server with     | Size |
#' |----------------------|--------------------------------|------|
#' | `navOutputTable()`   | [DT::renderDT()]               | full width |
#' | `navOutputPlot()`    | [shiny::renderPlot()]          | 80% wide |
#' | `navOutputPlotly()`  | [plotly::renderPlotly()]       | 80% wide, full window height |
#' | `navOutputGirafe()`  | [ggiraph::renderGirafe()]      | 80% wide, full window height |
#' | `navOutputPic()`     | [shiny::renderImage()]         | 80% of the window wide, full window height |
#' | `sideNavOutputPic()` | [shiny::renderImage()]         | 40% wide, for beside another output |
#' | `navOutputText()`    | [shiny::renderText()]          | as needed |
#'
#' Like the inputs, each output can have a `label` shown above it and a
#' `tooltipText` that adds an info icon after the label (or on its own, if
#' there's no label). Use the tooltip to explain how to read a plot or table.
#'
#' @param outputId The output's ID. Fill it in the server with
#'   `output$<outputId> <- render...()`.
#' @param label Optional heading shown above the output.
#' @param tooltipText Optional text for an info tooltip after the label.
#'
#' @return A 'shiny' output tag to place in the UI, with its label if one was
#'   given.
#' @name navOutputs
#' @examples
#' navOutputTable("resultsTable")
#' navOutputPlotly("pcaPlot", label = "PCA",
#'                 tooltipText = "Each point is one sample.")
#' navOutputText("statusMessage")
NULL

# Puts the label and tooltip (if any) above an output
withOutputLabel <- function(output, label, tooltipText){
  if (!hasText(label) && !hasText(tooltipText)){
    return(output)
  }
  shiny::tagList(
    shiny::div(class = "ezr-output-label", style = "font-weight: 500; margin-bottom: 0.25rem;",
               addTooltip(if (hasText(label)) label else "", tooltipText)),
    output
  )
}

#' @rdname navOutputs
#' @export
navOutputTable <- function(outputId, label = NULL, tooltipText = NA){
  withOutputLabel(DT::DTOutput(outputId), label, tooltipText)
}

#' @rdname navOutputs
#' @export
navOutputPlot <- function(outputId, label = NULL, tooltipText = NA){
  withOutputLabel(shiny::plotOutput(outputId, width = "80%"), label, tooltipText)
}

#' @rdname navOutputs
#' @export
navOutputPlotly <- function(outputId, label = NULL, tooltipText = NA){
  withOutputLabel(plotly::plotlyOutput(outputId, width = "80%", height = "100vh"),
                  label, tooltipText)
}

#' @rdname navOutputs
#' @export
navOutputGirafe <- function(outputId, label = NULL, tooltipText = NA){
  withOutputLabel(ggiraph::girafeOutput(outputId, width = "80%", height = "100vh"),
                  label, tooltipText)
}

#' @rdname navOutputs
#' @export
navOutputPic <- function(outputId, label = NULL, tooltipText = NA){
  withOutputLabel(shiny::imageOutput(outputId, width = "80vw", height = "100vh"),
                  label, tooltipText)
}

#' @rdname navOutputs
#' @export
sideNavOutputPic <- function(outputId, label = NULL, tooltipText = NA){
  withOutputLabel(shiny::imageOutput(outputId, width = "40%"), label, tooltipText)
}

#' @rdname navOutputs
#' @export
navOutputText <- function(outputId, label = NULL, tooltipText = NA){
  withOutputLabel(shiny::textOutput(outputId), label, tooltipText)
}
