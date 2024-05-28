

***boxplots_online appendix USLIMTIP

forvalues year = 2005/2023 {
	cd "$savedata"
		
        *local year = 2022
		use "$savedata/asec_atus_f_concise.dta" if year==`year' , clear
		merge m:1 year hseq lineno using "$savedata/match_`year'_wkday.dta", gen(m1)
		merge m:1 year hseq lineno using "$savedata/match_`year'_wkend.dta", gen(m2)
		
		
		drop2 _merge mx
		drop2 fpr* sum_w* yearp*
		gen ych = nkids05_c>0
		*gen anykids = (nkids05_c +nkids614_c +nkids1517_c)>0
		egen emp_child = group(empstat2_c anykids)
		gen ntchild = nkids_c
		replace ntchild =3 if ntchild >3
		gen ntadult = min(nadults,3)
		recode age (15/24 =1 ) (25/39=2) (40/54=3) (55/64=4) (65/999=5), gen(age_group)
		gen iscouple = 0
		replace iscouple = 1 if famtype>=5
		gen educ_tb = educ 
		replace educ_tb = 4 if educ_tb ==5
		xtile faminc_q = hfaminc [w=fwt], n(5)

		foreach i in race ych  emp_child ntchild ntadult age_group iscouple educ_tb faminc_q  {
			tab `i'
		}

		** First time use
		gen hprod_wkend=ccare_wkend +acare_wkend +core_wkend +proc_wkend
		gen hprod_wkday=ccare_wkday +acare_wkday +core_wkday +proc_wkday

		replace hprod_wkend=ccare +acare  +core  +proc if survey==12
		replace hprod_wkday=ccare +acare  +core  +proc if survey==11
		
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


*Match quality boxplots
global $github Users/aashimasinha/Documents/GitHub/LevyBardOnline.github.io/uslimtip
set scheme white2 
color_style bay


*Overall
			 			 
foreach i in sex race age_group empstat2 haschildren ych ntchild ntadult iscouple educ_tb faminc_q {
	
graph box hprod_wkday if survey!=12, by(`i', note("") l1title("Daily minutes") compact) over(survey) ytitle("Daily minutes") name(wkday_`i', replace) 
graph export "/Users/aashimasinha/Documents/GitHub/LevyBardOnline.github.io/uslimtip/resources/y`year'/`year'wkday_`i'.png", replace


graph box hprod_wkend if survey!=11, by(`i', note("") l1title("Daily minutes") compact) over(survey) ytitle("Daily minutes") name(wkend_`i', replace) 
graph export "/Users/aashimasinha/Documents/GitHub/LevyBardOnline.github.io/uslimtip/resources/y`year'/`year'wkend_`i'.png", replace

graph combine wkday_`i' wkend_`i', nocopies  ysize(5) xsize(10) scale(1.4)

graph export "/Users/aashimasinha/Documents/GitHub/LevyBardOnline.github.io/uslimtip/resources/y`year'/`year'c_`i'.png", replace
}


*Men
foreach i in race age_group empstat2 haschildren ych ntchild ntadult iscouple educ_tb faminc_q{

graph box hprod_wkday if survey!=12 & sex==1, by(`i', note("") l1title("Daily minutes") compact) over(survey) ytitle("Daily minutes") name(wkday_`i', replace) 
graph export "/Users/aashimasinha/Documents/GitHub/LevyBardOnline.github.io/uslimtip/resources/y`year'/m`year'wkday_`i'.png", replace

graph box hprod_wkend if survey!=11 & sex==1, by(`i', note("") l1title("Daily minutes") compact) over(survey) ytitle("Daily minutes") name(wkend_`i', replace) 

graph export "/Users/aashimasinha/Documents/GitHub/LevyBardOnline.github.io/uslimtip/resources/y`year'/m`year'wkend_`i'.png", replace

}
*Women
foreach i in race age_group empstat2 haschildren ych ntchild ntadult iscouple educ_tb faminc_q {

graph box hprod_wkday if survey!=12 & sex==2, by(`i', note("") l1title("Daily minutes") compact) over(survey) ytitle("Daily minutes") name(wkday_`i', replace) 
graph export "/Users/aashimasinha/Documents/GitHub/LevyBardOnline.github.io/uslimtip/resources/y`year'/f`year'wkday_`i'.png", replace


graph box hprod_wkend if survey!=11 & sex==2, by(`i', note("") l1title("Daily minutes") compact) over(survey) ytitle("Daily minutes") name(wkend_`i', replace) 
graph export "/Users/aashimasinha/Documents/GitHub/LevyBardOnline.github.io/uslimtip/resources/y`year'/f`year'wkend_`i'.png", replace


}

}

/***EXTRA
	
***Construct rel/abs gap and plot those \
forvalues i = 2022 / 2022 {
	use "/Users/aashimasinha/Documents/GitHub/LevyBardOnline.github.io/uslimtip/procdata/qtable_`i'.dta", clear


sort ovar1 ovar2

gen day_gap = ((day_d_mean - day_r_mean) / (0.5 * (day_d_mean + day_r_mean))) * 100

gen end_gap = ((end_d_mean - end_r_mean)/  (0.5 * (end_d_mean + end_r_mean))) * 100 

gen y_var= _n

	
#delimit ;	
twoway
	(scatter y_var day_gap if ovar2 == "none",xscale(range(-15 15)) msym(oh) mcolor(red))
	(scatter y_var end_gap if ovar2 == "none", xscale(range(-15 15)) msym(o) mcolor(blue)),
	xlabel(-20(5)20, labsize(small))  
    xtitle("Relative household production gap", size(small)) 
    ytitle("Sub-groups")
    title("Match Quality: Comparing Mean differences", size(small bold))
	legend(order(1 "Weekday " 2 "Weekend") position(6) rows(1))
	xline(0, lcolor(black) lpattern(shortdash))
    xsize(5) ysize(8)
;
#delimit cr

}

levelsof y_var, local(vyvar)
foreach i of local vyvar {
     sum end_d_vi if y_var == `i', meanonly
	 local ki = r(mean)
	 local ii `=ovar1[`i']'
	 display "`ii'"
	 label define y_var `i' "`:label `ii' `ki''", modify
}
label values y_var y_var

sort ovar1 ovar2


#delimit ;	
twoway
	(scatter y_var day_gap if ovar1=="sex" & ovar2=="none" ,xscale(range(-15 15)) msym(oh) mcolor(red))
	(scatter y_var end_gap if ovar1=="sex" & ovar2=="none" , xscale(range(-15 15)) msym(o) mcolor(blue)),
	xlabel(-20(5)20, labsize(small))  
	ylabel(,val)
    xtitle("Relative household production gap" , size(small)) 
    ytitle("Presence of young children")
    title("Match Quality: Comparing Mean differences", size(medium))
	legend(order(1 "Weekday " 2 "Weekend") position(6) rows(1))
	xline(0, lcolor(black) lpattern(shortdash))
    xsize(5) ysize(8) 

;

#delimit cr


#delimit ;	
twoway
	(scatter y_var day_gap if ovar1=="age_group" & ovar2=="none" ,xscale(range(-15 15)) msym(oh) mcolor(red))
	(scatter y_var end_gap if ovar1=="age_group" & ovar2=="none" , xscale(range(-15 15)) msym(o) mcolor(blue)),
	xlabel(-20(5)20, labsize(small))  
	ylabel(,val)
    xtitle("Relative household production gap" , size(small)) 
    ytitle("Age-groups")
    title("Match Quality: Comparing Mean differences", size(medium))
	legend(order(1 "Weekday " 2 "Weekend") position(6) rows(1))
	xline(0, lcolor(black) lpattern(shortdash))
    xsize(5) ysize(8) 

;
#delimit cr



#delimit ;	
twoway
	(scatter y_var day_gap if ovar1=="employed" & ovar2=="none" ,xscale(range(-15 15)) msym(oh) mcolor(red))
	(scatter y_var end_gap if ovar1=="employed" & ovar2=="none" , xscale(range(-15 15)) msym(o) mcolor(blue)),
	xlabel(-20(5)20, labsize(small))  
	ylabel(,val)
    xtitle("Relative household production gap" , size(small)) 
    ytitle("Employment status")
    title("Match Quality: Comparing Mean differences", size(medium))
	legend(order(1 "Weekday " 2 "Weekend") position(6) rows(1))
	xline(0, lcolor(black) lpattern(shortdash))
    xsize(5) ysize(8) 

;
#delimit cr


#delimit ;	
twoway
	(scatter y_var day_gap if ovar1=="ych" & ovar2=="none" ,xscale(range(-15 15)) msym(oh) mcolor(red))
	(scatter y_var end_gap if ovar1=="ych" & ovar2=="none" , xscale(range(-15 15)) msym(o) mcolor(blue)),
	xlabel(-20(5)20, labsize(small))  
	ylabel(,val)
    xtitle("Relative household production gap" , size(small)) 
    ytitle("Presence of young children")
    title("Match Quality: Comparing Mean differences", size(medium))
	legend(order(1 "Weekday " 2 "Weekend") position(6) rows(1))
	xline(0, lcolor(black) lpattern(shortdash))
    xsize(5) ysize(8) 

;
#delimit cr


#delimit ;	
twoway
	(scatter y_var day_gap if ovar1=="race" & ovar2=="none" ,xscale(range(-15 15)) msym(oh) mcolor(red))
	(scatter y_var end_gap if ovar1=="race" & ovar2=="none" , xscale(range(-15 15)) msym(o) mcolor(blue)),
	xlabel(-20(5)20, labsize(small))  
	ylabel(,val)
    xtitle("Relative household production gap" , size(small)) 
    ytitle("Race")

    title("Match Quality: Comparing Mean differences", size(medium))
	legend(order(1 "Weekday " 2 "Weekend") position(6) rows(1))
	xline(0, lcolor(black) lpattern(shortdash))
    xsize(5) ysize(8) 

;
#delimit cr


global listv1  sex  employed  ych iscouple race educ_tb   age_group ntchild  ntadult faminc_q
global listv2 none  $listv1 
 foreach ii  of global listv1 {
            foreach jj  of global listv2 {
                if "`jj'"!="`ii'" {
#delimit ;	
twoway
	(scatter y_var day_gap if ovar1=="`ii'" & ovar2=="none",xscale(range(-15 15)) msym(oh) mcolor(red))
	(scatter y_var end_gap if ovar1=="`ii'" & ovar2=="none", xscale(range(-15 15)) msym(o) mcolor(blue)),
	xlabel(-20(5)20, labsize(small))  
    xtitle("Relative household production gap", size(small)) 
    ytitle("Sub-groups")
    title("Match Quality: Comparing Mean differences", size(medium))
	legend(order(1 "Weekday " 2 "Weekend") position(6) rows(1))
	xline(0, lcolor(black) lpattern(shortdash))
    xsize(5) ysize(8) ylabel(,val)
;
#delimit cr

}
}
}
}

/*check with FRA saving
graph save "/Users/aashimasinha/Documents/GitHub/LevyBardOnline.github.io/uslimtip/resources/y`i'/scatter_`i'.png", replace
*/
	

	
#delimit ;	
twoway
	(scatter y_var day_gap if ovar1 =="employed" & ovar2 == "none",xscale(range(-20 20)) msym(oh) mcolor(red))
	(scatter y_var end_gap if ovar1 =="employed" & ovar2 == "none", xscale(range(-20 20)) msym(o) mcolor(blue)),
	xlabel(-20(5)20, labsize(small))
    ylabel(299 "Not Employed" 298 "Employed", angle(0) labsize(small) gmin gmax)
	xtitle("Relative household production gap", size(small))
    ytitle("Employment status")
    title("Match Quality: Comparing Mean differences", size(medium))
	legend(order(1 "Weekday " 2 "Weekend") ring(0) position(11) rows(1))
	xline(0, lcolor(black) lpattern(shortdash))

;
#delimit cr

#delimit ;	
twoway
	(scatter y_var day_gap if ovar1 =="ych" & ovar2 == "none",xscale(range(-20 20)) msym(oh) mcolor(red))
	(scatter y_var end_gap if ovar1 =="ych" & ovar2 == "none", xscale(range(-20 20)) msym(o) mcolor(blue)),
	xlabel(-20(5)20, labsize(small))
    ylabel(299 "Not Employed" 298 "Employed", angle(0) labsize(small) gmin gmax)
	xtitle("Relative household production gap", size(small))
    ytitle("Employment status")
    title("Match Quality: Comparing Mean differences", size(medium))
	legend(order(1 "Weekday " 2 "Weekend") ring(0) position(9) rows(1))
	xline(0, lcolor(black) lpattern(shortdash))

;
#delimit cr



/*
label define y_var 1 "Age:15-34" 2  "Age:25-39", modify

scatter y_var end_gap if ovar2="none", ylabel (1 2 valuelabels), xscale(range(-15 15))
*/

/**Balance??

gen b_day_gap = (day_d_n/day_r_n-1)*100

((day_d_mean - day_r_mean) / (0.5 * (day_d_mean + day_r_mean))) * 100

gen end_gap = ((end_d_mean - end_r_mean)/  (0.5 * (end_d_mean + end_r_mean))) * 100 
*/

 foreach j in end_r_wn end_d_wn  {
 	foreach k in day_r_wn day_d_wn {
            drop2 twgt twgt2    `*_share   *_share       
            bysort ovar1 ovar2:egen double twgt = sum(`j')    
            replace `j'=`j'/twgt*100
			gen `j'_share=`j'/twgt*100
         
            bysort ovar1 ovar2:egen double twgt2 = sum(`k')    
            replace `k'=`k'/twgt2*100
			gen `k'_share=`k'/twgt2*100
	
#delimit ;	
twoway
	(scatter y_var `j'_share if ovar2 == "none",xscale(range(-15 15)) msym(oh) mcolor(red))
	(scatter y_var `k'_share if ovar2 == "none", xscale(range(-15 15)) msym(o) mcolor(blue)),
	xlabel(-20(5)20, labsize(small))  
    xtitle("Relative household production gap", size(small)) 
    ytitle("Sub-groups")
    title("Match Quality: Comparing Mean differences", size(medium))
	legend(order(1 "Weekday " 2 "Weekend") ring(0) position(9) rows(1))
	xline(0, lcolor(black) lpattern(shortdash))
    xsize(5) ysize(8)
;
#delimit cr
	
	}
 }
 		
 
 
 
#delimit ;	
twoway
	(scatter y_var `j'_share if ovar2 == "none",xscale(range(-15 15)) msym(oh) mcolor(red))
	(scatter y_var end_gap if ovar2 == "none", xscale(range(-15 15)) msym(o) mcolor(blue)),
	xlabel(-10(4)10, labsize(small))  
    xtitle("Relative household production gap", size(small)) 
    ytitle("Sub-groups")
    title("Match Quality: Comparing Mean differences", size(medium))
	legend(order(1 "Weekday " 2 "Weekend") ring(0) position(9) rows(1))
	xline(0, lcolor(black) lpattern(shortdash))
    xsize(5) ysize(8)
;
#delimit cr
	
			
 }
 */


