#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#


ui <- dashboardPage(
  
    dashboardHeader(title = "MCF tool"),
    
    ## Sidebar content
    # icon library : https://fontawesome.com/icons?d=gallery&p=2&q=th
    
    dashboardSidebar(
        sidebarMenu(
            menuItem("Load mass list", tabName = "loadmass", icon = icon("database")),
            menuItem("Define modifier", tabName = "definemodifier", icon = icon("meteor")),
            menuItem("Work with formula", tabName = "workformula", icon = icon("connectdevelop")),
            menuItem("Compute list of adducts", tabName = "compute_list_of_adducts", icon = icon("list-ul")),
            menuItem("Predict formula", tabName = "predict_formula_from_mass", icon = icon("spinner")),
            menuItem("Generate mass pools", tabName = "generate_mass_pools", icon = icon("layer-group")),
            menuItem("Build sequence", tabName = "build_sequence", icon = icon("ruler-vertical")),
            menuItem("MGF reader", tabName = "mgf_reader", icon = icon("bars-staggered")),
            menuItem("Session Information", tabName = "sessioninfo", icon = icon("info"))
        )
    ),
    
    dashboardBody(
        
        # Running message
        tags$head(tags$style(type="text/css", "
             #runmessage {
               position: fixed;
               top: 0px;
               left: 0px;
               width: 100%;
               padding: 5px 0px 5px 0px;
               text-align: center;
               font-weight: bold;
               font-size: 100%;
               color: #000000;
               background-color: #CCFF66;
               z-index: 105;
             }
          ")),
        
        # bsModal window size
        tags$style(HTML("
                        
                        .modal { max-height: 100%; }
                        .modal-body { max-height: none; height: 80vh; overflow-y: auto; }
                        .modal-dialog { width: 90%; }
                        
                        ")),
        
        tabItems(
            
            # TAB: load mass data
            source(file.path("ui", "tab1_load_mass_data.R"),  local = TRUE)$value,
            
            # TAB: define modifier
            source(file.path("ui", "tab2_define_modifier.R"),  local = TRUE)$value,
            
            # TAB: work with formula
            source(file.path("ui", "tab3_work_formula.R"),  local = TRUE)$value,
            
            # TAB: compute list of adducts
            source(file.path("ui", "tab4_compute_list_of_adducts.R"),  local = TRUE)$value,
            
            # TAB: predict formula from mass
            source(file.path("ui", "tab5_predict_formula_from_mass.R"),  local = TRUE)$value,
            
            # TAB: generate mass pools
            source(file.path("ui", "tab6_generate_mass_pools.R"),  local = TRUE)$value,
            
            # TAB: build sequence
            source(file.path("ui", "tab7_build_sequence.R"),  local = TRUE)$value,
            
            # TAB: mgf reader
            source(file.path("ui", "tab8_mgf_reader.R"),  local = TRUE)$value,
            
            ############################################################################
            #                                                                          #
            # Session information                                                      #
            #                                                                          #
            ############################################################################
            
            tabItem(tabName = "sessioninfo",
                    
                    h1("Session information"),
                    br(),
                    
                    verbatimTextOutput("session_information")
                    
            ) # end tabItem
                            
        ) # end tabItems
        
    ) # dashboardBody
    
) # dashboardPage