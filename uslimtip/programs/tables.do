*** Add PRocess
forvalues i = 2005 / 2023 {
     use "C:\Users\Fernando\Documents\GitHub\uslimtipqm\procdata\qtable_`i'.dta" , clear
    gen id = _n
    expand 2 if end_r_nm!="none"
    bysort id:gen t = _n
    drop2 aux
    gen aux = end_r_eq
    replace end_r_eq = end_r_nm  if t==2
    replace end_r_nm  = aux if t==2
    drop2 aux
    gen aux = end_d_vi
    replace end_d_vi = end_d_vj  if t==2
    replace end_d_vj = aux if t==2
    drop id t
    save "C:\Users\Fernando\Documents\GitHub\uslimtipqm\procdata\qtable_`i'.dta" , replace 
}

forvalues i = 2005 / 2023 {
    use "C:\Users\Fernando\Documents\GitHub\uslimtipqm\procdata\qtable_`i'.dta" , clear
    drop2 cd*
    encode2 end_r_eq end_r_nm, prefix(cd)
    replace cdend_r_nm = 0 if cdend_r_nm==6
    ren (end_r_eq end_r_nm cdend_r_eq cdend_r_nm ) (ovar1 ovar2 rcvar1 rcvar2)
    sort ovar1 ovar2 rcvar1 rcvar2
    drop2 *_eq *_nm
    save "C:\Users\Fernando\Documents\GitHub\uslimtipqm\procdata\qtable_`i'.dta" , replace 
}

forvalues i = 2005 / 2023 {
    use "C:\Users\Fernando\Documents\GitHub\uslimtipqm\procdata\qtable_`i'.dta" , clear
        foreach j in end_r_wn end_d_wn day_r_wn day_d_wn {
            drop2 twgt       
            bysort ovar1 ovar2:egen double twgt = sum(`j')    
            replace `j'=`j'/twgt*100
        }
 
    
    save "C:\Users\Fernando\Documents\GitHub\uslimtipqm\procdata\qtable_`i'.dta" , replace 
}


********************************************************************************
********************************************************************************
cd "C:\Users\Fernando\Documents\GitHub\uslimtipqm\resources"

*** Balance

forvalues year = 2005/2023 {
        capture mkdir y`year'
        use "C:\Users\Fernando\Documents\GitHub\uslimtipqm\procdata\qtable_`year'.dta" , clear

        ** Create locals for all variables
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

        label define age_group 1 "15/24" 2 "25/39" 3 "40/54" 4 "55/64" 5 "65+"
        label define educ_tb 1 "Less than HS" 2 "HighSchool"  3 "Some College" 4 "College+"
        label define employed 0 "Not Employed" 1 "Employed"
        label define faminc_q 1 "Less than $30k" 2 "$30k-$50k" 3 "$50k-$75k" 4 "$75k-$150k" 5 "$150k and over"
        label define iscouple 0 "Single Headed HH" 1 "Couple Headed HH"
        label define ntadult 3 "3+"
        label define ntchild 2 "2+"
        label define race 1 "White" 2 "Black" 3 "Hispanic" 4 "Other"
        label define sex 1 "Men" 2 "Women"
        label define ych 0 "No young Child" 1 "Young Child present"       

        foreach ii  of global listv1 {
            display "`ii'"
            tab end_d_vi if ovar1 == "`ii'"
        }

        global listv1  sex  employed ych iscouple race educ_tb   age_group ntchild  ntadult faminc_q 
        global listv2 none  $listv1 

        list end_r_wn end_d_wn day_d_wn if ovar1 == "sex" & ovar2 == "employed"
        gen byte vaux = .
        gen byte vaux2 = .
        sort ovar1 ovar2   end_d_vi end_d_vj

        by ovar1 ovar2: gen allg=_n

        foreach ii  of global listv1 {
            foreach jj  of global listv2 {
                if "`jj'"!="`ii'" {
                    ******
                    drop2 sel
                    gen sel = (ovar1=="`ii'") & (ovar2=="`jj'")
                    mata:mtx = st_data(.,"end_r_wn end_d_wn day_d_wn","sel")
                    mata:val = st_data(.,"end_d_vi end_d_vj","sel")
                    mata:mtx = mtx,mtx[,1]:-mtx[,(2,3)];mtx
                    mata:st_matrix("mtx",mtx)
                    display in w "`ii':`jj'"
                    matrix colname mtx = "ASEC" "ATUS-Wend" "ATUS-Wday" "Gap-Wend" "Gap-day"
                    if "`jj'"!="none" label var vaux "${`ii'} x ${`jj'}"
                    else              label var vaux "${`ii'}" 
                    levelsof allg     if sel==1, local(vallg)
         
                    local vrow
                    capture label drop allg
                    foreach k of local vallg {
                        local vrow `vrow' `k'.allg
                        sum end_d_vi if sel == 1 & allg == `k', meanonly
                        local ki = r(mean)
                        sum end_d_vj if sel == 1 & allg == `k', meanonly
                        local kj = r(mean)
                        if "`jj'"!="none" label define allg `k' "&nbsp;&nbsp;`:label `ii' `ki'' x `:label `jj' `kj''", modify
                        else              label define allg `k' "&nbsp;&nbsp;`:label `ii' `ki''" , modify                
                        
                    }
                    label values allg allg 
                    matrix roweq   mtx = vaux
                    matrix rowname   mtx = `vrow'
                    
                    esttab matrix(mtx, fmt(2)) using y`year'/f`year'_`ii'_`jj' ///
                        , md label nomtitle replace              
                         
                }           
            }
        }

}



forvalues year = 2005/2023 {
        capture mkdir y`year'
        use "C:\Users\Fernando\Documents\GitHub\uslimtipqm\procdata\qtable_`year'.dta" , clear

        ** Create locals for all variables
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

        label define age_group 1 "15/24" 2 "25/39" 3 "40/54" 4 "55/64" 5 "65+"
        label define educ_tb 1 "Less than HS" 2 "HighSchool"  3 "Some College" 4 "College+"
        label define employed 0 "Not Employed" 1 "Employed"
        label define faminc_q 1 "Less than $30k" 2 "$30k-$50k" 3 "$50k-$75k" 4 "$75k-$150k" 5 "$150k and over"
        label define iscouple 0 "Single Headed HH" 1 "Couple Headed HH"
        label define ntadult 3 "3+"
        label define ntchild 2 "2+"
        label define race 1 "White" 2 "Black" 3 "Hispanic" 4 "Other"
        label define sex 1 "Men" 2 "Women"
        label define ych 0 "No young Child" 1 "Young Child present"       

        foreach ii  of global listv1 {
            display "`ii'"
            tab end_d_vi if ovar1 == "`ii'"
        }

        global listv1  sex  employed ych iscouple race educ_tb   age_group ntchild  ntadult faminc_q 
        global listv2 none  $listv1 

        list end_r_wn end_d_wn day_d_wn if ovar1 == "sex" & ovar2 == "employed"
        gen byte vaux = .
        gen byte vaux2 = .
        sort ovar1 ovar2   end_d_vi end_d_vj

        by ovar1 ovar2: gen allg=_n

        foreach ii  of global listv1 {
            foreach jj  of global listv2 {
                if "`jj'"!="`ii'" {
                    ******
                    drop2 sel
                    gen sel = (ovar1=="`ii'") & (ovar2=="`jj'")
                    mata:mtx1 = st_data(.,"end_d_mean   end_r_mean   day_d_mean   day_r_mean  ","sel")
                    mata:mtx2 = st_data(.,"end_d_median end_r_median day_d_median day_r_median","sel")
                    mata:mtx3 = st_data(.,"end_d_sd     end_r_sd     day_d_sd     day_r_sd    ","sel")
                    
                    mata:mtx1 = mtx1[,1],mtx1[,2]-mtx1[,1],mtx1[,3],mtx1[,4]-mtx1[,3]
                    mata:mtx2 = mtx2[,1],mtx2[,2]-mtx2[,1],mtx2[,3],mtx2[,4]-mtx2[,3]
                    mata:mtx3 = mtx3[,1],mtx3[,2]-mtx3[,1],mtx3[,3],mtx3[,4]-mtx3[,3]
                    
                    mata:val = st_data(.,"end_d_vi end_d_vj","sel")
                    
                    mata:st_matrix("mtx1",mtx1)
                    mata:st_matrix("mtx2",mtx2)
                    mata:st_matrix("mtx3",mtx3)
                    display in w "`ii':`jj'"
                    matrix colname mtx1 = "ATUS-Wend" "ASEC-Gap" "ATUS-Wday" "ASEC-Gap"
                    matrix colname mtx2 = "ATUS-Wend" "ASEC-Gap" "ATUS-Wday" "ASEC-Gap"
                    matrix colname mtx3 = "ATUS-Wend" "ASEC-Gap" "ATUS-Wday" "ASEC-Gap"
                    if "`jj'"!="none" label var vaux "${`ii'} x ${`jj'}"
                    else              label var vaux "${`ii'}" 
                    levelsof allg     if sel==1, local(vallg)
         
                    local vrow
                    capture label drop allg
                    foreach k of local vallg {
                        local vrow `vrow' `k'.allg
                        sum end_d_vi if sel == 1 & allg == `k', meanonly
                        local ki = r(mean)
                        sum end_d_vj if sel == 1 & allg == `k', meanonly
                        local kj = r(mean)
                        if "`jj'"!="none" label define allg `k' "&nbsp;&nbsp;`:label `ii' `ki'' x `:label `jj' `kj''", modify
                        else              label define allg `k' "&nbsp;&nbsp;`:label `ii' `ki''" , modify                
                        
                    }
                    label values allg allg 
                    matrix roweq   mtx1 = vaux
                    matrix rowname   mtx1 = `vrow'
                    matrix roweq   mtx2 = vaux
                    matrix rowname   mtx2 = `vrow'
                    matrix roweq   mtx3 = vaux
                    matrix rowname   mtx3 = `vrow'
                    
                    esttab matrix(mtx1, fmt(2)) using y`year'/mn`year'_`ii'_`jj' ///
                        , md label nomtitle replace              
                    
                    esttab matrix(mtx2, fmt(2)) using y`year'/md`year'_`ii'_`jj' ///
                        , md label nomtitle replace
                        
                    esttab matrix(mtx3, fmt(2)) using y`year'/sd`year'_`ii'_`jj' ///
                        , md label nomtitle replace    
                }           
            }
        }

}


*** Pages for Site


forvalues year = 2005/2023 {
    file open myfile using _`year'_balance.qmd, write replace
********************************************************************************    
    foreach vmain of global listv1 {
            file write myfile "## ${`vmain'}" _n _n
            foreach vsec of global listv2 {
                if "`vmain'"!="`vsec'" {        
                    if "`vsec'"!="none" local vdetlab ${`vmain'} x ${`vsec'}
                    else                local vdetlab ${`vmain'}                    
                    display "`vdetlab'"
                    file write myfile "### `vdetlab'" _n _n
                    
                    file write myfile "{{< include resources/y`year'/f`year'_`vmain'_`vsec'.md >}}" _n	
                    file write myfile ":Distribution Balance {#tbl-bal`year'_`vmain'_`vsec'}" _n _n                
                   
                }
            }
     } 
********************************************************************************             
    file close myfile
}
  


forvalues year = 2005/2023 {
    file open myfile using _`year'_qm.qmd, write replace
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
  


