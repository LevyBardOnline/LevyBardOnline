
cd "/Users/aashimasinha/Documents/GitHub/LevyBardOnline.github.io/uslimtip/"


forvalues year = 2005/2023 {
    file open myfile using uslimtip`year'_bal_fig.qmd, write replace
********************************************************************************    
    file write myfile "---" _n 
    file write myfile "title: ASEC-ATUS Balance" _n 
    file write myfile "subtitle: Year `year'" _n 
    file write myfile "---" _n  _n
    file write myfile "This page contains bar charts presenting the balance quality of data between ATUS " ///  
                      "(weekday and weekend) and ASEC."  _n _n ///
                      "This is done for main selected variables" _n _n
    file write myfile "{{< include howto.md >}}" _n _n
    file write myfile "{{< include resources/_`year'_bal_fig.qmd >}}" _n
                        
********************************************************************************             
    file close myfile
}
 
*cd "/Users/aashimasinha/Documents/GitHub/LevyBardOnline.github.io/uslimtip/"

 
forvalues year = 2005/2023 {
    file open myfile using uslimtip`year'_qm_fig.qmd, write replace
********************************************************************************    
    file write myfile "---" _n 
    file write myfile "title: ASEC-ATUS Match Quality Statistics" _n 
    file write myfile "subtitle: Year `year'" _n 
    file write myfile "---" _n _n 
    file write myfile "This page contains Box plots evaluating Statistical Match quality between ATUS " ///  
                      "(weekday and weekend) and ASEC data."  _n _n ///
                      "This is done by comparing the distribution of total daily time spent on household production. " ///
                      "We present the figures for the main strata group (sex has children and employment status) and for various selected variables." _n _n
    file write myfile "{{< include howto.md >}}" _n _n
    file write myfile "{{< include resources/_`year'_qm_fig.qmd >}}" _n
                        
********************************************************************************             
    file close myfile
}
 

