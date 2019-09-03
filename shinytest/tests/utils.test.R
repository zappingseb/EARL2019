get_strings_from_p_html <- function(app_elem){
  
  HTML_in <- XML::htmlTreeParse(app_elem, asText=T, encoding = "UTF-8")
  XML::xmlApply(
    HTML_in$children$html$children$body,
    function(x) XML::xmlValue(x[[1]]))
}

get_code_from_div_p_html <- function(app_elem) {
  HTML_in <- XML::htmlTreeParse(app_elem, asText=T, encoding = "UTF-8")
  XML::xmlApply(
    HTML_in$children$html$children$body[["div"]],
    function(x) XML::xmlAttrs(x[[1]])["src"])
}

get_table_from_html <- function(html_input) {
  HTML_in <- XML::htmlTreeParse(html_input, asText=T, encoding = "UTF-8")
  
  the_table <- HTML_in$children$html$children$body[[1]]
  
  # Get the table headers
  headers <- the_table$children[["thead"]]
  column_names <- lapply(headers$children[[1]]$children, function(x) XML::xmlValue(x))
  # Get the table content
  content <- c()
  # For each row
  for(i in 1:length(the_table[["tbody"]]$children))
  {
    table_row <- the_table[["tbody"]]$children[[i]]
    row_content<-c()
    # for each column
    for(j in 1:length(table_row$children)){
      
      v <- XML::xmlValue(table_row[[j]])
      
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