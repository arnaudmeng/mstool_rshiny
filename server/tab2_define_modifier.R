
# FUNCTION: update the modifier total mass (could be negative) : the sum of the mass
# listed in the adduct table
update_modifier_mass <- function(user_brick_input_table) {
  
  sum_modifier_masses = sum(user_brick_input_table$RelMass)
  
  return( sum_modifier_masses )
  
}

# FUNCTION: add the new entry to the brick table
update_brick_table <- function(tab, formula, count, status) {
  
  # calculate the mass of the formula/atom to add/remove from compound
  results = calculate_mass_from_formula(formula)
  
  brick_mass = count * ifelse(input$user_brick_status == "Lost", -1, 1) * results$mass
  
  # Create the new entry
  new_entry <- data.frame(
    Symbol = formula,
    Count = count,
    Status = status,
    RelMass = brick_mass,
    stringsAsFactors = FALSE)
  
  # Add the new entry to the data frame
  updated_tab = rbind(tab, new_entry)
  
  return(updated_tab)
  
}

# FUNCTION: add the new entry to the modifier table
update_mod_table <- function(brick_tab, mod_tab, charge) {
  
  # if brick table is not empty
  if (dim(brick_tab)[1] > 0) {
    
    user_brick_summary <- character()
    
    # Create a summary string of the bricks
    for (i in 1:nrow(brick_tab)) {
      count <- brick_tab$Count[i]
      symbol <- brick_tab$Symbol[i]
      status <- brick_tab$Status[i]
      
      # Transform status to sign
      if (status == "Lost") { status = "-"} else { status = "+"}
      
      # Create a summary string for the current entry
      entry_summary <- paste(status, " (", symbol, ")", count, sep = "")
      
      # Append the current entry summary to the overall summary
      user_brick_summary <- paste(user_brick_summary, entry_summary, sep = " ")
      
    }
    
    # Calculate the total mass of the modifier
    sum_modifier_masses = sum(brick_tab$RelMass)
    
  } else {
    
    showNotification(
      "This is a warning message!",
      type = "warning",
      duration = 5
    )
    
  }
  
  # Create the new entry
  new_entry <- data.frame(Bricks = user_brick_summary,
                          RelMass = sum_modifier_masses,
                          Charge = as.numeric(input$user_charge),
                          stringsAsFactors = FALSE)
  
  # Add the new entry to the data frame
  updated_tab = rbind(mod_tab, new_entry)
  
  return(updated_tab)
  
}

# FUNCTION: remove entry a data frame
remove_last_entry_from_table = function(tab) {
  
  updated_tab <- tab[-nrow(tab), ]
  
  return(updated_tab)
  
}

# OBSERVE: Add a formula/atom
observeEvent(input$add_input_brick, {
  
  req(RV$user_brick_input_table)
  
  tab = RV$user_brick_input_table
  
  # Generate the updated table
  res = update_brick_table(tab, 
                           input$user_brick_formula, 
                           input$user_brick_formula_count, 
                           input$user_brick_status)
  
  updated_tab = res
  
  # Store the updates in global variable
  RV$user_brick_input_table = updated_tab
  
})

# OBSERVE: Remove last entry of the brick table
observeEvent(input$remove_input_brick, {
  
  req(RV$user_brick_input_table)

  tab = RV$user_brick_input_table
  
  # Remove last entry from the adduct table
  updated_tab = remove_last_entry_from_table(tab)
  
  # Store the update table in global variable
  RV$user_brick_input_table = updated_tab
  
})

# OBSERVE: Add a modifier
observeEvent(input$submit_modifier, {
  
  brick_tab = RV$user_brick_input_table
  mod_tab = RV$user_modifier_input_table
  
  if (dim(brick_tab)[1] > 0) {
  
    # Generate the updated table
    res = update_mod_table(brick_tab,
                           mod_tab,
                           input$user_charge)
    
    updated_tab = res
    
    # Store the updates in global variable
    RV$user_modifier_input_table = updated_tab
    
    # Reset bricks table
    RV$user_brick_input_table = data.frame(Symbol = character(),
                                           Count = numeric(),
                                           Status = character(),
                                           RelMass = numeric(),
                                           stringsAsFactors = FALSE)
    
  }
  
})

# OBSERVE: Remove last entry of the modifier table
observeEvent(input$remove_input_modifier, {
  
  req(RV$user_modifier_input_table)

  tab = RV$user_modifier_input_table
  
  # Remove last entry from the adduct table
  updated_tab = remove_last_entry_from_table(tab)
  
  # Store the update table in global variable
  RV$user_modifier_input_table = updated_tab
  
})

# OBSERVE: disable the submit button the value is not a numeric value
observe({
    # Convert input$user_charge to numeric
    user_charge_numeric <- as.numeric(input$user_charge)
    
    # Check if it's a numeric value
    if (is.na(user_charge_numeric)) {
        # If not numeric, disable the submit button
        shinyjs::disable("submit_modifier")
    } else {
        # If numeric, enable the submit button
        shinyjs::enable("submit_modifier")
        
    }
})

observe({
  
    # Validate the input$user_charge
    validate(
        need(!is.na(as.numeric(input$user_charge)), "Please enter a numeric value for 'Charge'.")
    )
    
    # Enable or disable the submit button based on validation
    shinyjs::toggleState("submit_modifier", !is.null(input$user_charge))
  
})

# RENDER bricks table
output$user_brick_input_df <- DT::renderDataTable({
  
    req(RV$user_brick_input_table)
  
    tab = RV$user_brick_input_table
    tab$RelMass = round(tab$RelMass, digits = input$shiny_param_digits)

    datatable(tab,
              filter = "top",
              selection = "single",
              rownames = TRUE,
              extensions = 'Buttons',
              options = list(autoWidth = FALSE,
                             Server = FALSE,
                             dom = 'lBfrtip',
                             scrollX = FALSE,
                             buttons = c('copy', 'csv', 'excel', 'pdf'),
                             fixedColumns = TRUE, 
                             lengthMenu = list(c(10, 25, 50, -1), c('10', '25', '50', 'All')))
              )
  
})

# RENDER modifier table
output$user_mod_input_df <- DT::renderDataTable({
  
    req(RV$user_modifier_input_table)
  
    tab = RV$user_modifier_input_table
    tab$RelMass = round(tab$RelMass, digits = input$shiny_param_digits)
    
    datatable(tab,
              filter = "top",
              selection = "single",
              rownames = TRUE,
              extensions = 'Buttons',
              options = list(autoWidth = F,
                             Server = FALSE,
                             dom = 'lBfrtip',
                             scrollX = FALSE,
                             buttons = c('copy', 'csv', 'excel', 'pdf'),
                             fixedColumns = TRUE, 
                             lengthMenu = list(c(10, 25, 50, 100, -1), c('10', '25', '50', '100', 'All'))) 
              )
  
})