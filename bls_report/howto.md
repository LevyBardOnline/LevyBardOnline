## How to read the tables: 

### Balance

Consider the following table:

| | CE<br>Interview |  CE<br>Diary | ATUS<br>Weekday | CE:Int &minus; ATUS | CE:Dia &minus; ATUS |
| -------------------- | :----------: | :----------: | :----------: | :----------: | :----------: |
| Var |              |              |              |              |              |
|  Var=1 | a1 | b1 | c1 | a1-c1 | b1-c1 |
|  Var=2 | a2 | b2 | c2 | a2-c2 | b2-c2 |
|  Var=3 | a3 | b3 | c3 | a3-c3 | b3-c3 |

This table shows the balance of the data, providing the distribution of individuals in the recipient (**CE's**) and donor sample (**ATUS**), across the groups defined by variable **Var**. 

For example, for Column 2, **a1, a2, a3** represent the share of individuals in the CE-Diary sample that are in group Var=1, var=2, and var=3, respectively. Similar for columns 3 and 4. 

Columns 5 and 6 are used to quantify the balance of the data, comparing the distribution of individuals in the CE sample with the distribution of individuals in the ATUS sample. If the data were perfectly balance, we should expect to see zeros in these columns.

### Distribution Statistics

Consider the following table:


|                      | CE<br>Interview |  CE<br>Diary | ATUS<br>Weekday | CE:Int<br>%ATUS | CE:Dia<br>%ATUS |
| -------------------- | :----------: | :----------: | :----------: | :----------: | :----------: |
| Var       |              |              |              |              |              |
| Var=1 | a1 | b1 | c1 | a1/c1 x 100 | b1/c1 x 100 |
| Var=2 | a2 | b2 | c2 | a2/c2 x 100| b2/c2 x 100 |        
| Var=3 | a3 | b3 | c3 | a3/c3 x 100| b3/c3 x 100 |        

This tables aims to provide a snapshot of the distribution of the variable **Hours of household production** in the CE and ATUS samples, across the groups defined by variable **Var**.

For example, **a1** represents the (imputed) **average** number of hours of household production that individuals in group Var=1 do in the CE-Interview sample. **c1** represents the (observed) **average** number of hours of household production that individuals in group Var=1 do in the ATUS sample. As part of the different "tabs", we also present information for the  ***median*** and ***standard deviation*** as the distributional statistics.

The columns 5 and 6 are used to quantify the differences in the distribution of the variable **Hours of household production** in the CE samples, compared to the ATUS. We use the Ratio between the imputed (CE) and observed (ATUS) statistics. If the data were perfectly balance, we should expect to see 100 in these columns. 


