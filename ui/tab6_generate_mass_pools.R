
# source : https://shiny.rstudio.com/gallery/file-upload.html`

tabItem(tabName = "generate_mass_pools",
        
        h1("Generate mass pools"),
        br(),
        h4("TODO: description"),
        br(),
        
        actionButton("tab6_generate_mass_pools_help", 
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
              width = 4,
              solidHeader = T,
              collapsible = F,
              
              fileInput('masstopool_file', 
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
              checkboxInput("header_masstopoolfile", "Header", TRUE),
              radioButtons("separator_masstopoolfile", "Separator",
                           choices = c("Comma" = ',',
                                       "Semicolon" = ";",
                                       "Tab" = "\t"),
                           selected = ';'),
              
              conditionalPanel(condition="$('html').hasClass('shiny-busy')",
                               tags$div("Running...",id="runmessage")),

          ), # end box
          
          # Table of mass to use for prediction
          box(title = "Mass to pool", 
              status = "primary",
              width = 8,
              solidHeader = T,
              
              dataTableOutput('masstopool_table'),
              
          ), # end box

        ), # end fluidrow
        
        fluidRow(
            
            # Pooling parameters
            box(title = "Pool parameters", 
                status = "primary",
                width = 4,
                solidHeader = T,
                
                numericInput("user_number_of_pool", "Number of pools", value = 20, min = 2, max = 100),
                textInput("user_mass_pool_tolerance", "Enter a mass tolerance", "0.01"),
                numericInput("user_max_opti_iteration", "Maximum optimization iterations", value = 50, min = 2, max = 200),
                numericInput("user_max_pool_iteration", "Maximum pooling iterations", value = 50, min = 2, max = 200),
                
                actionButton('run_pooling', 'Generate pools'),
                
            ), # end box
            
            box(title = "Pooling information",
                status = "primary",
                width = 8,
                solidHeader = TRUE,
                
                valueBoxOutput("pooling_res_n_pools"),
                
                valueBoxOutput("pooling_res_pool_size_range"),
                
                valueBoxOutput("pooling_res_pool_size")
                
            ), # end box
            
            
        ), # end fluidrow
        
        fluidRow(
            
            # Pooling results
            box(title = "Pool results", 
                status = "primary",
                width = 12,
                solidHeader = T,
                
                dataTableOutput('masstopool_result_table'),
                
            ), # end box
            
            
        ) # end fluidrow
        
) #end tabItem
