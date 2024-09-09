
# Function to read the file with the specified parameters
read_file_formula <- function(file_path) {
  
  req(file_path)
  ext <- tools::file_ext(file_path)
  validate(need(ext %in% c("txt", "csv", "tsv"), "Please upload a txt/csv/tsv file"))
  
  if (file.info(file_path)$size != 0) {
    
    tab <- read.table(file_path,
                      header = input$header_formulafile,
                      sep = input$separator_formulafile)
    
    # Check if the table has exactly 3 columns and column names are as expected
    if (ncol(tab) == 2 && all(colnames(tab) == c("MoleculeName", "Formula"))) {
    
        # Add tab to global variables
        RV$formula_table <- tab
    
    } else { shinyalert("Invalid Format!", "The uploaded file should have 2 columns with names 'MoleculeName', 'Formula'.", type = "error") }
  } else { shinyalert("Oops!", "Your file is empty, retry.", type = "error") }
  
}

process_adduct_for_list_of_formula = function() {
  
  # Empty multiple_formula_adduct_table if already filled previously
  RV$multiple_formula_adduct_table = data.frame(MoleculeName = character(),
                                               Formula = character(),
                                               Mass = numeric(),
                                               Modifier = character(),
                                               RelMass = numeric(),
                                               Charge = numeric(),
                                               AdductMass = numeric(),
                                               stringsAsFactors = FALSE)
    
  # Load formula list table
  formula_list = RV$formula_table
  
  # Load modifier table
  mod_tab = RV$user_modifier_input_table
  
  # if modifier table is not empty, compute adducts for all formula of the list
  if (dim(mod_tab)[1] > 0) {
    
    # For each formula from the formula list
    #for (user_formula in RV$formula_table$Formula) {
    for (i in 1:nrow(formula_list)) {  
      
      user_molname = formula_list$MoleculeName[i]
      user_formula = formula_list$Formula[i]
      
      # Get formula compound mass
      res = calculate_mass_from_formula(user_formula)
      
      formula_count_table = res$tab
      formula_compound_mass =  res$mass
      formula_compound_atom_diversity = res$div
      formula_compound_n_atoms = res$count
      
      # Compute adduct mass for each modifier
      for (i in 1:nrow(mod_tab)) {
        
        mod_bricks = mod_tab$Bricks[i]
        mod_relmass = mod_tab$RelMass[i]
        mod_charge = mod_tab$Charge[i]
        
        # fix charge (eg: if charge is 0 => 1 to compute m/z)
        fixed_charge = fix_charge(mod_charge)
        
        # Compute adduct mass considering the molecule charge and electron gain/loss
        adduct_mass = compute_adduct_mass(formula_compound_mass, mod_relmass, fixed_charge)
        
        # Create an entry
        new_entry = data.frame(MoleculeName = user_molname,
                               Formula = user_formula,
                               Mass = formula_compound_mass,
                               Modifier = mod_bricks,
                               RelMass = mod_relmass,
                               Charge = mod_charge,
                               AdductMass = adduct_mass,
                               stringsAsFactors = FALSE)
        
        # Add the new entry to the adduct table
        RV$multiple_formula_adduct_table = rbind(RV$multiple_formula_adduct_table, new_entry)
      
      }
        
    }
    
  }
  
}

# OBSERVE changes for header, separator and quote parameters
observeEvent(c(input$separator_formulafile, input$header_formulafile, input$formula_list_file), {
  
  if (!is.null(input$formula_list_file$datapath)) {
    
    read_file_formula(input$formula_list_file$datapath)
    
  }
  
})

# OBSERVE changes for formula_list_file
observeEvent(input$formula_list_file, {
  
  # Read formula table 
  read_file_formula(input$formula_list_file$datapath)
  
})

# OBSERVE: Compute adducts for the formula list 
observeEvent(input$compute_adducts_formulalist, {
  
  req(RV$formula_table)
  req(RV$user_modifier_input_table)
  
  if (dim(RV$formula_table)[1] > 0) {
      if (dim(RV$user_modifier_input_table)[1] > 0) {
          process_adduct_for_list_of_formula()
      } else { shinyalert("Oops!", "You must define modifiers first!", type = "error") }
  } else { shinyalert("Oops!", "Your file containing list of formula seems empty.", type = "error") }
  
})

# RENDER mass list table
output$formulalist_table <- DT::renderDataTable({
  
    req(RV$formula_table)
    
    datatable(RV$formula_table,
              filter = "top",
              selection = "single",
              rownames = TRUE,
              extensions = 'Buttons',
              options = list(autoWidth = FALSE,
                             Server = FALSE,
                             dom = 'lBfrtip',
                             scrollX = FALSE,
                             fixedColumns = TRUE, 
                             lengthMenu = list(c(10, 25, 50, 100, -1), c('10', '25', '50', '100', 'All')),
                             buttons = c('copy', 'csv', 'excel', 'pdf'))
    )
  
})

# RENDER mass list table
output$multiple_formula_adduct_df <- DT::renderDataTable({
  
    req(RV$multiple_formula_adduct_table)
  
    tab = RV$multiple_formula_adduct_table
    tab$Mass = round(tab$Mass, digits = input$shiny_param_digits)
    tab$RelMass = round(tab$RelMass, digits = input$shiny_param_digits)
    tab$AdductMass = round(tab$AdductMass, digits = input$shiny_param_digits)
    
    datatable(tab,
              filter = "top",
              selection = "single",
              rownames = TRUE,
              extensions = 'Buttons',
              options = list(autoWidth = FALSE,
                             server = FALSE,
                             dom = 'lBfrtip',
                             scrollX = FALSE,
                             buttons = c('copy', 'csv', 'excel', 'pdf'),
                             fixedColumns = TRUE, 
                             lengthMenu = list(c(10, 25, 50, 100, -1), c('10', '25', '50', '100', 'All')))
    )
  
})