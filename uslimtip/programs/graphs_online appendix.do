**online appendix USLIMTIP

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
		label define survey 11 "ATUS" 12 "ATUS"  20 "ASEC" ,  replace 
		label define g 1 "m_nc_ne" 2 "m_nc_e" 3 "m_c_ne" 4 "m_c_e" 5 "w_nc_ne" 6 "w_nc_e" 7 "w_c_ne" 8 "w_c_e",  replace 

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
		label values g g

*Match quality boxplots
global $github Users/aashimasinha/Documents/GitHub/LevyBardOnline.github.io/uslimtip
set scheme white2 
color_style bay


*Overall
			 			 
foreach i in g sex race age_group empstat2 haschildren ych ntchild ntadult iscouple educ_tb faminc_q {
	
graph box hprod_wkday if survey!=12, by(`i', note("") l1title("Daily minutes") compact) over(survey) ytitle("Daily minutes") name(wkday_`i', replace) 

graph export "/Users/aashimasinha/Documents/GitHub/LevyBardOnline.github.io/uslimtip/resources/y`year'/wkday_`i'.png", replace


graph box hprod_wkend if survey!=11, by(`i', note("") l1title("Daily minutes") compact) over(survey) ytitle("Daily minutes") name(wkend_`i', replace) 
graph export "/Users/aashimasinha/Documents/GitHub/LevyBardOnline.github.io/uslimtip/resources/y`year'/wkend_`i'.png", replace

}


*Men
foreach i in g race age_group empstat2 haschildren ych ntchild ntadult iscouple educ_tb faminc_q{

graph box hprod_wkday if survey!=12 & sex==1, by(`i', note("") l1title("Daily minutes") compact) over(survey) ytitle("Daily minutes") name(wkday_`i', replace) 
graph export "/Users/aashimasinha/Documents/GitHub/LevyBardOnline.github.io/uslimtip/resources/y`year'/mwkday_`i'.png", replace

graph box hprod_wkend if survey!=11 & sex==1, by(`i', note("") l1title("Daily minutes") compact) over(survey) ytitle("Daily minutes") name(wkend_`i', replace) 

graph export "/Users/aashimasinha/Documents/GitHub/LevyBardOnline.github.io/uslimtip/resources/y`year'/mwkend_`i'.png", replace

}
*Women
foreach i in g race age_group empstat2 haschildren ych ntchild ntadult iscouple educ_tb faminc_q {


graph box hprod_wkday if survey!=12 & sex==2, by(`i', note("") l1title("Daily minutes") compact) over(survey) ytitle("Daily minutes") name(wkday_`i', replace) 
graph export "/Users/aashimasinha/Documents/GitHub/LevyBardOnline.github.io/uslimtip/resources/y`year'/fwkday_`i'.png", replace


graph box hprod_wkend if survey!=11 & sex==2, by(`i', note("") l1title("Daily minutes") compact) over(survey) ytitle("Daily minutes") name(wkend_`i', replace) 
graph export "/Users/aashimasinha/Documents/GitHub/LevyBardOnline.github.io/uslimtip/resources/y`year'/fwkend_`i'.png", replace


}

*Balance


*Overall
set scheme white2 
color_style bay

foreach i in sex race age_group empstat2 haschildren ych ntchild ntadult iscouple educ_tb faminc_q {
graph bar (percent) if survey!=12 [w=fwt], over(survey, label(labsize(small))) over(`i', label(labsize(small))) ytitle("Share (%)")
graph export "/Users/aashimasinha/Documents/GitHub/LevyBardOnline.github.io/uslimtip/resources/y`year'/wkday_`i'_b.png", replace

graph bar (percent) if survey!=11 [w=fwt], over(survey, label(labsize(small))) over(`i', label(labsize(small))) ytitle("Share (%)")
graph export "/Users/aashimasinha/Documents/GitHub/LevyBardOnline.github.io/uslimtip/resources/y`year'/wkend_`i'_b.png", replace
}
*Men
foreach i in  race age_group empstat2 haschildren ych ntchild ntadult iscouple educ_tb faminc_q {
graph bar (percent) if survey!=12 & sex==1 [w=fwt], over(survey, label(labsize(small))) over(`i', label(labsize(small))) ytitle("Share (%)")
graph export "/Users/aashimasinha/Documents/GitHub/LevyBardOnline.github.io/uslimtip/resources/y`year'/mwkday_`i'_b.png", replace

graph bar (percent) if survey!=11 & sex==1 [w=fwt], over(survey, label(labsize(small))) over(`i', label(labsize(small))) ytitle("Share (%)")
graph export "/Users/aashimasinha/Documents/GitHub/LevyBardOnline.github.io/uslimtip/resources/y`year'/mwkend_`i'_b.png", replace
}

*Women
foreach i in race age_group empstat2 haschildren ych ntchild ntadult iscouple educ_tb faminc_q {
graph bar (percent) if survey!=12 & sex==1 [w=fwt], over(survey, label(labsize(small))) over(`i', label(labsize(small))) ytitle("Share (%)")
graph export "/Users/aashimasinha/Documents/GitHub/LevyBardOnline.github.io/uslimtip/resources/y`year'/fwkday_`i'_b.png", replace

graph bar (percent) if survey!=11 & sex==2 [w=fwt], over(survey, label(labsize(small))) over(`i', label(labsize(small))) ytitle("Share (%)")

graph export "/Users/aashimasinha/Documents/GitHub/LevyBardOnline.github.io/uslimtip/resources/y`year'/fwkend_`i'_b.png", replace
}
}