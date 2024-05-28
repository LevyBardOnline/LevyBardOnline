cd "C:\Users\Fernando\Documents\GitHub\LevyBardOnline.github.io\uslimtip"



forvalues year = 2005/2023 {
    file open myfile using uslimtip`year'_bal.qmd, write replace
********************************************************************************    
    file write myfile "---" _n 
    file write myfile "title: ASEC-ATUS Balance" _n 
    file write myfile "subtitle: Year `year'" _n 
    file write myfile "---" _n  _n
    file write myfile "This page contains data evaluating the balance quality of data between ATUS " ///  
                      "(weekday and weekend) and ASEC."  _n _n ///
                      "This is done for various selected groups and their interactions" _n _n
    file write myfile "{{< include howto.md >}}" _n _n
    file write myfile "{{< include resources/_`year'_balance.qmd >}}" _n
                        
********************************************************************************             
    file close myfile
}
 
cd "C:\Users\Fernando\Documents\GitHub\LevyBardOnline.github.io\uslimtip"

 
forvalues year = 2005/2023 {
    file open myfile using uslimtip`year'_qm.qmd, write replace
********************************************************************************    
    file write myfile "---" _n 
    file write myfile "title: ASEC-ATUS Match Quality Statistics" _n 
    file write myfile "subtitle: Year `year'" _n 
    file write myfile "---" _n _n 
    file write myfile "This page contains data evaluating the Match quality of data between ATUS " ///  
                      "(weekday and weekend) and ASEC."  _n _n ///
                      "This is done by comparing the mean, median and Standard deviation for time " ///
                      "spent on household production for various selected groups and their interactions" _n _n
    file write myfile "{{< include howto.md >}}" _n _n
    file write myfile "{{< include resources/_`year'_qm.qmd >}}" _n
                        
********************************************************************************             
    file close myfile
}
 
cd "C:\Users\Fernando\Documents\GitHub\LevyBardOnline.github.io"

file open myfile using uslimtip.qmd, write replace
file write myfile "---" _n 
file write myfile "title: LIMTIP-US - Online Tables and Figures"_n
file write myfile "---" _n 
file write myfile "This is site provides access to tables and figures that can be used to evaluate the Matching Quality of the Statistical matching performed between ASEC and ATUS for multiple years." _n _n  
file write myfile "This is organized by year." _n _n

forvalues year = 2005/2023 {
file write myfile "## Year `year'" _n _n
file write myfile "### Balance " _n _n
file write myfile "* [Tables](uslimtip/uslimtip`year'_bal.qmd) " _n 
file write myfile "* Figures " _n _n
file write myfile "### Match Quality " _n _n
file write myfile "* [Tables](uslimtip/uslimtip`year'_mq.qmd) " _n 
file write myfile "* Figures " _n _n
}
file close myfile

