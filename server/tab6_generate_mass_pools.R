
# Function to read the file with the specified parameters
read_file_masstopool <- function(file_path) {
  
  req(file_path)
  ext <- tools::file_ext(file_path)
  validate(need(ext %in% c("txt", "csv", "tsv"), "Please upload a txt/csv/tsv file"))
  
  if (file.info(file_path)$size != 0) {
    
    tab <- read.table(file_path,
                      header = input$header_masstopoolfile,
                      sep = input$separator_masstopoolfile)
    
    if (ncol(tab)>=2) {
        if (colnames(tab)[1] == "ID") {
            # Add tab to global variables
            RV$mass_to_pool_table <- tab
        } else { shinyalert("Oops!", "First column of your file should be 'ID'", type = "error") }
    } else { shinyalert("Oops!", "You file must contain at least 2 columns", type = "error") }
  } else { shinyalert("Oops!", "Your file is empty, retry.", type = "error") }
  
}

# OBSERVE changes for header, separator and quote parameters
observeEvent(c(input$separator_masstopoolfile, input$header_masstopoolfile, input$masstopool_file), {
  
  if (!is.null(input$masstopool_file$datapath)) {
    
    read_file_masstopool(input$masstopool_file$datapath)
    
  }
  
})

# OBSERVE changes for masstopool_file
observeEvent(input$masstopool_file, {
  
  # Read formula table 
  read_file_masstopool(input$masstopool_file$datapath)
  
})

# FUNCTION to check for dataframe to not contain duplicates across lines
check_dataframe = function(df, tolerance) {
    
    mat = as.matrix(df)
    val = c(mat)
    dup = sum(duplicated(val))
    
    if (dup == 0) { return(TRUE) } 
    else { return(FALSE) }
    
}

# FUNCTION to perform check_dataframe() function on a list of dataframes
check_multiple_pools = function(pool_list) {
    
    check_list = list()
    
    for (i in 1:length(pool_list)) {
        check_list[i] = check_dataframe(df = pool_list[[i]], tolerance = TOL)
    }
    
    return(check_list)
    
}


# FUNCTION to create random pools based on df lines
make_rd_pools = function(input_df, N) {
    
    # create index vector
    indices <- sample(rep(1:N, each = ceiling(nrow(input_df)/N))[1:nrow(input_df)])
    # Random split data frame
    pool_list <- split(input_df, indices)
    return(pool_list)
    
}

# FUNCTION to optimize pools to split similar masses (according to tolerance) in different pools
make_pools = function(input_df, N, tolerance=0.001, max_iteration=30) {
    
    iteration = 1
    
    # Initialize final pool list
    final_pools <- list()
    
    while (N > 1) {
        #cat(paste("Pool iteration:", iteration, "\n"))
        pool_list = make_rd_pools(input_df = input_df, N = N)
        for (i in seq_along(pool_list)) {
            #print(paste("Checking i:", i," || N:", N," || length(pool_list):", length(pool_list)," || nrow(input_df):", nrow(input_df)," || length(final_pools):", length(final_pools)))
            if (check_dataframe(pool_list[[i]], TOL)) {
                final_pools <- c(final_pools, pool_list[i])
                pool_rownames <- rownames(pool_list[[i]])
                input_df <- input_df[!(rownames(input_df) %in% pool_rownames), , drop = FALSE]
                N <- N - 1
            }
        }
        iteration = iteration + 1
        if(iteration > max_iteration) {
            final_pools <- c(final_pools, list(as.data.frame(input_df)))
            break 
        }
    }
    
    while (N == 1) {
        for (j in 1:nrow(input_df)) {
            line = input_df[j, , drop=FALSE]
            for (k in seq_along(final_pools)) {
                test_pool = rbind(final_pools[[k]], line)
                if (check_dataframe(test_pool, TOL)) {
                    final_pools[[k]] = test_pool
                    input_df = input_df[-j, , drop=FALSE]
                    break
                }
            }
        }
        # Add remaining lines as a last pool
        final_pools <- c(final_pools, list(as.data.frame(input_df)))
        N = 0
        input_df = tibble()
    }
    
    return(final_pools)
}

# FUNCTION to launch the pooling process
generate_pools = function(input_df, N, tolerance=0.001, max_iteration=5, pool_iteration=10) {
    
    all_pools_ok = FALSE
    
    iteration = 1
    
    # While all pools are not yet found
    while (all_pools_ok==FALSE) {
        #cat(paste("---iteration n:", iteration,"---\n"))
        # Decrease the number of iterations
        iteration = iteration + 1
        # Get pools
        final_pools = make_pools(input_df = input_df, N = N, tolerance = tolerance, max_iteration = pool_iteration)
        # Check pools
        if (length(final_pools)>0) {
            ch = check_multiple_pools(final_pools)
            if (all(unique(unlist(ch)))) { 
                all_pools_ok <- TRUE 
                break
            }
        }
        if (iteration > max_iteration) { break }
    }
    
    if (all_pools_ok==TRUE && length(final_pools) <= N) {
        # Rename pool list names
        final_pools <- setNames(final_pools, paste0("Pool_", seq_along(final_pools)))
        return(final_pools)
        
    } else {
        return(list())
    }
    
}

# OBSERVE: Run pooling
observeEvent(input$run_pooling, {

    req(RV$mass_to_pool_table)
    
    data = RV$mass_to_pool_table
    
    # remove first column
    rownames(data) = data$ID
    data = data[,-1]
    
    if (!is.numeric(as.numeric(input$user_mass_pool_tolerance))) {
        # Display error message if not numeric
        shinyjs::enable("error_message")
        output$error_message <- renderPrint({
            "Error: Please enter a numeric value for mass tolerance."
        })
    } else {
        # Reset the error message if the value is numeric
        shinyjs::disable("error_message")
        output$error_message <- renderPrint({ NULL })
        
        # Run
        final_pools = generate_pools(input_df = data, 
                                     N = input$user_number_of_pool, 
                                     tolerance = as.numeric(input$user_mass_pool_tolerance), 
                                     max_iteration = input$user_max_opti_iteration, 
                                     pool_iteration = input$user_max_pool_iteration)
        
        # Transform list of pools into dataframe
        final_pools_combined <- bind_rows(final_pools, .id = "Pool_Index")
        final_pools_combined$ID = rownames(final_pools_combined)
        
        # merge to original file
        #data_final = merge(x = data, final_pools_combined[,c("ID","Pool_Index")], all.x = T, by="ID")
        
        RV$mass_to_pool_result = final_pools_combined
        
    }
    
})

# RENDER pooling information: number of pools
output$pooling_res_n_pools <- renderValueBox({
    
    req(RV$mass_to_pool_result)
    
    df = RV$mass_to_pool_result
    
    n_final_pools = length(unique(df$Pool_Index))
    
    valueBox(
        n_final_pools, "Pools", icon = icon("elementor"),
        color = "blue"
    )
    
})

# RENDER pooling information: range of pool size
output$pooling_res_pool_size_range <- renderValueBox({
    
    req(RV$mass_to_pool_result)
    
    df = RV$mass_to_pool_result
    
    pool_table_ct = as.data.frame(df) %>% count(Pool_Index, name="Size")
    
    min_pool_size = min(pool_table_ct$Size)
    max_pool_size = max(pool_table_ct$Size)
    
    out_print = paste0(min_pool_size, "-", max_pool_size)
    
    valueBox(
        out_print, "Pool size range", icon = icon("elementor"),
        color = "blue"
    )
    
})

# RENDER pooling information: range of pool size
output$pooling_res_pool_size <- renderValueBox({
    
    req(RV$mass_to_pool_result)
    
    df = RV$mass_to_pool_result
    
    pool_table_ct = as.data.frame(df) %>% count(Pool_Index, name="Size")
    
    min_pool_size = min(pool_table_ct$Size)
    max_pool_size = max(pool_table_ct$Size)
    
    smallest_pools = pool_table_ct[which(pool_table_ct$Size == min_pool_size), "Pool_Index"]
    largest_pools = pool_table_ct[which(pool_table_ct$Size == max_pool_size), "Pool_Index"]
    
    out_print_1 = paste0('largest: ', largest_pools)
    out_print_2 = paste0('smallest: ', smallest_pools)
    
    valueBox(
        out_print_1, out_print_2, icon = icon("elementor"),
        color = "blue"
    )
    
})

# RENDER mass to predict formula table
output$masstopool_table <- DT::renderDataTable({
  
  req(RV$mass_to_pool_table)
  
  datatable(RV$mass_to_pool_table,
            filter = "top",
            selection = "single",
            rownames = TRUE,
            extensions = 'Buttons',
            options = list(autoWidth = FALSE,
                           Server = FALSE,
                           dom = 'lBfrtip',
                           scrollX = TRUE,
                           fixedColumns = TRUE, 
                           lengthMenu = list(c(10, 25, 50, 100, -1), c('10', '25', '50', '100', 'All')),
                           buttons = c('copy', 'csv', 'excel', 'pdf'))
            )
  
})

# RENDER mass to predict formula table
output$masstopool_result_table <- DT::renderDataTable({
    
    req(RV$mass_to_pool_result)
    
    datatable(RV$mass_to_pool_result,
              filter = "top",
              selection = "single",
              rownames = TRUE,
              extensions = 'Buttons',
              options = list(autoWidth = FALSE,
                             Server = FALSE,
                             dom = 'lBfrtip',
                             scrollX = TRUE,
                             fixedColumns = TRUE,
                             lengthMenu = list(c(10, 25, 50, 100, -1), c('10', '25', '50', '100', 'All')),
                             buttons = c('copy', 'csv', 'excel', 'pdf'))
    )
    
})