# Columns the app needs, with the values allowed in each
titanicColumns <- list(
  Class = c("1st", "2nd", "3rd", "Crew"),
  Sex = c("Male", "Female"),
  Age = c("Child", "Adult"),
  Survived = c("No", "Yes")
)

# Reads the CSV and checks it has the columns and values the app needs.
# Returns list(TheData = <data frame or NULL>, error = <message or "">)
ReadFile <- function(filePath){
  TheData <- tryCatch(
    utils::read.csv(filePath, stringsAsFactors = FALSE),
    error = function(e) NULL
  )

  if (is.null(TheData)){
    return(list(TheData = NULL, error = "The file could not be read. Please upload a CSV file."))
  }

  missingColumns <- setdiff(names(titanicColumns), colnames(TheData))
  if (length(missingColumns) > 0){
    return(list(TheData = NULL,
                error = paste0("The file is missing these columns: ",
                               paste(missingColumns, collapse = ", "),
                               ". Download the Titanic data to see the layout.")))
  }

  for (column in names(titanicColumns)){
    badValues <- setdiff(unique(TheData[[column]]), titanicColumns[[column]])
    if (length(badValues) > 0){
      return(list(TheData = NULL,
                  error = paste0("The ", column, " column can only hold: ",
                                 paste(titanicColumns[[column]], collapse = ", "), ".")))
    }
    # Keep the values in a sensible order for tables and plots
    TheData[[column]] <- factor(TheData[[column]], levels = titanicColumns[[column]])
  }

  list(TheData = TheData, error = "")
}
