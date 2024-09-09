
# Function to read the file with the specified parameters
read_file_masstopred <- function(file_path) {
  
  req(file_path)
  ext <- tools::file_ext(file_path)
  validate(need(ext %in% c("txt", "csv", "tsv"), "Please upload a txt/csv/tsv file"))
  
  if (file.info(file_path)$size != 0) {
    
    tab <- read.table(file_path,
                      header = input$header_masstopredfile,
                      sep = input$separator_masstopredfile)
    
    # Add tab to global variables
    RV$mass_to_predict_formula_table <- tab
    
  } else {
    
    shinyalert("Oops!", "Your file is empty, retry.", type = "error")
    
  }
  
}

# FUNCTION to resolve formula based on mass and atoms composition
findAllCoefficientsWithTolerance <- function(target_mass, tolerance, user_atom_table_for_pred) {
    
    # Get the number of atoms to be used in prediction
    n_atoms <- nrow(user_atom_table_for_pred)
    
    # Init coefficient list result
    all_coefficients <- list()
    
    # Helper function for recursive backtracking
    backtrack <- function(current_combo, remaining_mass, index) {
        
        if (index > n_atoms) {
            # Check if the combination satisfies the target mass within the tolerance
            if (abs(remaining_mass) <= tolerance) {
                all_coefficients <<- c(all_coefficients, list(current_combo))
            }
            return()
        }
        
        atom_mass <- user_atom_table_for_pred$Mass[index]
        max_atoms <- floor(remaining_mass / atom_mass) + 1
        
        for (i in 0:max_atoms) {
            current_combo[index] <- i
            new_remaining_mass <- remaining_mass - i * atom_mass
            # Continue the recursive backtracking
            backtrack(current_combo, new_remaining_mass, index + 1)
        }
    }
    
    # Start the recursive backtracking from the first atom
    backtrack(rep(0, n_atoms), target_mass, 1)
    
    # Remove all solutions with negative coefficients
    if (!is_empty(all_coefficients)) {
        all_coefficients = all_coefficients[sapply(all_coefficients, function(lst) !any(lst < 0))]
    }
    
    return(all_coefficients)
    
}

UpdateParameterTextInfo <- function(mass, tolerance, atom_list) {
    
    output$prediction_parameters_text <- renderText({ 
        paste0("prediction parameters: mass=", mass, " (mass tolerance=", tolerance, ") for considered atoms: ", paste(list(atom_list), collapse = ", ")) 
    })
}

# OBSERVE changes for header, separator and quote parameters
observeEvent(c(input$separator_masstopredfile, input$header_masstopredfile, input$masstopred_file), {
  
  if (!is.null(input$masstopred_file$datapath)) {
    
    read_file_masstopred(input$masstopred_file$datapath)
    
  }
  
})

# OBSERVE changes for masstopred_file
observeEvent(input$masstopred_file, {
  
  # Read formula table 
  read_file_masstopred(input$masstopred_file$datapath)
  
})

# OBSERVE: Update choices for updateCheckboxGroupInput whenever mass_table changes
observe({
  
  choices <- unique(RV$mass_table$Element)
  updateCheckboxGroupInput(session, "selected_atom", choices = choices)
  
})

# OBSERVE: Run prediction
observeEvent(input$run_prediction, {
    
    # reset result
    RV$prediction_results_table = NULL
    
    selected_atoms <- input$selected_atom
    
    # Check if user checked some atoms, if not null then continue
    if (!is.null(selected_atoms)) {
    
        
        ###
        #
        # Get the atom info for all atoms checked by the user
        #
        ###
        
        result_entries <- lapply(selected_atoms, function(atom) {
          
            # get the mass of the atom from mass_table
            mass_value <- RV$mass_table$Mass[RV$mass_table$Element == atom]
          
            # get the symbol of the atom from mass_table
            symb_value <- RV$mass_table$Symbol[RV$mass_table$Element == atom]
          
            # format as a dataframe
            data.frame(Atom = atom,
                       Symbol = symb_value,
                       Mass = mass_value)
          
        })
      
        # turn the list of dataframes into a single dataframe
        param_tab <- do.call(rbind, result_entries)
        
        ###
        #
        # Perform prediction
        #
        ###
        
        # get the user params
        target_mass_user = as.numeric(input$user_target_mass_for_pred)
        target_mass_tolerance = as.numeric(input$user_target_mass_tol_for_pred)
        target_form = input$user_target_form_for_pred
        
        # adjust the target_mass for prediction according to the compound form
        if (target_form == "Neutral") {
            target_mass_updated = target_mass_user
        } else if(target_form == "+") {
            target_mass_updated = target_mass_user - as.numeric(input$electron_mass)
        } else if(target_form == "-") {
            target_mass_updated = target_mass_user + as.numeric(input$electron_mass)
        }
        
        # run prediction
        preds = findAllCoefficientsWithTolerance(target_mass_updated, 
                                                 target_mass_tolerance, 
                                                 param_tab)
      
        if (length(preds) > 0) {
      
          # Transform preds list to data.frame
          preds = do.call(rbind, preds)
        
          # Convert preds to a data frame if it's not already
          if (!is.data.frame(preds)) {
              preds <- as.data.frame(preds)
          }
        
          # rename column with atoms symbol
          colnames(preds) = param_tab$Symbol
        
          # add column for readable formula
          preds$formula <- apply(preds, 1, function(row) {
              # Filter out atoms with coefficient 0
              non_zero_atoms <- names(row)[row != 0]
              # Exclude coefficient from formula if it's 1
              non_one_coefficients <- ifelse(row[row != 0] == 1, "", row[row != 0])
              # Combine non-zero atoms with coefficients
              formula <- paste0(non_zero_atoms, non_one_coefficients, sep = "")
              # Concatenate the formula
              paste0(formula, collapse = "")
          })
        
          # add +/- or nothing depending on the compound form
          if (target_form == "Neutral") {
              preds$formula = preds$formula
          } else if(target_form == "+") {
              preds$formula = paste0(preds$formula, "+")
          } else if(target_form == "-") {
              preds$formula = paste0(preds$formula, "-")
          }
          
          # add the exact mass for the concatenated formula
          preds$formula_mass = NULL
          preds$formula_n_atoms = NULL
        
          # for each prediction
          for (i in 1:nrow(preds)) {
              cat(paste0("---\n"))
              # get the formula
              concatenated_formula = preds$formula[i]
              #cat(paste0("formula : ", concatenated_formula, "\n"))
              # calculate mass
              mass_calc = calculate_mass_from_formula(concatenated_formula)
              preds$formula_mass[i] = mass_calc$mass
              #cat(paste0("mass : ", mass_calc$mass, "\n"))
              # calculate delta to target mass
              preds$mass_delta[i] = target_mass_user - mass_calc$mass
              #cat(paste0("delta mass : ", preds$mass_delta[i], "\n"))
              # calculate delta to target mass in ppm
              preds$mass_delta_ppm[i] = ((target_mass_user - mass_calc$mass) / target_mass_user) * 1e6
              #cat(paste0("delta mass ppm : ", preds$mass_delta_ppm[i], "\n"))

          }
          
          # Save predictions to global variable
          RV$prediction_results_table = preds[order(abs(preds$mass_delta)), ]
        
        }
        
    } else {
        shinyalert("Oops!", "You must select at least 1 atom before running prediction", type = "error")
    }
    
    # update parameters text info
    UpdateParameterTextInfo(input$user_target_mass_for_pred, input$user_target_mass_tol_for_pred, input$selected_atom)
  
})
  
# RENDER mass to predict formula table
output$masstopred_table <- DT::renderDataTable({
  
  req(RV$mass_to_predict_formula_table)
  
  datatable(RV$mass_to_predict_formula_table,
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

# RENDER prediction table
output$prediction_results_tab <- DT::renderDataTable({
  
    req(RV$prediction_results_table)
  
    tab = RV$prediction_results_table
    tab$formula_mass = round(tab$formula_mass, digits = input$shiny_param_digits)
    tab$mass_delta = round(tab$mass_delta, digits = input$shiny_param_digits)
    tab$mass_delta_ppm = round(tab$mass_delta_ppm, digits = input$shiny_param_digits)
    
    datatable(tab,
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
