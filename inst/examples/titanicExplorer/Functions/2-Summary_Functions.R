# Keeps the passengers matching every filter
FilterData <- function(TheData, classes, sexes, ages){
  TheData[TheData$Class %in% classes &
          TheData$Sex %in% sexes &
          TheData$Age %in% ages, ]
}

# Number of people, survivors and survival rate for each group.
# groupBy is one or more column names, for example "Class" or c("Class", "Sex")
SurvivalSummary <- function(TheData, groupBy){
  groups <- interaction(TheData[groupBy], sep = " / ", drop = TRUE)
  people <- tapply(TheData$Survived, groups, length)
  survivors <- tapply(TheData$Survived == "Yes", groups, sum)

  theSummary <- unique(TheData[groupBy])
  theSummary <- theSummary[do.call(order, theSummary), , drop = FALSE]
  keys <- as.character(interaction(theSummary, sep = " / ", drop = TRUE))

  theSummary$People <- as.integer(people[keys])
  theSummary$Survived <- as.integer(survivors[keys])
  theSummary$SurvivalRate <- round(100 * theSummary$Survived / theSummary$People, 1)
  rownames(theSummary) <- NULL
  theSummary
}
