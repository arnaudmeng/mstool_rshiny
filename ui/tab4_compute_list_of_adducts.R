
# source : https://shiny.rstudio.com/gallery/file-upload.html`

tabItem(tabName = "compute_list_of_adducts",
        
        h1("Compute list of adducts"),
        br(),
        h4("TODO: description"),
        br(),
        
        actionButton("tab4_compute_list_of_adducts_help", 
                     "Need help?", 
                     class = "btn-warning", 
                     style="color: #fff; background-color: #F19926; border-color: #2e6da4",
                     title = "HELP_PAGE4"),
        
        br(),
        br(),
        
        fluidRow(
          
          # Load file
          box(title = "Load file",
              status = "primary",
              width = 3,
              solidHeader = T,
              collapsible = F,
              
              fileInput('formula_list_file', 
                        'Upload a .txt, .csv or .tsv file', 
                        accept = c(
                          "text/csv",
                          "text/tsv",
                          "text/plain",
                          ".csv",
                          ".tsv",
                          ".txt")
              ),
              tags$hr(),
              checkboxInput("header_formulafile", "Header", TRUE),
              radioButtons("separator_formulafile", "Separator",
                           choices = c("Comma" = ',',
                                       "Semicolon" = ";",
                                       "Tab" = "\t"),
                           selected = ';'),
              
              conditionalPanel(condition="$('html').hasClass('shiny-busy')",
                               tags$div("Running...",id="runmessage")),
              
              # Submit button
              actionButton('compute_adducts_formulalist', 'Compute adducts'),
              
          ), # end box
          
          # Formula list table
          box(title = "Formula table", 
              status = "primary",
              width = 9,
              solidHeader = T,
              
              dataTableOutput('formulalist_table'),
              
          ), # end box

        ), # end fluidrow
        
        fluidRow(
          
          # Formula list table
          box(title = "Adduct table", 
              status = "primary",
              width = 12,
              solidHeader = T,
              
              dataTableOutput('multiple_formula_adduct_df'),
              
          ), # end box
          
        ), # end fluidrow
        
) #end tabItem
