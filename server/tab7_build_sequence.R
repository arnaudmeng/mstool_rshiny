
# Function to read the file with the specified parameters
read_file_squence <- function(file_path) {
  
  req(file_path)
  ext <- tools::file_ext(file_path)
  validate(need(ext %in% c("txt", "csv", "tsv"), "Please upload a txt/csv/tsv file"))
  
  if (file.info(file_path)$size != 0) {
    
    tab <- read.table(file_path,
                      header = input$header_masstopoolfile,
                      sep = input$separator_masstopoolfile)
    
    if (ncol(tab)>=1) {
        if (colnames(tab)[1] == "filename") {
            # Add tab to global variables
            RV$sequence_table <- tab
        } else { shinyalert("Oops!", "First column of your file should be 'filename'", type = "error") }
    } else { shinyalert("Oops!", "You file must contain a single column", type = "error") }
  } else { shinyalert("Oops!", "Your file is empty, retry.", type = "error") }
  
}

# OBSERVE changes for header, separator and quote parameters
observeEvent(c(input$separator_sequencefile, input$header_sequencefile, input$sequence_file), {
  
  if (!is.null(input$sequence_file$datapath)) {
    
      read_file_squence(input$sequence_file$datapath)
    
  }
  
})

# OBSERVE changes for sequence_file
observeEvent(input$sequence_file, {
  
  # Read formula table 
    read_file_squence(input$sequence_file$datapath)
  
})

# Function to create replicates
create_replicates <- function(sample, N) {
    
    # Initialize a vector to store the suffixes
    suffixes <- sprintf("_%03d", 1:N)
    
    # Add suffixes to the blanks elements
    replicates <- paste(sample, suffixes, sep = "")
    #replicates <- paste0(sample, "_rep", 1:N)
    
    return(replicates)
}

# Function to calculate the variance of block sizes
calculate_variance <- function(samples, block_size) {
    # Calculate the number of blocks
    num_blocks <- ceiling(length(samples) / block_size)
    #print(paste0("num_blocks:", num_blocks))
    # Calculate the size of each block
    block_sizes <- rep(block_size, num_blocks)
    #print(paste0("block_sizes:", block_sizes))
    # Calculate the remaining samples
    remaining_samples <- length(samples) %% block_size
    # Adjust the size of the last block if there are remaining samples
    if (remaining_samples > 0) {
        block_sizes[num_blocks] <- remaining_samples
    }
    #print(block_sizes)
    # Calculate the variance of block sizes
    if (length(block_sizes) > 1) {
        variance <- var(block_sizes)
    } else {
        variance <- 0
    }
    return(variance)
}

# Function to extract the pool ID from a filename
extract_pool_id <- function(filename) {
    # Split the filename by underscore
    parts <- unlist(strsplit(filename, "_"))
    # Check if there are at least 6 parts
    if (length(parts) >= 6) {
        pool_id <- parts[6]
        return(pool_id)
    } else {
        cat(paste("Not enough parts in filename:", filename, "\n"))
        return(NA)
    }
}

# Function to check for duplicates in a block
check_duplicates <- function(block) {
    # Extract pool IDs from filenames in the block
    pool_ids <- sapply(block, extract_pool_id)
    # Check for NA values
    if (any(is.na(pool_ids))) {
        cat("One or more filenames have no pool ID\n")
        return(TRUE)  # Return TRUE if there are NA values
    }
    # Count occurrences of each pool ID
    pool_id_counts <- table(pool_ids)
    # Check if any count is greater than 1
    has_duplicates <- any(pool_id_counts > 1)
    return(has_duplicates)
}


# OBSERVE: Run pooling
observeEvent(input$build_sequence, {
    
    # Get current time
    current_time <- Sys.time()
    
    # Extract numerical representation of time
    seed <- as.numeric(current_time)
    
    # Set seed
    set.seed(seed)
    
    # Initialize the number of trials
    n_trials = 0
    
    # reset trials counter
    RV$sequence_trials = 0
    
    while(n_trials <= input$user_seq_max_iterations) {
    
        n_trials = n_trials + 1

        # save to global variables
        RV$sequence_trials = n_trials
        
        ##
        ## STEP 1: Load
        ##
        
        req(RV$sequence_table)
        
        data = RV$sequence_table
        
        ##
        ## STEP 2: Generate sample replicates
        ##
        
        # Filter out lines starting with "S_"
        samples <- data[grep("^S_", data$filename),]
        
        # Create replicates for each sample
        replicated_samples <- unlist(lapply(samples, create_replicates, input$user_seq_rep_size))
        
        ##
        ## STEP 3: Determine sample block size
        ##
        
        # Determine the sample block size
        if(input$run_optimal_block_size == FALSE) {
            
            SAMPLE_BLOCK_SIZE = input$user_block_size
            
            # save to global variables
            RV$sample_block_size = SAMPLE_BLOCK_SIZE
            
        } else {
            
            PARAM_MIN_BLOCK_SIZE = input$user_seq_min_block_size
            PARAM_MAX_BLOCK_SIZE = input$user_seq_max_block_size
            MIN_VARIANCE <- Inf
            
            for (block_size in PARAM_MIN_BLOCK_SIZE:PARAM_MAX_BLOCK_SIZE) {
                #print(paste0("Testing block size:", block_size))
                variance <- calculate_variance(replicated_samples, block_size)
                #print(variance)
                if (!is.na(variance) && variance < MIN_VARIANCE) {
                    MIN_VARIANCE <- variance
                    OPTIMAL_BLOCK_SIZE <- block_size
                }
            }
            
            SAMPLE_BLOCK_SIZE = OPTIMAL_BLOCK_SIZE
            
            # save to global variables
            RV$sample_block_size = SAMPLE_BLOCK_SIZE
            
        }
        
        # Determine the number of sample blocs needed
        N_SAMPLE_BLOCKS = ceiling( length(replicated_samples) / SAMPLE_BLOCK_SIZE )
        
        # save to global variables
        RV$sample_block_n = N_SAMPLE_BLOCKS
        
        ##
        ## STEP 4: Generate blanks
        ##
        
        # Determine the total number of blanks
        N_BLANKS = input$user_seq_heading_blanks_n + input$user_seq_tailing_blanks_n + ( N_SAMPLE_BLOCKS - 1 ) * input$user_seq_intermediate_blanks_n
        
        # Store to global variables
        RV$total_blank_n = N_BLANKS
        
        # Filter out lines starting with "W_"
        blanks <- data[grep("^W_", data$filename),]
        
        # Initialize a vector to store the suffixes
        bl_suffixes <- sprintf("_%03d", 1:N_BLANKS)
        
        # Add suffixes to the blanks elements
        replicated_blanks <- paste(blanks, bl_suffixes, sep = "")

        ##
        ## STEP 5: Generate sample blocks
        ##
        
        # Calculate the number of samples remaining
        remaining_samples <- length(replicated_samples)
        
        # Initialize a list to store the blocks of samples
        sample_blocks <- list()
        
        # Calculate the number of blocks needed
        num_blocks <- ceiling(remaining_samples / SAMPLE_BLOCK_SIZE)
        
        # Loop to create blocks of samples
        for (i in 1:num_blocks) {
            # Calculate the number of samples to extract for this block
            num_sample_block <- min(SAMPLE_BLOCK_SIZE, remaining_samples)
            
            # Generate random indices without replacement
            block_indices <- sample(remaining_samples, num_sample_block, replace = FALSE)
            
            # Extract the samples for this block
            block_samples <- replicated_samples[block_indices]
            
            # Remove the extracted samples from the remaining samples
            replicated_samples <- replicated_samples[-block_indices]
            
            # Update the remaining number of samples
            remaining_samples <- length(replicated_samples)
            
            # Store the block
            sample_blocks[[i]] <- block_samples
        }
        
        ##
        ## STEP 6: Generate blank blocks
        ##
        
        # Get the heading blanks
        heading_blanks <- head(replicated_blanks, input$user_seq_heading_blanks_n)
        replicated_blanks <- replicated_blanks[-(1:input$user_seq_heading_blanks_n)]
        
        # Get the tailing blanks
        tailing_blanks <- tail(replicated_blanks, input$user_seq_tailing_blanks_n)
        replicated_blanks <- replicated_blanks[-c((length(replicated_blanks) - input$user_seq_tailing_blanks_n + 1):length(replicated_blanks))]
        
        # Initialize a list to store the blocks of blanks
        blanks_blocks <- list()
        
        # Calculate the number of blocks needed
        num_blocks <- ceiling(length(replicated_blanks) / input$user_seq_intermediate_blanks_n)
        
        # Loop to create blocks of blanks
        for (i in 1:num_blocks) {
            # Calculate the start and end indices for this block
            start_index <- (i - 1) * input$user_seq_intermediate_blanks_n + 1
            end_index <- min(start_index + input$user_seq_intermediate_blanks_n - 1, length(replicated_blanks))
            
            # Extract the blanks for this block
            block_blanks <- replicated_blanks[start_index:end_index]
            
            # Store the block of blanks
            blanks_blocks[[i]] <- block_blanks
        }
        
        # Add heading blanks list at the beginning of the whites_blocks list
        blanks_blocks <- c(list(heading_blanks), blanks_blocks)
        
        # Add tailing blanks list at the end of the whites_blocks list
        blanks_blocks <- c(blanks_blocks, list(tailing_blanks))
        
        # save to global variables
        RV$blank_block_n = length(blanks_blocks)
        
        ##
        ## STEP 7: Merge blocks
        ##
        
        # Initialize the merged list
        merged_list <- list()
        
        # Determine the number of blocks
        num_blocks <- max(length(sample_blocks), length(blanks_blocks))
        
        # Loop through the blocks
        for (i in 1:num_blocks) {
            # Add the blank block if it exists
            if (i <= length(blanks_blocks)) {
                merged_list <- c(merged_list, blanks_blocks[[i]])
            }
            # Add the sample block if it exists
            if (i <= length(sample_blocks)) {
                merged_list <- c(merged_list, sample_blocks[[i]])
            }
        }
        
        merged_list = unlist(merged_list)
        
        ##
        ## STEP 8: Check sample blocks to not include replicates from the same sample
        ##
        
        # Initialize a vector to store duplicate check results
        has_duplicates <- logical(length(sample_blocks))
        
        # Iterate through the sample blocks and check for duplicates
        for (i in seq_along(sample_blocks)) {
            block <- sample_blocks[[i]]
            has_duplicates[i] <- check_duplicates(block)
        }
        
        # Check if any sample blocks have duplicates
        if (!any(has_duplicates)) {
            
            # Add injection suffix
            #for (i in 1:length(merged_list)) {
            #    merged_list[[i]] <- paste0(merged_list[[i]], "_inj", i)
            #}
            
            #merged_list.df <- as.data.frame(unlist(merged_list))
            #colnames(merged_list.df) <- "filename"
            
            # Format the result
            pattern = '(\\w+)_(\\d+)_(\\w+)_(\\w+)_(\\w+)_(\\w+)_(\\d+)'
            
            for(i in 1:length(merged_list)) {
                
                # Extract match information
                match_info <- str_match(merged_list[i], pattern)
        
                # Create an entry
                new_entry = data.frame(SampleType = "unknown",
                                       FileName = paste(match_info[1,3:8], collapse = "_"),
                                       Path = "to_fill",
                                       InstrumentMethod = match_info[1,4],
                                       Position = i,
                                       InjVol = "to_fill",
                                       stringsAsFactors = FALSE)
                
                # Add the new entry to the sequence_result_table
                RV$sequence_result_table = rbind(RV$sequence_result_table, new_entry)
                
            }
            
            # Ends the while loop if a solution is found
            break
            
        }
        
    } # end while
    
})

# RENDER sequence trials counter
output$sequence_trials_counter <- renderText({ 
    
    req(RV$sequence_trials)
    paste0("Number of iterations: ", RV$sequence_trials) 
    
})

# RENDER sequence total length
output$sequence_total_length <- renderText({ 
    
    req(RV$sequence_result_table)
    paste0("Total length of the sequence: ", dim(RV$sequence_result_table)[1])
    
})

# RENDER sequence total length
output$sample_block_info <- renderText({ 
    
    req(RV$sample_block_n)
    req(RV$sample_block_size)
    paste0("Considering your parameters, the sequence includes ", RV$sample_block_n, " blocks of size ", RV$sample_block_size, " (This correspond to user sample block size or optimal block size)")
    
})


# RENDER sequence info
output$blank_block_info <- renderText({ 
    
    req(RV$total_blank_n)
    req(input$selected_atom)
    paste0("Your sequence includes ", RV$total_blank_n, " blanks divided in ", RV$blank_block_n, " blocks ") 
    
})

# RENDER result sequence table
output$sequence_result_table <- DT::renderDataTable({
    
    req(RV$sequence_result_table)
    
    datatable(RV$sequence_result_table,
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












