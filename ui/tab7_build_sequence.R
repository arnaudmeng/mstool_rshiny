
# source : https://shiny.rstudio.com/gallery/file-upload.html`

tabItem(tabName = "build_sequence",
        
        h1("Build sequence"),
        br(),
        h4("TODO: description"),
        br(),
        
        actionButton("tab7_build_sequence_help", 
                     "Need help?", 
                     class = "btn-warning", 
                     style="color: #fff; background-color: #F19926; border-color: #2e6da4",
                     title = "HELP_PAGE5"),
        
        br(),
        br(),
        
        fluidRow(
          
          # Load file
          box(title = "Load file",
              status = "primary",
              width = 3,
              solidHeader = T,
              collapsible = F,
              
              fileInput('sequence_file', 
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
              checkboxInput("header_sequencefile", "Header", TRUE),
              radioButtons("separator_sequencefile", "Separator",
                           choices = c("Comma" = ',',
                                       "Semicolon" = ";",
                                       "Tab" = "\t"),
                           selected = ';'),
              
              conditionalPanel(condition="$('html').hasClass('shiny-busy')",
                               tags$div("Running...",id="runmessage")),

          ), # end box
          
          box(title = "Blank parameters", 
              status = "primary",
              width = 3,
              solidHeader = T,
              
              numericInput("user_seq_heading_blanks_n", "Heading blanks", value = 5, min = 1, max = 20),
              numericInput("user_seq_intermediate_blanks_n", "Intermediate blanks", value = 3, min = 1, max = 20),
              numericInput("user_seq_tailing_blanks_n", "Tailing blanks", value = 5, min = 1, max = 20),
              
          ), # end box
          
          box(title = "Sample parameters", 
              status = "primary",
              width = 3,
              solidHeader = T,
              
              numericInput("user_seq_rep_size", "Number of replicates", value = 3, min = 1, max = 10),
              numericInput("user_block_size", "User sample block size", value = 6, min = 2, max = 20),
              checkboxInput("run_optimal_block_size", "Automatic optimal block size ?", FALSE),
              helpText('If automatic optimal block size is checked, user sample block size won\'t be considerd'),
              numericInput("user_seq_min_block_size", "Min block size", value = 4, min = 2, max = 20),
              numericInput("user_seq_max_block_size", "Max block size", value = 10, min = 2, max = 20),
              
          ), # end box
          
          box(title = "Building parameters", 
              status = "primary",
              width = 3,
              solidHeader = T,
             
              numericInput("user_seq_max_iterations", "Max iterations", value = 50, min = 2, max = 10000),
              helpText('Maximum number of trials to build the sequence'),
              
              actionButton('build_sequence', 'Build'),
              
          ), # end box

        ), # end fluidrow
        
        fluidRow(
            
            # Pooling results
            box(title = "Resulting sequence", 
                status = "primary",
                width = 12,
                solidHeader = T,
                
                verbatimTextOutput("sequence_trials_counter"),
                verbatimTextOutput("sequence_total_length"),
                verbatimTextOutput("sample_block_info"),
                verbatimTextOutput("blank_block_info"),
                
                dataTableOutput('sequence_result_table'),
                
            ), # end box
            
            
        ) # end fluidrow
        
) #end tabItem
