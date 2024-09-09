#### _Have any feedback? If you have any questions, comments, or suggestions, feel free to contact me at arnaud.meng@pasteur.fr_

## **Requirements**

This function handles .mgf file only. Your file must follow the MGF format:

e.g.

    PEPMASS=
    RTINSECONDS=
    CHARGE=
    MSLEVEL=
    COLLISION_ENERGY=
    SOURCE_INSTRUMENT=
    FILENAME=
    IONMODE=
    ORGANISM=
    NAME=
    PI=
    DATACOLLECTOR=
    SMILES=
    INCHI=
    INCHIAUX=
    TITLE=
    MASS\tabINTENSITY
    MASS\tabINTENSITY
    MASS\tabINTENSITY
    END IONS

See the example file *8_mgf_reader_example_light.mgf* in the ***Demo folder***.

Note that separator should be tabulation

## **Button functions**

### **Select spectrum** box

Use **sliders** to define the precursor mass window (min and max) to reduce the number of spectrums.

You can click the **drop down menu** to select a spectrum and display its spectrum, details and raw values. This drop down menu is based on the MGF title field which must be unique for each spectrum.

### **Peak plot** box

This box allows to display the spectrum that has been selected in the above section. You can hover peaks to show the fragment information (m/z and intensity values).

### **Spectrum details** box

For the selected spectrum, displays the details of the other text MGF fields. 

### **Spectrum raw data** box

This is the datatable of the raw data used to plot the spectrum.