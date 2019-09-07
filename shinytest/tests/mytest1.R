app <- ShinyDriver$new("../")
app$snapshotInit("mytest1")

app$uploadFile(data_file = "test123.csv")
app$setInputs(data_columns = c("TEST1", "TEST2", "TEST3"))
app$setInputs(data_columns = c("TEST1", "TEST2", "TEST3", "TEST4"))
app$setInputs(data_columns = c("TEST1", "TEST3", "TEST4"))
app$snapshot()
snapshotCompare("..", testnames = "mytest1", autoremove = FALSE)
