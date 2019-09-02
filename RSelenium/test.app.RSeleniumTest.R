setwd("C:/_wolfs25/git/EARL2019/RSelenium")
library(tcltk)
library(RTest)
Sys.setenv("JAVA_HOME" = "C:/Program Files/Java/jdk1.8.0_201")
devtools::load_all("C:/_wolfs25/git/RSeleniumTest")

source("utils.test.R")

process_app <- start_app(port = 1212, path = getwd())

execute("Sebastian Wolf", project.name = "EARL Conf - Test")

end_app(process_app)
