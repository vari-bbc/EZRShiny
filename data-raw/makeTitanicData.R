# Makes the passenger-level Titanic data used by the example app:
#   inst/examples/titanicExplorer/Necessary_Files/titanic.csv
# R's built-in Titanic data is a table of counts. This turns it into one row
# per person. Run from the package folder with: source("data-raw/makeTitanicData.R")

counts <- as.data.frame(datasets::Titanic, stringsAsFactors = FALSE)
passengers <- counts[rep(seq_len(nrow(counts)), counts$Freq), c("Class", "Sex", "Age", "Survived")]
passengers <- cbind(PassengerID = seq_len(nrow(passengers)), passengers)

utils::write.csv(passengers,
                 "inst/examples/titanicExplorer/Necessary_Files/titanic.csv",
                 row.names = FALSE)
