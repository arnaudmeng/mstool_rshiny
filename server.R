#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#

server <- function(input, output, session) {
    
    # maximum uploaded file size limit
    options(shiny.maxRequestSize=16000*1024^2)
    
    #source(file.path("R", "DimPlotly.R"),  local = TRUE)$value
  
    # global variables
    RV <- reactiveValues(mass_table = NULL,
                         user_formula = NULL,
                         user_formula_ionization = NULL,
                         user_formula_count_table = NULL,
                         user_formula_compound_mass = 0,
                         user_formula_compound_atom_diversity = 0,
                         user_formula_compound_n_atoms = 0,
                         user_brick_input_counter = 0,
                         user_brick_input_table = data.frame(Symbol = character(),
                                                             Count = numeric(),
                                                             Status = character(),
                                                             RelMass = numeric(),
                                                             stringsAsFactors = FALSE),
                         adduct_total_mass = NULL,
                         modifier_total_mass = NULL, 
                         user_charge = -1,
                         formula_table = data.frame(MoleculeName = character(),
                                                    Formula = character()),
                         user_modfier_input_table = data.frame(Bricks = character(),
                                                               RelMass = numeric(),
                                                               Charge = numeric(),
                                                               stringsAsFactors = FALSE),
                         single_formula_adduct_table = data.frame(Formula = character(),
                                                                  Mass = numeric(),
                                                                  Modifier = character(),
                                                                  RelMass = numeric(),
                                                                  Charge = numeric(),
                                                                  AdductMass = numeric(),
                                                                  stringsAsFactors = FALSE),
                         multiple_formula_adduct_table = data.frame(MoleculeName = character(),
                                                                    Formula = character(),
                                                                    Mass = numeric(),
                                                                    Modifier = character(),
                                                                    RelMass = numeric(),
                                                                    Charge = numeric(),
                                                                    AdductMass = numeric(),
                                                                    stringsAsFactors = FALSE),
                         mass_to_predict_formula_table = data.frame(ID = character(),
                                                                    META = character(),
                                                                    Mass = numeric()),
                         prediction_results_table = NULL, 
                         mass_to_pool_table = NULL,
                         mass_to_pool_result = NULL, 
                         sequence_table = NULL,
                         sample_block_size = 0, 
                         sample_block_n = 0,
                         total_blank_n = 0,
                         blank_block_n = 0,
                         sequence_result_table = data.frame(SampleType = character(),
                                                            FileName = character(),
                                                            Path = character(),
                                                            InstrumentMethod = character(),
                                                            Position = numeric(),
                                                            InjVol = numeric(),
                                                            stringsAsFactors = FALSE),
                         sequence_trials = 0,
                         mgf_spectrum_count = 0,
                         mgf_ms1_count = 0,
                         mgf_ms2_count = 0,
                         mgf_data = list(),
                         selected_spectrum = NULL)

    # TAB Load data
    source(file.path("server", "tab1_load_mass_data.R"),  local = TRUE)$value
    
    # TAB Define modifier
    source(file.path("server", "tab2_define_modifier.R"),  local = TRUE)$value
    
    # TAB Work formula
    source(file.path("server", "tab3_work_formula.R"),  local = TRUE)$value
    
    # TAB Compute list of adducts
    source(file.path("server", "tab4_compute_list_of_adducts.R"),  local = TRUE)$value
    
    # TAB Predict formula from mass
    source(file.path("server", "tab5_predict_formula_from_mass.R"),  local = TRUE)$value
    
    # TAB Generate pools
    source(file.path("server", "tab6_generate_mass_pools.R"),  local = TRUE)$value
    
    # TAB Build sequence
    source(file.path("server", "tab7_build_sequence.R"),  local = TRUE)$value
    
    # TAB mgf reader
    source(file.path("server", "tab8_mgf_reader.R"),  local = TRUE)$value
    
    ############################################################################
    #                                                                          #
    # Session information                                                      #
    #                                                                          #
    ############################################################################
    
    output$session_information <- renderPrint({
      
      print(sessioninfo::session_info())
      
    })
    
    ############################################################################
    #                                                                          #
    # Help messages                                                            #
    # 
    # use : https://dillinger.io
    # 
    ############################################################################

    observeEvent(input$tab1_load_mass_data_help, {
      
      showModal(modalDialog(
        title = "Tab 1 help",
        renderUI(HTML(includeMarkdown("vignettes/tab1_load_mass_data_help.md"))),
        easyClose = TRUE
      ))
    })
    
    observeEvent(input$tab2_define_modifier_help, {
      
      showModal(modalDialog(
        title = "Tab 2 help",
        renderUI(HTML(includeMarkdown("vignettes/tab2_define_modifier_help.md"))),
        easyClose = TRUE
      ))
    })
    
    observeEvent(input$tab3_work_formula_help, {
      
      showModal(modalDialog(
        title = "Tab 3 help",
        renderUI(HTML(includeMarkdown("vignettes/tab3_work_formula_help.md"))),
        easyClose = TRUE
      ))
    })
    
    observeEvent(input$tab4_compute_list_of_adducts_help, {
      
      showModal(modalDialog(
        title = "Tab 4 help",
        renderUI(HTML(includeMarkdown("vignettes/tab4_compute_list_of_adducts_help.md"))),
        easyClose = TRUE
      ))
    })
    
    observeEvent(input$tab5_predict_formula_from_mass_help, {
      
      showModal(modalDialog(
        title = "Tab 5 help",
        renderUI(HTML(includeMarkdown("vignettes/tab5_predict_formula_from_mass_help.md"))),
        easyClose = TRUE
      ))
    })
    
    observeEvent(input$tab6_generate_mass_pools_help, {
        
        showModal(modalDialog(
            title = "Tab 6 help",
            renderUI(HTML(includeMarkdown("vignettes/tab6_generate_mass_pools_help.md"))),
            easyClose = TRUE
        ))
    })
    
    observeEvent(input$tab7_build_sequence_help, {
        
        showModal(modalDialog(
            title = "Tab 7 help",
            renderUI(HTML(includeMarkdown("vignettes/tab7_build_sequence_help.md"))),
            easyClose = TRUE
        ))
    })
    
    observeEvent(input$tab8_mgf_reader_help, {
        
        showModal(modalDialog(
            title = "Tab 8 help",
            renderUI(HTML(includeMarkdown("vignettes/tab8_mgf_reader_help.md"))),
            easyClose = TRUE
        ))
    })
    
}
