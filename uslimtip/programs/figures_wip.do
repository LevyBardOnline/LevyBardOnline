
cd "Users\aashimasin\Documents\GitHub\LevyBardOnline\uslimtip\resources"


*** Pages for Site


forvalues year = 2005/2023 {
    file open myfile using _`year'_balance_fig.qmd, write replace
********************************************************************************    
                	foreach i in sex race age_group empstat2 haschildren ych ntchild ntadult iscouple educ_tb faminc_q {

/*Include figures 
::{#fig-threshold}

![](resources/Tables/thrshold.png)

**Threshold of Weekly Hours of Household Production: 2022**

::: 
********************************************************************************             
    file close myfile
}
*/
                    file write myfile "##`fig_sm'" _n _n
                    
                    file write myfile "{{< include resources/y`year'/f`year'_`vmain'_`vsec'.md >}}" _n	
                    file write myfile ":Distribution Balance {#tbl-bal`year'_`vmain'_`vsec'}" _n _n                
                   
                }
            }
     } 
	 
	
  


forvalues year = 2005/2023 {
    file open myfile using _`year'_qm_fig.qmd, write replace
********************************************************************************    
            foreach vmain of global listv1 {
 
                file write myfile "## ${`vmain'}" _n _n                
                foreach vsec of global listv2 {
                    if "`vmain'"!="`vsec'" {
                        
                        if "`vsec'"!="none" local vdetlab ${`vmain'} x ${`vsec'}
                        else                local vdetlab ${`vmain'}                    
                        display "`vdetlab'"
                        file write myfile "### `vdetlab'" _n _n
                        
                        file write myfile "::: {.panel-tabset} " _n _n
                        
                        file write myfile "## Mean " _n _n
                        
                        file write myfile "{{< include resources/y`year'/mn`year'_`vmain'_`vsec'.md >}}" _n	
                        file write myfile ":Match Quality: Mean {#tbl-mn`year'_`vmain'_`vsec'}" _n _n  
              
                        
                        *file write myfile "{{< >}}" _n
                        file write myfile "## Median " _n _n
                        
                        file write myfile "{{< include resources/y`year'/md`year'_`vmain'_`vsec'.md >}}" _n	
                        file write myfile ":Match Quality: Median {#tbl-md`year'_`vmain'_`vsec'}" _n _n  
              
                        *file write myfile "{{< >}}" _n
                        file write myfile "## SD " _n _n
                        
                        file write myfile "{{< include resources/y`year'/sd`year'_`vmain'_`vsec'.md >}}" _n	
                        file write myfile ":Match Quality: Standard Deviation {#tbl-sd`year'_`vmain'_`vsec'}" _n _n  
                             
                        file write myfile "::: " _n _n
                        
                    }
                }
             } 
********************************************************************************             
    file close myfile
}
  


