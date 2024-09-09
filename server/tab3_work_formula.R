
# Function to decompose compound into atom list
count_atoms <- function(group, multiplier) {
  
  req(RV$mass_table)
  mass_table = RV$mass_table
  
  # Create an empty data.frame
  group_table = data.frame(Symbol = character(), Count = numeric(), stringsAsFactors = FALSE)
  
  # Order the mass_table so that elements with 2 letters come first
  mass_table = mass_table[order(nchar(mass_table$Symbol), decreasing = TRUE),]
  
  # Continue processing until the group is empty
  while (nchar(group) > 0) {
    
    # Flag to check if any match is found in the current iteration
    match_found = FALSE
    
    # Iterate through the symbols in mass_table
    for (i in seq_len(nrow(mass_table))) {
      
      # Extract the symbol
      symbol = mass_table$Symbol[i]
      symbol_sum = 0
      
      # Find matches of the symbol in the group
      matches = stri_match_all_regex(group, paste0("(", symbol, ")(\\d*)"))[[1]]
      
      # Check if the symbol is found in the matches
      if (any(sapply(matches, function(match) any(!is.na(match))))) {
        
        # Set the flag to true
        match_found <- TRUE
        
        # Iterate through matches and update the group_table
        for (match in matches[[1]]) {
          
          result = regmatches(match, regexec("([A-Za-z]+)([0-9]+)?", match))
          
          # Extract element and coefficient
          symb = result[[1]][2]
          ct = ifelse(length(result[[1]]) > 2 && result[[1]][3] != "", result[[1]][3], 1)
          
          # If no ct is specified, ct = 1
          ct = ifelse(is.na(ct), 1, as.numeric(ct))
          
          # print summary
          # print(paste0("There is: ", ifelse(is.na(ct), 1, as.numeric(ct)), " times ", symbol))
          
          # Prepare the new entry to add to group_table
          new_entry = data.frame(Symbol = symb, Count = ct, stringsAsFactors = FALSE)
          
          # Add the entry to group_table
          group_table = rbind(group_table, new_entry)
          
        }
        
        # Remove the symbol and coefficient (first occurrence) from the group
        group = str_replace(group, paste0("(", symb, ")(\\d*)"), "")
        
        # Break out of the loop after the first match
        break
        
      }
    }
    
    # Check if no match is found in the current iteration
    if (!match_found) {
      
      # This means we couldn't match any symbol, and the loop should break to avoid infinite loop
      break
      
    }
  }
  
  # When the group is empty multiply the Count column in group_table by "multiplier"
  group_table$Count = group_table$Count * multiplier
  
  # Finally return the result
  return(group_table)
  
}

calculate_mass_from_formula <- function(formula) {
  
  # Create an empty data.frame
  count_table = data.frame(Symbol = character(), Count = numeric(), stringsAsFactors = FALSE)
  
  # in the formula, find the first occurrence of group within parentheses
  # submit the first occurrence to count_atoms(match, multiplier) with multiplier being N in the string (XX)N
  # get the result and rbind it to count_table. 
  # remove the first occurrence of the matched group from the formula
  # redo the process until no group with parentheses is found in the formula
  # Then submit the rest of the formula to count_atoms() function with a multiplier of 1
  # rbind the result to the count_table
  
  # Check if the formula includes a positive or negative ion
  RV$user_formula_ionization = 0
  if (grepl("\\+$", formula)) {
      RV$user_formula_ionization = -1  # Positive ion, loss of an electron
      formula = sub("\\+$", "", formula)
  } else if (grepl("\\-$", formula)) {
      RV$user_formula_ionization = 1  # Negative ion, gain of an electron
      formula = sub("\\-$", "", formula)
  }
  
  # Continue processing until the formula is empty
  while (nchar(formula) > 0) {
    
    # Flag to check if any match is found in the current iteration
    match_found <- FALSE
    
    # Find the first occurrence of a group within parentheses in the formula
    group_match <- stri_match_all_regex(formula, "\\((.*?)\\)(\\d*)")[[1]]
    
    # Check if a group is found
    if (any(sapply(group_match, function(match) any(!is.na(match))))) {
      
      # Extract the group content and multiplier
      group_content <- group_match[1, 2]
      multiplier <- ifelse(!is.na(group_match[1, 3]), as.numeric(group_match[1, 3]), 1)
      
      # Process the group using count_atoms
      group_count_table <- count_atoms(group_content, multiplier)
      
      # Add the entries from the group to count_table
      count_table <- rbind(count_table, group_count_table)
      
      # Remove the first occurrence of the matched group from the formula
      formula <- str_replace(formula, "\\((.*?)\\)(\\d*)", "")
      
      # Set the flag to true
      match_found <- TRUE
      
    }
    
    # Check if no group is found in the current iteration
    if (!match_found) {
      
      # Process the remaining formula without parentheses with a multiplier of 1
      remaining_count_table <- count_atoms(formula, 1)
      
      # Add the entries from the remaining formula to count_table
      count_table <- rbind(count_table, remaining_count_table)
      
      # Break out of the loop
      break
      
    }
  }
  
  # Aggregate identical symbols and sum the counts
  count_table <- count_table %>%
    group_by(Symbol) %>%
    summarise(Count = sum(Count))
  
  # Merge the table with RV$mass_table
  merged_table <- merge(count_table, RV$mass_table, by = "Symbol", all.x = TRUE)
  
  # Add a column for the sum of mass
  merged_table$Mass_sum = with(merged_table, Mass * Count)
  
  # Rearrange columns 
  merged_table = merged_table[, c("Element", "Symbol", "Mass", "Count", "Mass_sum")]
  
  # Store the resulting table in the global variable
  user_formula_count_table = as.data.frame(merged_table)
  
  # Store the compound mass
  user_formula_compound_mass = sum(merged_table$Mass_sum)
  
  # adjust the mass for ionization if necessary
  user_formula_compound_mass = as.numeric(user_formula_compound_mass) + RV$user_formula_ionization * as.numeric(input$electron_mass)
  
  # Store the compound atom diversity
  user_formula_compound_atom_diversity = dim(merged_table)[1]
  
  # Store the number of atoms
  user_formula_compound_n_atoms = sum(merged_table$Count)
  
  # Return results
  return(list(tab = user_formula_count_table, 
              mass = user_formula_compound_mass, 
              div = user_formula_compound_atom_diversity, 
              count = user_formula_compound_n_atoms))
  
}

# FUNCTION: fix charge
fix_charge <- function(charge) {
  
  if (abs(charge) <= 1) {
    
    if (sign(charge) == 1) {
      charge = 1
    } else {
      charge = -1
    }
    
  } else {
    charge = charge
  }
  
  return(charge)
  
}

# FUNCTION: update the adduct total mass given the modifier mass (could be negative)
compute_adduct_mass <- function(compound_mass, modifier_mass, modifier_charge) {
  
  # if charge is positive (eg. +2) <=> loss of 2 electrons
  # else the charge is negative <=> gain of 2 electrons
  if (sign(modifier_charge) == 1) {
    res = (compound_mass + modifier_mass - (abs(modifier_charge) * as.numeric(input$electron_mass)) ) / abs(modifier_charge)
  } else {
    res = (compound_mass + modifier_mass + (abs(modifier_charge) * as.numeric(input$electron_mass)) ) / abs(modifier_charge)
  }
  
  return(res)
  
}

# OBSERVE button click event
observeEvent(input$submit_formula, {
  
  # Reset adduct table
  RV$single_formula_adduct_table = data.frame(Formula = character(),
                                              Mass = numeric(),
                                              Modifier = character(),
                                              RelMass = numeric(),
                                              Charge = numeric(),
                                              AdductMass = numeric(),
                                              stringsAsFactors = FALSE)
  
  # Get the user-entered formula
  user_formula = isolate(input$user_formula)
  
  # Store user formula in global variable
  RV$user_formula = user_formula
  
  # Calculate the mass of the compound
  results = calculate_mass_from_formula(user_formula)

  RV$user_formula_count_table = results$tab
  RV$user_formula_compound_mass =  results$mass
  RV$user_formula_compound_atom_diversity = results$div
  RV$user_formula_compound_n_atoms = results$count

  # Calculate the adduct mass for each modifier if the table is not empty
  mod_tab = RV$user_modifier_input_table
  
  # Compute all adducts
  #if (dim(mod_tab)[1] > 0) {
  if (!is.null(mod_tab)) {
    
    for (i in 1:nrow(mod_tab)) {
      
      mod_bricks = mod_tab$Bricks[i]
      mod_relmass = mod_tab$RelMass[i]
      mod_charge = mod_tab$Charge[i]
      
      # fix charge (eg: if charge is 0 => 1 to compute m/z)
      fixed_charge = fix_charge(mod_charge)
      
      # Compute adduct mass considering the molecule charge and electron gain/loss
      adduct_mass = compute_adduct_mass(RV$user_formula_compound_mass, mod_relmass, fixed_charge)
      
      # Create an entry
      new_entry = data.frame(Formula = RV$user_formula,
                             Mass = RV$user_formula_compound_mass,
                             Modifier = mod_bricks,
                             RelMass = mod_relmass,
                             Charge = mod_charge,
                             AdductMass = adduct_mass,
                             stringsAsFactors = FALSE)
      
      # Add the new entry to the adduct table
      RV$single_formula_adduct_table = rbind(RV$single_formula_adduct_table, new_entry)
      
    }
    
  }
  
})

# RENDER mass list table
output$user_formula_count_table <- DT::renderDataTable({
  
    req(RV$user_formula_count_table)
  
    tab = RV$user_formula_count_table
    tab$Mass = round(tab$Mass, digits = input$shiny_param_digits)
    tab$Mass_sum = round(tab$Mass_sum, digits = input$shiny_param_digits)
    
    datatable(tab,
              filter = "top",
              selection = "single",
              rownames = TRUE,
              extensions = 'Buttons',
              options = list(autoWidth = FALSE,
                             server = FALSE,
                             dom = 'lBfrtip',
                             buttons = c('copy', 'csv', 'excel', 'pdf'),
                             fixedColumns = TRUE, 
                             lengthMenu = list(c(10, 25, 50, 100, -1), c('10', '25', '50', '100', 'All')))
            )
            
  
})

# RENDER compound total mass
output$compound_total_mass <- renderValueBox({
  
  req(RV$user_formula_compound_mass)

  valueBox(
    round(RV$user_formula_compound_mass, digits = input$shiny_param_digits), "Total compound mass (UA)", icon = icon("weight-scale"),
    color = "blue"
  )
  
})

# RENDER compound number of atoms
output$compound_atom_diversity <- renderValueBox({
  
  req(RV$user_formula_compound_atom_diversity)
  
  valueBox(
    RV$user_formula_compound_atom_diversity, "type of atoms", icon = icon("elementor"),
    color = "blue"
  )
  
})

# RENDER compound number of atoms
output$compound_number_of_atoms <- renderValueBox({
  
  req(RV$user_formula_compound_n_atoms)
  
  valueBox(
    RV$user_formula_compound_n_atoms, "atoms", icon = icon("atom"),
    color = "blue"
  )
  
})

# RENDER mass list table
output$single_formula_adduct_df <- DT::renderDataTable({
  
    req(RV$single_formula_adduct_table)
    req(RV$user_formula_ionization)
    
    # if formula corresponds to neutral compound, then compute adduct
    if (RV$user_formula_ionization ==0) { 
        tab = RV$single_formula_adduct_table
        tab$Mass = round(tab$Mass, digits = input$shiny_param_digits)
        tab$RelMass = round(tab$RelMass, digits = input$shiny_param_digits)
        tab$AdductMass = round(tab$AdductMass, digits = input$shiny_param_digits)
    } else {
        tab = NULL
    }
    
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