
# Function to read the file with the specified parameters
read_file_mgf <- function(file_path) {
  
     req(file_path)
     ext <- tools::file_ext(file_path)
     validate(need(ext %in% c("mgf"), "Please upload a .mgf file"))
      
     if (file.info(file_path)$size != 0) {
         # Read the file content
         file_content <- readLines(file_path)
         return(file_content)
     }
     
     return(0)
  
}

# Function to parse the MGF file and return a list of spectrums
parse_mgf_file <- function(file_path) {
    
    req(file_path)
    ext <- tools::file_ext(file_path)
    validate(need(ext %in% c("mgf"), "Please upload a .mgf file"))
    
    if (file.info(file_path)$size != 0) {
        
        file_content <- readLines(file_path)
        spectrums <- list()
        spectrum <- list()
        inside_ions_block <- FALSE
        title <- ""
        
        for (line in file_content) {
            if (grepl("^BEGIN IONS", line)) {
                inside_ions_block <- TRUE
                spectrum <- list(peaks = list())
            } else if (grepl("^END IONS", line)) {
                inside_ions_block <- FALSE
                if (!is.null(title) && title != "") {
                    spectrums[[title]] <- spectrum
                }
            } else if (inside_ions_block) {
                if (grepl("=", line)) {
                    key_value <- strsplit(line, "=")[[1]]
                    key <- key_value[1]
                    value <- key_value[2]
                    spectrum[[key]] <- value
                    if (key == "TITLE") {
                        title <- value
                    }
                } else {
                    peak <- strsplit(line, "\t")[[1]]
                    spectrum$peaks <- append(spectrum$peaks, list(list(mz = as.numeric(peak[1]), intensity = as.numeric(peak[2]))))
                }
            }
        }
        return(spectrums)
    }
    return(list())
}

# OBSERVE changes for mgf_file
observeEvent(input$mgf_file, {
  
    # Read MGF file
    mgf_file = read_file_mgf(input$mgf_file$datapath)

    # Count the number of spectrums by counting "BEGIN IONS" occurrences
    RV$mgf_spectrum_count <- sum(grepl("^BEGIN IONS", mgf_file))
    
    # Count the number of MS1 spectrums
    RV$mgf_ms1_count <- sum(grepl("^MSLEVEL=1", mgf_file))
    
    # Count the number of MS2 spectrums
    RV$mgf_ms2_count <- sum(grepl("^MSLEVEL=2", mgf_file))
    
    # Parse MGF file and store in reactive values
    RV$mgf_data <- parse_mgf_file(input$mgf_file$datapath)
    
    # Update slider range based on the mz values in the data
    if (length(RV$mgf_data) > 0) {
      
      # Compute min and max mz values
      all_precursor_mz <- unlist(lapply(RV$mgf_data, function(s) as.numeric(s$PEPMASS)))
      min_mz <- min(all_precursor_mz, na.rm = TRUE)-1
      max_mz <- max(all_precursor_mz+1, na.rm = TRUE)+1
      
      # Update slider input
      digits <- input$shiny_param_digits
      
      updateSliderInput(session, "mz_range",
                        min = round(min_mz, digits = digits),
                        max = round(max_mz, digits = digits),
                        value = c(round(min_mz, digits = digits), round(max_mz, digits = digits)),
                        step = 10^(-digits))  # Step size based on the number of digits
      
    }
    
})


# OBSERVE changes for selected title
observeEvent(input$selected_title, {
    
    req(RV$mgf_data)
    RV$selected_spectrum <- RV$mgf_data[[input$selected_title]]
    
})

# RENDER number of spectrum in MGF
output$mgf_file_nb_spectrums <- renderValueBox({
    
    req(RV$mgf_spectrum_count)
    
    valueBox(
        RV$mgf_spectrum_count, "Total number of spectrums", icon = icon("signal"),
        color = "blue"
    )
    
})

# RENDER number of spectrum in MGF
output$mgf_file_ms1ms2_count <- renderValueBox({
    
    req(RV$mgf_ms1_count)
    req(RV$mgf_ms2_count)
    
    string = paste0(RV$mgf_ms1_count, " / ", RV$mgf_ms2_count)
    
    valueBox(
        string, "#MS1/#MS2", icon = icon("mountain-sun"),
        color = "blue"
    )
    
})

# FILTER spectrum titles based on m/z range
filtered_titles <- reactive({
  
  req(RV$mgf_data)
  
  mz_range <- input$mz_range
  
  filtered <- sapply(RV$mgf_data, function(spectrum) {
    
    precursor_mz <- as.numeric(spectrum$PEPMASS)
    (precursor_mz >= mz_range[1]) & (precursor_mz <= mz_range[2])
    
  })
  
  names(RV$mgf_data)[filtered]
  
})

# UPDATE spectrum dropdown menu
observe({
  
  updateSelectInput(session, "spectrum_title", choices = filtered_titles())
  
})

# OBSERVE changes for spectrum_title
observeEvent(input$spectrum_title, {
  
  req(RV$mgf_data)
  RV$selected_spectrum <- RV$mgf_data[[input$spectrum_title]]
  
})

# RENDER selected spectrum details
output$selected_spectrum_details <- renderTable({
    
    req(RV$selected_spectrum)
    spectrum <- RV$selected_spectrum
    
    # Create a data frame for spectrum details excluding title and peaks
    details <- data.frame(
        Parameter = names(spectrum)[!(names(spectrum) %in% c("TITLE", "peaks"))],
        Value = unlist(spectrum[!(names(spectrum) %in% c("TITLE", "peaks"))]),
        stringsAsFactors = FALSE
    )
    
    return(details)
})

# RENDER spectrum raw table
output$selected_spectrum_table <- DT::renderDataTable({
  
  req(RV$selected_spectrum)
  
  tab = do.call(rbind, lapply(RV$selected_spectrum$peaks, as.data.frame))
  
  # adjust table with the number of digits
  tab$mz = round(tab$mz, digits = input$shiny_param_digits)
  tab$intensity = round(tab$intensity, digits = input$shiny_param_digits)
  
  datatable(tab,
            filter = "top",
            selection = "single",
            rownames = FALSE,
            extensions = 'Buttons',
            options = list(autoWidth = FALSE,
                           Server = FALSE,
                           dom = 'lBfrtip',
                           scrollX = FALSE,
                           buttons = c('copy', 'csv', 'excel', 'pdf'),
                           fixedColumns = TRUE, 
                           lengthMenu = list(c(10, 25, 50, 100, -1), c('10', '25', '50', '100', 'All'))) 
  )
  
})

# RENDER selected spectrum peaks plot
output$peaks_plot <- renderPlotly({
  
  req(RV$selected_spectrum)
  
  peaks <- do.call(rbind, lapply(RV$selected_spectrum$peaks, as.data.frame))
  colnames(peaks) <- c("mz", "intensity")
  
  precursor_mz <- as.numeric(RV$selected_spectrum$PEPMASS)
  
  if (nrow(peaks) == 1) {
    selected_mz <- peaks$mz
    x_min <- selected_mz - 100
    x_max <- selected_mz + 100
  } else {
    x_min <- max(0, min(peaks$mz) - 100)
    x_max <- max(peaks$mz) + 100
  }
  
  peaks$color <- ifelse(peaks$mz == precursor_mz, "blue", "gray")
  peaks$color <- ifelse(peaks$mz == precursor_mz, "Precursor", "Fragment")
  
  p <- ggplot(peaks, aes(x = mz, y = intensity, fill = color)) +
    geom_bar(stat = "identity", width = 1) +
    geom_point(aes(x = mz, y = intensity), color = "red", size = 2) +
    geom_text(aes(x = mz, y = intensity + (0.1 * max(intensity)), label = round(mz, 2)), vjust = -0.5, size = 3, color = "black") +
    labs(x = "m/z", y = "Intensity", fill = "Peak Type") +
    xlim(x_min, x_max) +
    scale_fill_manual(values = c("Fragment" = "gray", "Precursor" = "blue")) +
    theme_minimal()
  
  ggplotly(p)
  
})





