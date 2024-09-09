#### _Have any feedback? If you have any questions, comments, or suggestions, feel free to contact me at arnaud.meng@pasteur.fr_

## **Requirements**

This function handles .txt, .csv or .tsv file only

Your file must follow the 3-columns format bellow prior to be loaded:
- Element
- Symbol
- Mass

See the example file *1_load_mass_list_example_file.txt* in the ***Demo folder***.

Note that separator should be: comma, semicolon or tab

## **Button functions**

### **Load file** box

Use the the **Browse** button to find your input file containing element masses.

Always check the **Header** button because the input file must satisfy the header format described above.

Select **Comma**, **Semicolon** or **Tab** depending on the separator in your input file.

### **Shiny parameters** box

You can select the number of digits to be displayed bu setting the **Digits to show** parameter.

Use **Electron mass** input box to modify the electron mass that is use in calulations if needed.

### **Mass table** box

Displays the overview of your input mass table.

Use the **show** menu to inscrease the number of lines displayed in the view. 

Use the **Copy** button to copy to clipboard or **CSV**, **Excel** or **PDF** buttons to download the table.
