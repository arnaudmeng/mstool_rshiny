#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
#

# To execute on Windows: & 'C:\Program Files\R\R-4.3.2\bin\Rscript.exe' .\app.R

# Validation: https://byjus.com/chemical-compound-formulas/

library(shiny)

# source code

source("global.R")
source('ui.R', local = TRUE)
source('server.R')

# Run the application 
shinyApp(ui = ui, server = server)