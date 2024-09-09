
# source : https://shiny.rstudio.com/gallery/file-upload.html`

library(shinyjs)

tabItem(tabName = "definemodifier",
        
        h1("Define modifier(s)"),
        br(),
        h4("TODO: description"),
        br(),
        
        actionButton("tab2_define_modifier_help", 
                     "Need help?", 
                     class = "btn-warning", 
                     style="color: #fff; background-color: #F19926; border-color: #2e6da4",
                     title = "HELP_PAGE2"),
        
        br(),
        br(),
        
        fluidRow(
          
          # use shinyjs
          shinyjs::useShinyjs(),
            
          box(title = "Add a modifier bricks", 
              status = "primary",
              width = 3,
              solidHeader = T,
              
              textInput("user_brick_formula", "Enter formula/atom", "H"),
              numericInput("user_brick_formula_count", "Count", value = 1, min = 1),
              selectInput("user_brick_status", "Gain/Lost Status", choices = c("Lost", "Gain")),
              
              # Action buttons
              actionButton("add_input_brick", "Add"),
              actionButton("remove_input_brick", "Remove last")
              
          ), # end box
          
          box(title = "Modifier bricks", 
              status = "primary",
              width = 6,
              solidHeader = T,
              
              dataTableOutput('user_brick_input_df'),
              
          ), # end box
          
          box(title = "Submit your modifier", 
              status = "primary",
              width = 3,
              solidHeader = T,
              
              helpText('Note that the charge will be applied in the "work formula" and the "compute list of adducts" tabs'),
              helpText('Make sure to enter a numeric value (e.g "-1" or "2")'),
              
              textInput("user_charge", "Charge", value = "-1"),
              
              actionButton('submit_modifier', 'Submit'),
              actionButton("remove_input_modifier", "Remove last")

          ), # end box
          
        ), # end fluidrow
        
        fluidRow(
          
          box(title = "Modifiers summary table", 
              status = "primary",
              width = 12,
              solidHeader = T,
              
              dataTableOutput('user_mod_input_df'),
              
          ), # end box
          
        ), # end fluidrow
        
) #end tabItem
