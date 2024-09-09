#### _Have any feedback? If you have any questions, comments, or suggestions, feel free to contact me at arnaud.meng@pasteur.fr_

## **Requirements**

This function handles .txt, .csv or .tsv file only

Your file must follow the N-columns (1 compound per line, N forms of he compound in column) format bellow prior to be loaded:
- compound 1 ID, compound 1 form 1 mass, compound 1 form 2 mass, ...
- compound 2 ID, compound 2 form 1 mass, compound 2 form 2 mass, ...

See the example file *4_generate_mass_pools_example_file.csv* in the ***Demo folder***.

Note that separator should be: comma, semicolon or tab

## **Algorithm**

- With the file containing 1 compound per line, create N (desired number of pools) pools by randomly dispatching lines in N dataframes. 
- For each dataframes, check that no mass are similar (including the mass tolerance parameter). If the dataframe pass the check, remove the lines from the input data, if not: delete the the dataframe.
- Redo the previous step with N = N - number of pools that passed the check until N = 1
- When N = 1, take the first line among the remaining lines from the input data, and try to add it to the first pool dataframe. Check if the resulting pool dataframe pass the check, if yes, keep the new pool and remove the line from the remaining lines in input data. If not, try to add the line to the second pool dataframe, etc.
- Do it until the remaining lines from input data = 0. 
- If impossible, redo the process from the begining.

## **Button functions**

### **Load file** box

Use the the **Browse** button to find your input file.

Always check the **Header** button because the input file must satisfy the header format described above.

Select **Comma**, **Semicolon** or **Tab** depending on the separator in your input file.

### **Mass to pool** box

Displays the input table.

Use the **show** menu to inscrease the number of lines displayed in the view. 

You can copy to clipboard or save the table using the **Copy**, **CSV**, **Excel** or **PDF** buttons.

### **Pool parameters** box

Use the **Number of pools** numeric input to defined the desired number of final pools.

The **Enter a mass tolerance** text box allows to user to defined the mass tolerance to be considered for to compound to be in the same pool.

**Maximum optimization iterations** is a parameter setting the maximumn number of iterations for the calculation to find a set of pools all satisfying the mass tolerance parameter. 
If no pool can be find in the number of iteration. The function return a empty table.

The **Maximum pooling iterations** parameter is the maximum number of iterations for the algorithm to try adding all input lines in different pools. 
If some lines cannot be added to a pool, they are added to a final pool not satisfying the mass tolerance parameter.

### **Pooling information** box

Displays 3 information on the relsuting pools:
- The total number of pools
- The pool size range
- The ID of the smallest and the largest pools

### **Pool result** box

The resulting pools are showed in this table. 

<span style="color:blue"> **Pool_index** corresponds to the pool resulting pool IDs</span>. 

Use the **show** menu to inscrease the number of lines displayed in the view. 

You can copy to clipboard or save the table using the **Copy**, **CSV**, **Excel** or **PDF** buttons.