
cd "Users\aashimasin\Documents\GitHub\LevyBardOnline\uslimtip\resources"
		label define age_group 1 "15/24" 2 "25/39" 3 "40/54" 4 "55/64" 5 "65+", replace
        label define educ_tb 1 "Less than HS" 2 "HighSchool"  3 "Some College" 4 "College+",  replace
        label define empstat2 0 "Not Employed" 1 "Employed",  replace
        label define faminc_q 1 "Less than $30k" 2 "$30k-$50k" 3 "$50k-$75k" 4 "$75k-$150k" 5 "$150k and over",  replace
        label define iscouple 0 "Single Headed HH" 1 "Couple Headed HH",  replace
        label define ntadult 3 "3+",  replace
        label define ntchild 3 "3+",  replace
        label define race 1 "White" 2 "Black" 3 "Hispanic" 4 "Other",  replace
        label define sex 1 "Men" 2 "Women",  replace
        label define ych 0 "No young Child" 1 "Young Child present"  ,  replace 
		label define haschildren 0 "No children" 1 "Child(ren) present"  ,  replace 

		label values age_group  age_group
		label values educ_tb  educ_tb
		label values empstat2 empstat2 
		label values faminc_q faminc_q
		label values iscouple iscouple
		label values ntadult ntadult
		label values ntchild ntchild
		label values race race
		label values sex sex
		label values ych ych
		label values haschildren haschildren

        global age_group  "Age Group"
        global educ_tb    "Education"
        global employed   "Employed Status"
        global faminc_q   "Family Income"
        global iscouple   "Couple"
        global ntadult    "# Adults"
        global ntchild    "# Children"
        global race       "Race"
        global sex        "Gender"
        global ych        "Young Child"
        *global haschildren "Children in HH"
forvalues year = 2005/2023 {
    file open myfile using _`year'_qm_fig.qmd, write replace
********************************************************************************    
            foreach vmain in race age_group empstat2 ych ntchild ntadult iscouple educ_tb faminc_q {
 
                file write myfile "## ${`vmain'}" _n _n                
                
                        file write myfile "### Weekend " _n _n   
                        ///////////////////////////////////////////////////////////////////////////////
                        file write myfile "::: {.panel-tabset} " _n _n
                        
                        file write myfile "## Overall " _n _n                        
                        file write myfile "![](resources/y`year'/wkend_`vmain'.png)" _n	
                        file write myfile " **Box Plot** Time on Household Production {#tbl-`year'_`vmain'_o_end}" _n _n  
                        
                        file write myfile "## Men" _n _n
                        
                        file write myfile "![](resources/y`year'/mwkend_`vmain'.png)" _n	
                        file write myfile " **Box Plot** Time on Household Production {#tbl-`year'_`vmain'_m_end}" _n _n  
              
                        *file write myfile "{{< >}}" _n
                        file write myfile "## Women " _n _n
                        
                        file write myfile "![](resources/y`year'/fwkend_`vmain'.png)" _n	
                        file write myfile " **Box Plot** Time on Household Production {#tbl-`year'_`vmain'_w_end}" _n _n  
                             
                        file write myfile "::: " _n _n
                        ///////////////////////////////////////////////////////////////////////////////
                        file write myfile "### Weekday " _n _n                    
                        
                        file write myfile "::: {.panel-tabset} " _n _n
                        
                        file write myfile "## Overall " _n _n                        
                        file write myfile "![](resources/y`year'/wkday_`vmain'.png)" _n	
                        file write myfile " **Box Plot** Time on Household Production {#tbl-`year'_`vmain'_o_day}" _n _n  
                                      
                        *file write myfile "{{< >}}" _n
                        file write myfile "## Men" _n _n
                        
                        file write myfile "![](resources/y`year'/mwkday_`vmain'.png)" _n	
                        file write myfile " **Box Plot** Time on Household Production {#tbl-`year'_`vmain'_m_day}" _n _n  
              
                        *file write myfile "{{< >}}" _n
                        file write myfile "## Women " _n _n
                        
                        file write myfile "![](resources/y`year'/fwkday_`vmain'.png)" _n	
                        file write myfile " **Box Plot** Time on Household Production {#tbl-`year'_`vmain'_w_day}" _n _n  
                             
                        file write myfile "::: " _n _n
                        ///////////////////////////////////////////////////////////////////////////////
                }           
********************************************************************************             
    file close myfile
}
  


