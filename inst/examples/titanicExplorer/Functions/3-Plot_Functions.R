# Stacked bar chart of how many people in each group survived
SurvivalBarPlot <- function(TheData, groupBy, survivedColor, diedColor, plotTitle = ""){
  if (plotTitle == "") plotTitle <- paste("Survival by", groupBy)

  ggplot2::ggplot(TheData, ggplot2::aes(x = .data[[groupBy]], fill = Survived)) +
    ggplot2::geom_bar() +
    ggplot2::scale_fill_manual(values = c(No = diedColor, Yes = survivedColor)) +
    ggplot2::labs(title = plotTitle, x = groupBy, y = "People") +
    ggplot2::theme_bw()
}

# Survival rate of each pair of groups; hover over a bar to see the numbers
SurvivalRatePlot <- function(TheData, groupOne, groupTwo){
  theSummary <- SurvivalSummary(TheData, c(groupOne, groupTwo))
  theSummary$tooltip <- paste0(theSummary[[groupOne]], ", ", theSummary[[groupTwo]], ": ",
                               theSummary$Survived, " of ", theSummary$People,
                               " survived (", theSummary$SurvivalRate, "%)")

  thePlot <- ggplot2::ggplot(theSummary,
                             ggplot2::aes(x = .data[[groupOne]], y = SurvivalRate,
                                          fill = .data[[groupTwo]])) +
    ggiraph::geom_col_interactive(ggplot2::aes(tooltip = tooltip, data_id = tooltip),
                                  position = "dodge") +
    ggplot2::labs(x = groupOne, y = "Survival rate (%)", fill = groupTwo) +
    ggplot2::ylim(0, 100) +
    ggplot2::theme_bw()

  ggiraph::girafe(ggobj = thePlot, width_svg = 7, height_svg = 4)
}
