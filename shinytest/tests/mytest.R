library(shinytest)
library(testthat)
library(XML)
library(jsonlite)

source("utils.test.R")
app <- ShinyDriver$new("../")
app$snapshotInit("mytest")

app$uploadFile(data_file = "test123.csv")
app$setInputs(data_columns = c("TEST1", "TEST2", "TEST3"))

test_that("Test App",
          {
            
            expect_equal(
              app$getTitle(),
              "Quality Control app"
            )
            
            app_snap <- jsonlite::fromJSON(app$snapshot())
            
            f_test_results <- get_strings_from_p_html(app_snap$output$FTestString$html)
            mean_test_results <- get_strings_from_p_html(app_snap$output$MeanTest$html)
            
            expect_equal(
              f_test_results[[1]],
              "X, Y =  TEST1 , TEST2 \n F-Test ok"
            )
            
            expect_equal(
              f_test_results[[2]],
              "X, Y =  TEST1 , TEST3 \n F-Test failed"
            )
            
            expect_equal(
              mean_test_results[[1]],
              "X, Y =  TEST1 , TEST2 \n Mean Test ok"
            )
            
            expect_equal(
              mean_test_results[[2]],
              "X, Y =  TEST1 , TEST3 \n Mean Test failed"
            )
            
            summary_table <- get_table_from_html(app_snap$output$summary)
            
            expect_equal(
              names(summary_table),
              c("samples", "Mean", "SD", "Median", "Q25", "Q75")
            )
            
            expect_equal(
              summary_table$Mean,
              c("5.49", "5.43", "7.13")
            )
            
            app$setInputs(data_columns = c("TEST1", "TEST2", "TEST3", "TEST4"))
            app_snap <- jsonlite::fromJSON(app$snapshot())
            
            summary_table <- get_table_from_html(app_snap$output$summary)
            
            expect_equal(
              summary_table$Mean,
              c("5.48", "5.43", "7.13", "6.52")
            )
            
            expect_equal(
              unname(get_code_from_div_p_html(app_snap$output$finalresult$html)[[1]]),
              "check.png")
            
            expect_equal(
              unname(get_code_from_div_p_html(app_snap$output$finalresult$html)[[2]]),
              "cross.png")
            
            
            app$setInputs(data_columns = c("TEST1", "TEST3", "TEST4"))
            app_snap <- jsonlite::fromJSON(app$snapshot())
            
            summary_table <- get_table_from_html(app_snap$output$summary)
            
            expect_equal(
              summary_table$Mean,
              c("5.49", "7.13", "6.52")
            )
            expect_equal(
               unname(get_code_from_div_p_html(app_snap$output$finalresult$html)[[1]]),
               "cross.png")
            expect_equal(
               unname(get_code_from_div_p_html(app_snap$output$finalresult$html)[[2]]),
               "check.png")
            
            
          })
app$stop()