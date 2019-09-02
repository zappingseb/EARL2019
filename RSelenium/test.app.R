library(RSelenium)
library(XML)

rm(list = ls())
source("utils.test.R")
logs <- c()


process_r <- start_app()

Sys.sleep(2)


start_selenium("http://localhost:1235", browserName = "firefox")

el_1 <- remDr$findElements("id", "help")
logs <- c(logs, "INFO: Move mouse to 'help'.")
Sys.sleep(2)
remDr$mouseMoveToLocation(webElement = el_1[[1]])

Sys.sleep(1)

helptext <- remDr$findElements("css selector", ".helptext p")[[1]]

if (helptext$getElementValueOfCssProperty("display")[[1]] != "block") {
  logs <- c(logs, "ERROR: Hover on Help does not work")
} else {
  logs <- c(logs, "INFO: help text shown")
}

if (helptext$getElementAttribute("innerHTML")[[1]] != "This is a nonsense help text.") {
  logs <- c(logs, "ERROR: Wrong helptext.")
} else {
  logs <- c(logs, "INFO: Right help text.")
}

logs <- c(logs, "INFO: Moving SEX to x_columns.")
Sys.sleep(1)
drag_drop("SEX", "x_columns")
Sys.sleep(1)
logs <- c(logs, "INFO: Moving COUNTRY to y_columns.")
drag_drop("COUNTRY", "y_columns")
Sys.sleep(3)

remDr$screenshot(display = TRUE)
compare_file <- file.path(tempdir(), "tmpScreenShot.png")

logs <- c(logs, paste0("INFO: Screenshot difference SEX vs COUNTRY: ", image_diff(compare_file, file.path(getwd(), "testfiles/SEXCOUNTRY.png")), " Percent"))

Sys.sleep(1)
drag_drop("RACE", "facet_columns")

Sys.sleep(2)
remDr$screenshot(display = TRUE)

compare_file <- file.path(tempdir(), "tmpScreenShot.png")
logs <- c(
  logs,
  paste0(
    "INFO: Screenshot difference SEX vs COUNTRY, facet RACE: ",
    image_diff(compare_file, file.path(getwd(), "testfiles/SEXCOUNTRYRACE.png")),
    " Percent"
  )
)

Sys.sleep(2)

drag_drop("SEX", "grab_from")
Sys.sleep(1)
drag_drop("AGE", "x_columns")
Sys.sleep(1)
drag_drop("VITAMIND", "x_columns")
Sys.sleep(2)
remDr$screenshot(display = FALSE)

table_out <- getElement_table_as_data_frame()

table_test <- read.csv("testfiles/AGEVITAMINDCOUNTRYRACE.csv", stringsAsFactors = F)

if (all(dim(table_test) == dim(table_out))) {
  logs <- c(logs, paste0("INFO: Tables have same dimensions"))
  logs <- c(logs, unlist(lapply(names(table_test), function(x) {
    if (identical(as.character(table_out[, x]), as.character(table_test[, x]))) {
      paste0("INFO: Column ", x, " is equal.")
    } else {
      paste0("ERROR: Column ", x, " is different")
    }
  })))
} else {
  logs <- c(logs, paste0("ERROR: Tables cannot be compared due to unequal dimensions."))
}

logs <- c(logs, "END")

end_selenium()
end_app(process_r)

cat(paste(logs, collapse = "\n"))
