
# source : https://shiny.rstudio.com/gallery/file-upload.html`

tabItem(tabName = "mgf_reader",
        
        h1("MGF reader"),
        br(),
        h4("TODO: description"),
        br(),
        
        actionButton("tab8_mgf_reader_help", 
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
              
              fileInput('mgf_file', 
                        'Upload a .mgf file', 
                        accept = c(".mgf")
              ),
              tags$hr(),
              conditionalPanel(condition="$('html').hasClass('shiny-busy')",
                               tags$div("Running...",id="runmessage")),

          ), # end box
          
          box(title = "MGF information",
              status = "primary",
              width = 9,
              solidHeader = TRUE,
              
              valueBoxOutput("mgf_file_nb_spectrums"),
              
              valueBoxOutput("mgf_file_ms1ms2_count"),
              
              #valueBoxOutput("compound_number_of_atoms")
              
          ), # end box
          
        ), # end fluirow
         
        fluidRow(
            
          # Title selector
          box(title = "Select spectrum",
              status = "primary",
              width = 12,
              solidHeader = TRUE,
              collapsible = FALSE,
              
              sliderInput('mz_range', 'Precursor m/z range',
                          min = 0, max = 2000, value = c(0, 2000), step = 0.01),
              tags$hr(),
              selectInput("spectrum_title", "Select Spectrum Title", choices = NULL)

          ), # end box
          
        ), # end fluidrow
        
        fluidRow(
            
            # Plot peaks
            box(title = "Peaks Plot",
                status = "primary",
                width = 12,
                solidHeader = TRUE,
                collapsible = FALSE,
                
                plotlyOutput("peaks_plot")
                
            ), # end box
            
        ), # end fluidrow
        
        fluidRow(
            
            # Spectrum details
            box(title = "Spectrum details",
                status = "primary",
                width = 6,
                solidHeader = TRUE,
                collapsible = FALSE,
                
                tableOutput("selected_spectrum_details")
                
            ), # end box
            
            # Spectrum raw table
            box(title = "Spectrum raw data",
                status = "primary",
                width = 6,
                solidHeader = TRUE,
                collapsible = FALSE,
                
                dataTableOutput('selected_spectrum_table'),
                
            ), # end box
            
        ), # end fuildrow
        
) #end tabItem
