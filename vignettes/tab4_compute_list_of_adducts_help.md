#### _Have any feedback? If you have any questions, comments, or suggestions, feel free to contact me at arnaud.meng@pasteur.fr_

## **Requirements**

To be able to compute multiple adduct masses, mass list should have been upload in the ***Load mass list*** menu and
*modifier(s)* must be added to the *modifiers table* using the ***Define modifier*** menu.

This function handles .txt, .csv or .tsv file only

Your file must follow the 2-columns format bellow prior to be loaded:
- MoleculeName
- Formula

See the example file *2_compute_list_of_adducts_example_file.txt* in the ***Demo folder***.

Note that separator should be: comma, semicolon or tab

## **Button functions**

### **Load file** box

Use the the **Browse** button to find your input file containing multiple formula.

Always check the **Header** button because the input file must satisfy the header format described above.

Select **Comma**, **Semicolon** or **Tab** depending on the separator in your input file.

### **Formula table** box

Displays the overview of your input formula table.

Use the **show** menu to inscrease the number of lines displayed in the view. 

Use the **Copy** button to copy to clipboard or **CSV**, **Excel** or **PDF** buttons to download the table.

### **Adduct table** box

Displays the resulting adduct masses for your list of formula.

<span style="color:blue"> **Mass** corresponds to the total mass of the original compound</span>. 

<span style="color:blue"> **RelMass** corresponds to the relative mass to consider in the mass calulation when applying the modifier to a compound</span>. 

<span style="color:blue"> **AdductMass** corresponds to the total mass of the adduct after application of the modifier to the original compound</span>. 

Use the **show** menu to inscrease the number of lines displayed in the view. 

Use the **Copy** button to copy to clipboard or **CSV**, **Excel** or **PDF** buttons to download the table.