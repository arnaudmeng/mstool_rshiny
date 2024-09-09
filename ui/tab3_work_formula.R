
# source : https://shiny.rstudio.com/gallery/file-upload.html`

tabItem(tabName = "workformula",
        
        h1("Work on your formula"),
        br(),
        h4("TODO: description"),
        br(),
        
        actionButton("tab3_work_formula_help", 
                     "Need help?", 
                     class = "btn-warning", 
                     style="color: #fff; background-color: #F19926; border-color: #2e6da4",
                     title = "HELP_PAGE2"),
        
        br(),
        br(),
        
        fluidRow(
          
          # Enter formula
          box(title = "User formula",
              status = "primary",
              width = 3,
              solidHeader = T,
              collapsible = F,
              
              # text box (enter formula)
              textInput("user_formula", "Enter your formula", "CH3(CH2)14COOH"),
              
              # Submit button
              actionButton('submit_formula', 'Submit'),
              
              conditionalPanel(condition="$('html').hasClass('shiny-busy')",
                               tags$div("Running...",id="runmessage")),
              
          ), # end box
          
          box(title = "Compound information",
              status = "primary",
              width = 9,
              solidHeader = TRUE,
              
              valueBoxOutput("compound_total_mass"),
              
              valueBoxOutput("compound_atom_diversity"),
              
              valueBoxOutput("compound_number_of_atoms")
            
          ), # end box

        ), # end fluidrow
        
        fluidRow(
          
          # Formula result table
          box(title = "Formula detail table", 
              status = "primary",
              width = 12,
              solidHeader = T,
              
              dataTableOutput('user_formula_count_table'),
              
          ), # end box

        ), # end fluidrow
        
        fluidRow(
          
          box(title = "Adduct summary", 
              status = "primary",
              width = 12,
              solidHeader = T,
              
              dataTableOutput('single_formula_adduct_df'),
              
          ), # end box
          
        ), # end fluidrow
        
) #end tabItem
