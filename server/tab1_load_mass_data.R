
# OBSERVE changes for header, separator and quote parameters
observeEvent(c(input$separator_massfile, input$header_massfile, input$massList_file), {
  
  if (!is.null(input$massList_file$datapath)) {
    
    read_file(input$massList_file$datapath)
    
  }
  
})

# Function to read the file with the specified parameters
read_file <- function(file_path) {
  
  req(file_path)
  ext <- tools::file_ext(file_path)
  validate(need(ext %in% c("txt", "csv", "tsv"), "Please upload a txt/csv/tsv file"))
  
  if (file.info(file_path)$size != 0) {
    
    tab <- read.table(file_path,
                      header = input$header_massfile,
                      sep = input$separator_massfile)
    
    # Check if the table has exactly 3 columns and column names are as expected
    if (ncol(tab) == 3 && all(colnames(tab) == c("Element", "Symbol", "Mass"))) {
        RV$mass_table <- tab
    } else { shinyalert("Invalid Format!", "The uploaded file should have 3 columns with names 'Element', 'Symbol', and 'Mass'.", type = "error") }
  } else { shinyalert("Oops!", "Your file is empty, retry.", type = "error") }
  
}

# OBSERVE changes for massList_file
observeEvent(input$massList_file, {
  
  read_file(input$massList_file$datapath)
  
})

# RENDER mass list table
output$masslist_table <- DT::renderDataTable({
  
    req(RV$mass_table)
  
    tab = RV$mass_table
    
    # adjust table with the number of digits
    tab$Mass = round(tab$Mass, digits = input$shiny_param_digits)
    
    datatable(tab,
              filter = "top",
              selection = "single",
              rownames = FALSE,
              extensions = 'Buttons',
              options = list(autoWidth = FALSE,
                             Server = FALSE,
                             dom = 'lBfrtip',
                             scrollX = FALSE,
                             buttons = c('copy', 'csv', 'excel', 'pdf'),
                             fixedColumns = TRUE, 
                             lengthMenu = list(c(10, 25, 50, 100, -1), c('10', '25', '50', '100', 'All'))) 
    )
  
})