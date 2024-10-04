# mstool_rshiny

This tool has been developped for the needs of mass chemists working at the [Metabolomic Core Facility](https://research.pasteur.fr/en/team/metabolomics-core-facility/) of Pasteur Institute (Paris). 
All functions and utilities embedded resulted from the collaboration of mass spectrometry expert (Kathleen Rousseau), chemist expert (Lise Boulard) and bioinformatic expert (Arnaud Meng).

More description about the functions implemented in the tool will come soon.

> [!CAUTION]
> This project is still under developpment.

## Help vignettes for application sections

[page 1 - load atom mass table](vignettes/tab1_load_mass_data_help.md)
[page 2 - define modifier](vignettes/tab2_define_modifier_help.md)
[page 3 - compute compound mass](vignettes/tab3_work_formula_help.md)
[page 4 - compute adduct mass list](vignettes/tab4_compute_list_of_adducts_help.md)
[page 5 - predict formula from mass](vignettes/tab5_predict_formula_from_mass_help.md)
[page 6 - generate compond pools from mass](vignettes/tab6_generate_mass_pools_help.md)
[page 7 - build analytic chemical sequence for mass spectrometry](vignettes/tab7_build_sequence_help.md)
[page 8 - MGF spectrum vizualizer](vignettes/tab8_mgf_reader_help.md)

## Prerequisited packages

- library(shiny)
- library(shinydashboard)
- library(shinyBS)
- library(shinyalert)
- library(shinyjs)
- library(markdown)
- library(DT)
- library(tidyverse)
- library(dplyr)
- library(stringr)
- library(stringi)
- library(httr)
- library(ggplot2)
- library(ggpmisc)
- library(plotly)
- library(ggpubr)
- library(magrittr)
- library(ptable)

## How to

Simply open the "app.R" in Rstudio then click "Run App"

Or

In command line, do:
```
runApp("app.R")`
```

## Contact

[Arnaud Meng](https://research.pasteur.fr/en/member/arnaud-meng/), PhD, Institut Pasteur, Paris, FR
