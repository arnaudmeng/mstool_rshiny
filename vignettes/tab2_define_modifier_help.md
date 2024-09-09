#### _Have any feedback? If you have any questions, comments, or suggestions, feel free to contact me at arnaud.meng@pasteur.fr_

## **Requirements**

To be able to create/define a new *modifier*, mass list should have been upload in the ***Load mass list*** menu.

## **Defining a modifier**

To define a single *modifier*, you have to follow 2 steps: 

- Add a *brick* (atom or formula) of your desired *modifier*.
- When the *bricks* defining your *modifier* are all listed in the *modifier brick* table, click **Submit** 

Your *modifiers* will appear in the *modifier summary table*. 

Redo the previous steps to add more *modifiers* to be applied in further calculations.

## **Button functions**

### **Add a modifier brick** box

In the **Enter formula/atom** text box, enter an *atom symbol* or a *formula* in the text box. *Atom symbol* must follow the format of your mass list input table.

Using the **Count** numeric input, increase or decrease the number of atom(s) or compound(s) to be considered in your *brick*.

Use the **Gain/Lost status** selector to choose wether you want to consider a gain or a loss of the *atom*/*formula*.

Press the **Add** button to add a *brick* to the *bricks table*.

You can remove the last entry of the *bricks table* using the **Remove last** button.

### **Modifier bricks** box

This box displays the *brick(s)* you want to consider to build the *modifier*.

Use the **show** menu to inscrease the number of lines displayed in the view. 

You can copy to clipboard or save the table using the **Copy**, **CSV**, **Excel** or **PDF** buttons.

### **Submit your modifier** box

<span style="color:red">You have to enter the total charge to be applied (z in m/z) in the later calculations when applying your modifier to a compound</span>.

<span style="color:red">Note that the selected charge will applied the removal or the addition of the correct number of electron when computing a mass in the next menu</span>.

<span style="color:red">The electron removal/addition is not applied to the modifier !</span>

Once the bricks has been defined you can press the **Submit** button to save your *modifier*. The *modifier* will be added to the *Modifier table* to be use in later calculations.

You can also use the **Remove last** button to remove the last entry of the *modifier table*.

### **Modifier summary table** box

All previously defined *modifier(s)* will appear in this table.

<span style="color:blue"> **RelMass** corresponds to the relative mass to consider in the mass calulation when applying the modifier to a compound</span>. 

Use the **show** menu to inscrease the number of lines displayed in the view. 

You can copy to clipboard or save the table using the **Copy**, **CSV**, **Excel** or **PDF** buttons.
