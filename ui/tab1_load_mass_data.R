
# source : https://shiny.rstudio.com/gallery/file-upload.html`

tabItem(tabName = "loadmass",
        
        h1("Load mass list file"),
        br(),
        h4("TODO: description"),
        br(),
        
        actionButton("tab1_load_mass_data_help", 
                     "Need help?", 
                     class = "btn-warning", 
                     style="color: #fff; background-color: #F19926; border-color: #2e6da4",
                     title = "HELP_PAGE1"),
        
        br(),
        br(),
        
        fluidRow(
          
          # Load file
          box(title = "Load file",
              status = "primary",
              width = 3,
              solidHeader = T,
              collapsible = F,
              
              fileInput('massList_file', 
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
              checkboxInput("header_massfile", "Header", TRUE),
              radioButtons("separator_massfile", "Separator",
                           choices = c("Comma" = ',',
                                       "Semicolon" = ";",
                                       "Tab" = "\t"),
                           selected = ';'),
              
              conditionalPanel(condition="$('html').hasClass('shiny-busy')",
                               tags$div("Running...",id="runmessage")),
              
          ), # end box
          
          # application parameters
          box(title = "Shiny parameters", 
              status = "primary",
              width = 3,
              solidHeader = T,
              
              numericInput("shiny_param_digits", "Digits to show", value = 4, min = 1, max = 6),
              
              textInput("electron_mass", "Electron mass (Da)", "0.00054857"),
              
          ), # end box
          
        ), # end fluidrow
        
        fluidRow(
          
          # mass list content table
          box(title = "Mass table", 
              status = "primary",
              width = 12,
              solidHeader = T,
              
              dataTableOutput('masslist_table'),
              
          ), # end box

        ), # end fluidrow
        
) #end tabItem
