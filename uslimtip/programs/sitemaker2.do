cd "Users\aashimasin\Documents\GitHub\LevyBardOnline.github.io\uslimtip"



forvalues year = 2005/2023 {
    file open myfile using uslimtip`year'_bal_fig.qmd, write replace
********************************************************************************    
    file write myfile "---" _n 
    file write myfile "title: ASEC-ATUS Balance" _n 
    file write myfile "subtitle: Year `year'" _n 
    file write myfile "---" _n  _n
    file write myfile "This page contains figures presenting the balance quality of data between ATUS " ///  
                      "(weekday and weekend) and ASEC."  _n _n ///
                      "This is done for various selected groups and their interactions" _n _n
    file write myfile "{{< include howto.md >}}" _n _n
    file write myfile "{{< include resources/_`year'_balance_fig.qmd >}}" _n
                        
********************************************************************************             
    file close myfile
}
 
cd "Users\aashimasin\Documents\GitHub\LevyBardOnline.github.io\uslimtip"

 
forvalues year = 2005/2023 {
    file open myfile using uslimtip`year'_qm_fig.qmd, write replace
********************************************************************************    
    file write myfile "---" _n 
    file write myfile "title: ASEC-ATUS Match Quality Statistics" _n 
    file write myfile "subtitle: Year `year'" _n 
    file write myfile "---" _n _n 
    file write myfile "This page contains figures presenting the Match quality of data between ATUS " ///  
                      "(weekday and weekend) and ASEC."  _n _n ///
                      "This is done by comparing the mean for time " ///
                      "spent on household production for various selected groups and the interaction of the strata variables (sex has children and employment status)" _n _n
    file write myfile "{{< include howto.md >}}" _n _n
    file write myfile "{{< include resources/_`year'_qm_fig.qmd >}}" _n
                        
********************************************************************************             
    file close myfile
}
 

