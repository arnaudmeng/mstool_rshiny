
# source : https://shiny.rstudio.com/gallery/file-upload.html`

tabItem(tabName = "predict_formula_from_mass",
        
        h1("Predict formula from mass"),
        br(),
        h4("TODO: description"),
        br(),
        
        actionButton("tab5_predict_formula_from_mass_help", 
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
              
              fileInput('masstopred_file', 
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
              checkboxInput("header_masstopredfile", "Header", TRUE),
              radioButtons("separator_masstopredfile", "Separator",
                           choices = c("Comma" = ',',
                                       "Semicolon" = ";",
                                       "Tab" = "\t"),
                           selected = ';'),
              
              conditionalPanel(condition="$('html').hasClass('shiny-busy')",
                               tags$div("Running...",id="runmessage")),

          ), # end box
          
          # Table of mass to use for prediction
          box(title = "Mass for prediction", 
              status = "primary",
              width = 8,
              solidHeader = T,
              
              dataTableOutput('masstopred_table'),
              
          ), # end box

        ), # end fluidrow
        
        fluidRow(
          
          # Input box for prediction parameters
          box(title = "Prediction parameters", 
              status = "primary",
              width = 4,
              solidHeader = T,
              
              checkboxGroupInput("selected_atom", "Select atoms", choices = ""),
              
              textInput("user_target_mass_for_pred", "Enter a mass", "256.2402"),
              textInput("user_target_mass_tol_for_pred", "Enter a tolerance", "0.02"),
              
              selectInput("user_target_form_for_pred", "Compound form", choices = c("Neutral", "+", "-")),
              
              actionButton("run_prediction", "RUN")
              
          ), # end box
          
          # Table of mass to use for prediction
          box(title = "Prediction results", 
              status = "primary",
              width = 8,
              solidHeader = T,
              
              verbatimTextOutput("prediction_parameters_text"),
              dataTableOutput('prediction_results_tab'),
              
          ), # end box

        ), # end fluidrow

        
) #end tabItem
