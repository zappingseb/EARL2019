expect <- function(ok, failure_message, info = NULL, srcref = NULL) {
  type <- if (ok) "success" else "failure"

  # Preserve existing API which appear to be used in package test code
  # Can remove in next major release
  if (missing(failure_message)) {
    warn("`failure_message` is missing, with no default.")
    message <- "unknown failure"
  } else {
    # A few packages include code in info that errors on evaluation
    message <- paste(c(failure_message, info), collapse = "\n")
  }

  exp <- expectation(type, message, srcref = srcref)

  withRestarts(
      if (ok) signalCondition(exp) else stop(exp),
      continue_test = function(e) NULL
  )

  invisible(exp)
}
assignInNamespace("expect", expect, ns="testthat", pos="package:testthat")

Sys.setenv("PATH" = paste0("C:/Program Files/ImageMagick-6.9.10-47-portable-Q16-x64",";",Sys.getenv("PATH")))


image_diff <- function(rec, exp) {
  image_compared <- magick::image_compare(
    image=magick::image_read(rec),
    reference_image = magick::image_read(exp),
    metric = "RMSE")

  attributes(image_compared)$distortion
}

getElement_table_as_data_frame = function(object = get("remDr", parent.frame())){

  type_of_search = "css selector"
  value = "table"

  # Check if it was searched for an actual html table
  element <- object$findElements(type_of_search, value)[[1]]

  the_table <- element$getElementAttribute("innerHTML")

  # Parse the Table by XML
  the_table <- htmlTreeParse(the_table[[1]],asText=T,encoding = "UTF-8")
  the_table <- the_table$children$html$children$body

  # Get the table headers
  headers <- the_table$children[["thead"]]
  column_names <- lapply(headers$children[[1]]$children, function(x) xmlValue(x))

  # Get the table content
  content <- c()
  # For each row
  for(i in 1:length(the_table[["tbody"]]$children))
  {
    table_row <- the_table[["tbody"]]$children[[i]]
    row_content<-c()
    # for each column
    for(j in 1:length(table_row$children)){

      v <- xmlValue(table_row[[j]])

      if(is.null(v)) v2 <- as.character("")
      else if(length(v) == 0) v2 <- as.character("")
      else if(is.na(v)) v2 <- as.character("")
      else v2 <- as.character(v)

      row_content <- c(row_content, v2)
    }

    content <- rbind(content, row_content)
  }
  # Write out the table as a data.frame and delete row.names
  colnames(content) <- as.character(column_names)
  rownames(content) <- NULL

  return(as.data.frame(content,stringsAsFactors=F,check.names  = F))

}
start_selenium <- function(url = NULL,
  driver_location = "C:\\Programme_2\\RSelenium\\selenium-server-standalone-3.141.59.jar",
                           java_home = "C:/Program Files/Java/jdk1.8.0_201",
                           driver_folder = "C:\\Programme_2\\RSelenium",
                           browserName = "chrome",
                           implicit_timeout=5000,
                           page_load_time_out=5000
                           ) {
  # Check if a url was provided
  if (is.null(url)) {
    stop("RSeleniumTest needs a an url to be intialized")
  }
  # Check if JAVA_HOME has to be changed
  if (!is.null(java_home)) {
    Sys.setenv(JAVA_HOME = java_home)
  }

  if (is.null(driver_folder)) {
    Sys.setenv(PATH = paste("C:\\Programme_2\\ROCHE-R\\Selenium\\",
      Sys.getenv("PATH"),
      sep = ";"
    ))
  } else {
    Sys.setenv(PATH = paste(driver_folder,
      Sys.getenv("PATH"),
      sep = ";"
    ))
  }

  if (browserName == "internet explorer") {
    extraCapabilities <- list(
      ie.forceCreateProcessApi = FALSE,
      InternetExplorerDriver.INTRODUCE_FLAKINESS_BY_IGNORING_SECURITY_DOMAIN = TRUE,
      InternetExplorerDriver.IGNORE_ZOOM_SETTING = TRUE,
      requireWindowFocus = TRUE,
      enablePersistentHover = FALSE
    )
  } else {
    extraCapabilities <- list()
  }
  # set the output to be negative by default
  SUCCESS <- FALSE

  # Try to initiate a Driver Session with InternetExplorer. If this Session failes it is
  # due to the reason no Selenium Server was initiated. So in case of an error a Selenium
  # Server is started
  result <- tryCatch({

    # Set the remoteDriver globally
    remDr <<- remoteDriver(
      browserName = browserName,
      extraCapabilities = extraCapabilities
    )
    remDr$open()

    remDr$navigate(url)
    Sys.sleep(implicit_timeout / 1000)
    # Navigate to the provided url
    remDr$maxWindowSize()
    remDr$setWindowSize(1936, 1056)
    remDr$setWindowPosition(0, 0)
    remDr$sessionInfo$in_shiny <<- F
    remDr$switchToFrame(NULL)
    SUCCESS <- TRUE
  }, error = function(e) {

    # Start a selenium Server from command line
    sys_log <- paste("\"",
      Sys.getenv("JAVA_HOME"),
      "\\bin\\java.exe\" -jar ",
      "\"", driver_location, "\"",
      sep = ""
    )

    message(paste("starting selenium server from", sys_log))

    system(sys_log, wait = FALSE)
    Sys.sleep(5)
    print("started")
  })
  if (!SUCCESS) {
    # Set the remoteDriver globally
    remDr <<- remoteDriver(
      browserName = browserName,
      extraCapabilities = extraCapabilities
    )
    remDr$open()
    remDr$navigate(url)
    Sys.sleep(implicit_timeout/1000)
    # remDr$setTimeout(type = "page load", milliseconds = as.numeric(page_load_time_out))
    remDr$maxWindowSize()
    remDr$setWindowSize(1936, 1056)
    remDr$setWindowPosition(0, 0)
    # Navigate to the provided url
    remDr$sessionInfo$in_shiny <<- FALSE
    remDr$switchToFrame(NULL)
    # Sys.sleep(10)
    SUCCESS <- TRUE
  }
  return(SUCCESS)
}

end_selenium <- function(remDr = get("remDr", parent.frame())) {
  remDr$close()
}

start_app <- function(port = 1235, path = getwd()){
  p <- withr::with_envvar(
    c("R_TESTS" = NA),

    callr::r_bg(function(path, port){
      do.call(shiny::runApp, list(appDir = path, port = port))
      }, supervise = TRUE, args = list(path = path, port = port))
  )
  Sys.sleep(2)
  p$get_status()
  return(p)
}
end_app <- function(p) {
  p$kill()
}

drag_drop <- function(id_drag, id_target, remDr = get("remDr", parent.frame())){
  remDr$executeScript(paste0(
    'simulateDragDrop(document.getElementById("',
    id_drag,
    '"), document.getElementById("',
    id_target,
    '"))'
  ))
}


