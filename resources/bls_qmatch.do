**11 prep for qmatch

capture program drop tab_sum
program tab_sum, rclass 
	syntax varname [aw], cvar(varname) rvar(varname)  
	qui:levelsof `cvar' if `varlist'!=., local(ccvar)
	qui:levelsof `rvar' if `varlist'!=., local(rrvar)
	tempname vmean vmedian vsd result1 result2 result3
	foreach i of local rrvar {
		capture matrix drop `vmean' `vmedian' `vsd'
		foreach j of local ccvar {
			qui:sum `varlist' [`weight'`exp'] if `cvar'==`j' & `rvar'==`i',d
			matrix `vmean'  =nullmat(`vmean'  ), r(mean)
			matrix `vmedian'=nullmat(`vmedian'), r(p50)
			matrix `vsd'    =nullmat(`vsd'), r(sd)
		}
		matrix `result1'=nullmat(`result1') \ `vmean'
		matrix `result2'=nullmat(`result2') \ `vmedian'
		matrix `result3'=nullmat(`result3') \ `vsd'
		
	}
	return matrix result1=`result1'
	return matrix result2=`result2'
	 return matrix result3=`result3'
end

 

capture program drop qc_proc
program qc_proc
	egen colvar = group(survey3 sex)
	gen ychild = nchild00_05>=1
	egen work_child = group(works dchild), label
	gen tchild=min(nchild00_05 +nchild06_12 +nchild13_17,3)
	gen tadult=min(adult18_64_f +adult18_64_m +adult65p,3)
	replace tadult=1 if tadult==0

	recode age (15/17=1 "15-17") (18/29=2 "18-29") (30/44=3 "30-44") (45/64=4 "45/64") (65/99=5 "65/99"), gen(age_g)

	recode educ_0 (2/3=1 "Less than HS") (4=2 "High School") (5=3 "Some College") (6/8=4 "College +"), gen(educ_g)
	recode finc_pre (1/9=1) (10/12=2) (13/14=3) (15=4) (16=5), gen(q5)
end

capture program drop qc_tables
program qc_tables
	syntax varlist
	matrix blank = [.,.,.,.,.,. ]
	capture matrix drop fmean fmedian fsd
 	 
	foreach i in race ychild work_child tchild tadult age_g cpl educ_g q5 {
		
		tab_sum `varlist' [w=anwgt]  , rvar(`i') cvar(colvar)
		matrix fmean   = nullmat(fmean)\blank\r(result1)
		matrix fmedian = nullmat(fmedian)\blank\r(result2)
		matrix fsd     = nullmat(fsd)\blank\r(result3)
	}
	 
	
end
 
***
label define ychild 1 "Young Child present" 0 "No Young Child Present"
label values ychild ychild 
label define work_child 1 "Not Working no Children" ///
                        2 "Not Working with Children" ///
                        3 "Working no Children" ///
                        4 "Working with Children", modify
label values work_child work_child
 
label define age_g 1 "15/17" 2 "18/29" 3 "30/44", modify
label define tchild 3 "3+"
label define tadult 3 "3+"
label values tchild tchild 
label values tadult tadult 
label define cpl 1 "Single" 2 "Couple"
label values cpl cpl 
label define hhown 0 "Renter" 1 "Home-owner"
label values hhown hhown 
** ♂♀ 
label define wsc 1 "Not Working-Man-NoChild" ///
                 2 "Not Working-Man-Child" ///
                 3 "Not Working-Woman-NoChild" ///
                 4 "Not Working-Woman-Child" ///
                 5 "Working-Man-NoChild" ///
                 6 "Working-Man-Child" ///
                 7 "Working-Woman-NoChild" ///
                 8 "Working-Woman-Child", modify
label values wsc wsc

label define q5 1 "    < $35K " ///
                2 " $35K/$60K "  ///
                3 " $60K/$100K"  ///
                4 "$100K/$150K"  ///
                5 "    > $150K", modify
label values q5 q5

fre race ychild work_child tchild tadult age_g cpl educ_g q5 hhown sex

label var race "Race" 
label var ychild "Young Children Present" 
label var work_child "Works x Children"
label var tchild "# of Children"
label var tadult "# of Adults"
label var age_g "Age group"
label var cpl "Single/Couple"
label var educ_g "Education Level"
label var q5 "Income Quantile"
label var hhown "Home Ownership Status"
label var sex "Gender"
label var dchild "Child Present"
label define dchild 1 "Child Present" 0 "No Children"
label values dchild dchild 
** Essentials

fre race ychild work_child tchild tadult age_g cpl educ_g q5 hhown sex 
sum thp* anwgt survey2 dchild clust_100 *wday *wend

************ Creation of Tables
label var survey2 "Survey"
table (age_g race) (survey2) [w=anwgt] if inlist(survey2,1,2,4), stat(mean thp_levy_rp_wday) ///
                                                           stat(median thp_levy_rp_wday) ///
                                                           stat(sd thp_levy_rp_wday) ///
                                                           nototal nformat(%5.2f) 
collect label levels result sd "Std.Dev.", modify
                                                           
table (race) (survey2) [w=anwgt] if inlist(survey2,1,2,5), stat(mean thp_levy_rp_wend) nototal nformat(%5.2f)


cd "finldoc"
foreach i in rp sm mi1 mi2 mi3 mi4 mi5 {
	qc_tables thp_levy_`i'_wday
	putexcel set  CE_ATUS_Match, modify sheet(wkday_`i')
	putexcel c6=matrix(fmean) ///
			 k6=matrix(fmedian) ///
			 s6=matrix(fsd)
	putexcel close
		 
}

foreach i in rp sm mi1 mi2 mi3 mi4 mi5 {
	qc_tables thp_levy_`i'_wend
	putexcel set CE_ATUS_Match, modify sheet(wkend_`i')
	putexcel c6=matrix(fmean) ///
			 k6=matrix(fmedian) ///
			 s6=matrix(fsd)
	putexcel close
}
** Do the same for SUP
********************************************************************************
********************************************************************************
tabstat thp_levy_sm_wday  [w=anwgt] if survey2==4,stats(p10 p25 p50 p75 p90 mean sd) save
matrix trt=r(StatTotal)'
tabstat thp_levy_rp_wday  [w=anwgt] if survey2==1,stats(p10 p25 p50 p75 p90 mean sd) save
matrix trt=trt\r(StatTotal)'
tabstat thp_levy_mi1_wday [w=anwgt] if survey2==1,stats(p10 p25 p50 p75 p90 mean sd) save
matrix trt=trt\r(StatTotal)'
tabstat thp_levy_sm_wday  [w=anwgt] if survey2==1,stats(p10 p25 p50 p75 p90 mean sd) save
matrix trt=trt\r(StatTotal)'

tabstat thp_sup_sm_wday  [w=anwgt] if survey2==4 & dchild==1,stats(p10 p25 p50 p75 p90 mean sd) save
matrix trt=trt\r(StatTotal)'
tabstat thp_sup_rp_wday  [w=anwgt] if survey2==1 & dchild==1,stats(p10 p25 p50 p75 p90 mean sd) save
matrix trt=trt\r(StatTotal)'
tabstat thp_sup_mi1_wday [w=anwgt] if survey2==1 & dchild==1,stats(p10 p25 p50 p75 p90 mean sd) save
matrix trt=trt\r(StatTotal)'
tabstat thp_sup_sm_wday  [w=anwgt] if survey2==1 & dchild==1,stats(p10 p25 p50 p75 p90 mean sd) save
matrix trt=trt\r(StatTotal)'


tabstat thp_levy_sm_wend  [w=anwgt] if survey2==5,stats(p10 p25 p50 p75 p90 mean sd) save
matrix trt=trt\r(StatTotal)'
tabstat thp_levy_rp_wend  [w=anwgt] if survey2==1,stats(p10 p25 p50 p75 p90 mean sd) save
matrix trt=trt\r(StatTotal)'
tabstat thp_levy_mi1_wend [w=anwgt] if survey2==1,stats(p10 p25 p50 p75 p90 mean sd)  save
matrix trt=trt\r(StatTotal)'
tabstat thp_levy_sm_wend  [w=anwgt] if survey2==1,stats(p10 p25 p50 p75 p90 mean sd) save
matrix trt=trt\r(StatTotal)'

tabstat thp_sup_sm_wend  [w=anwgt] if survey2==5 & dchild==1,stats(p10 p25 p50 p75 p90 mean sd) save
matrix trt=trt\r(StatTotal)'
tabstat thp_sup_rp_wend  [w=anwgt] if survey2==1 & dchild==1,stats(p10 p25 p50 p75 p90 mean sd) save
matrix trt=trt\r(StatTotal)'
tabstat thp_sup_mi1_wend [w=anwgt] if survey2==1 & dchild==1,stats(p10 p25 p50 p75 p90 mean sd) save
matrix trt=trt\r(StatTotal)'
tabstat thp_sup_sm_wend  [w=anwgt] if survey2==1 & dchild==1,stats(p10 p25 p50 p75 p90 mean sd) save
matrix trt=trt\r(StatTotal)'


** boxplots
label define wsc 1 "w_m_nc" ///
				 2 "w_m_c" ///
				 3 "w_f_nc" ///
				 4 "w_f_c" ///
				 5 "nw_m_nc" ///
				 6 "nw_m_c" ///
				 7 "nw_f_nc" ///
				 8 "nw_f_c" 
label values wsc wsc
set scheme white2
foreach i of varlist thp* {
label var `i' " "
}

foreach i in rp sm mi1 {
	foreach j in wday wend {
	if "`i'"=="rp" local subt "Regression Prediction"
	if "`i'"=="sm" local subt "Statistical Matching"
	if "`i'"=="mi1" local subt "Multiple Imputation 1"
	if "`j'"=="wday" local tit "Weekday"
	if "`j'"=="wend" local tit "Weekend"
	graph hbox thp_levy_`i'_`j' [w=anwgt] if thp_levy_`i'_`j'!=., over(wsc) ///
		by(survey2, col(3) note("") title("Time use on HP: `tit'") subtitle(`subt')) ///
		graphregion(margin(tiny))  plotregion(margin(tiny))  xsize(10) ysize(5)
	graph export fnl_data\boxplot_`i'_`j'.png	, replace 
	}
}

foreach i in rp sm mi1 {
	foreach j in wday wend {
	if "`i'"=="rp" local subt "Regression Prediction"
	if "`i'"=="sm" local subt "Statistical Matching"
	if "`i'"=="mi1" local subt "Multiple Imputation 1"
	if "`j'"=="wday" local tit "Weekday"
	if "`j'"=="wend" local tit "Weekend"
	graph hbox thp_sup_`i'_`j' [w=anwgt] if thp_levy_`i'_`j'!=., over(wsc) ///
		by(survey2, col(3) note("") title("Time use on Sup. Care: `tit'") subtitle(`subt')) ///
		graphregion(margin(tiny))  plotregion(margin(tiny))  xsize(10) ysize(5)
	graph export fnl_data\boxplot_`i'_`j'_sup.png	, replace 
	}
}

** Potentially produced for ALL elements 
color_style bay

graph hbar (mean) thp_levy_rp_wday (median) thp_levy_rp_wday  (sd) thp_levy_rp_wday if survey2==1 [w=anwgt], ///
	  over(wsc) legend(order(1 "Mean" 2 "Median" 3 "Sd") row(1)) ///
	  subtitle("Regression Prediction") name(m1, replace) graphregion(margin(tiny))
graph hbar (mean) thp_levy_sm_wday (median) thp_levy_sm_wday  (sd) thp_levy_sm_wday if survey2==1 [w=anwgt], ///
	  over(wsc) legend(order(1 "Mean" 2 "Median" 3 "Sd") row(1)) ///
	  subtitle("Statistical Matching") name(m2, replace) graphregion(margin(tiny))
graph hbar (mean) thp_levy_mi1_wday (median) thp_levy_mi1_wday  (sd) thp_levy_mi1_wday if survey2==1 [w=anwgt], ///
	  over(wsc) legend(order(1 "Mean" 2 "Median" 3 "Sd") row(1)) ///
	  subtitle("Multiple Imputation") name(m3, replace)	 graphregion(margin(tiny))
graph hbar (mean) thp_levy_mi1_wday (median) thp_levy_mi1_wday  (sd) thp_levy_mi1_wday if survey2==4 [w=anwgt], ///
	  over(wsc) legend(order(1 "Mean" 2 "Median" 3 "Sd") row(1)) ///
	  subtitle("ATUS") name(m4, replace)	 graphregion(margin(tiny))	  
grc1leg m1 m2 m3 m4, col(4)	   nocopies xcommon name(mix, replace) title("Time use on HP: Weekday") subtitle("CE Interview")
graph combine mix,  xsize(10) ysize(5) nocopies
graph export fnl_data\compare_wday_cei.png	, replace 
	  
***************

graph hbar (mean) thp_levy_rp_wend (median) thp_levy_rp_wend  (sd) thp_levy_rp_wend if survey2==1 [w=anwgt], ///
	  over(wsc) legend(order(1 "Mean" 2 "Median" 3 "Sd") row(1)) ///
	  subtitle("Regression Prediction") name(m1, replace) graphregion(margin(tiny))
graph hbar (mean) thp_levy_sm_wend (median) thp_levy_sm_wend  (sd) thp_levy_sm_wend if survey2==1 [w=anwgt], ///
	  over(wsc) legend(order(1 "Mean" 2 "Median" 3 "Sd") row(1)) ///
	  subtitle("Statistical Matching") name(m2, replace) graphregion(margin(tiny))
graph hbar (mean) thp_levy_mi1_wend (median) thp_levy_mi1_wend  (sd) thp_levy_mi1_wend if survey2==1 [w=anwgt], ///
	  over(wsc) legend(order(1 "Mean" 2 "Median" 3 "Sd") row(1)) ///
	  subtitle("Multiple Imputation") name(m3, replace)	 graphregion(margin(tiny))
graph hbar (mean) thp_levy_mi1_wend (median) thp_levy_mi1_wend  (sd) thp_levy_mi1_wend if survey2==5 [w=anwgt], ///
	  over(wsc) legend(order(1 "Mean" 2 "Median" 3 "Sd") row(1)) ///
	  subtitle("ATUS") name(m4, replace)	 graphregion(margin(tiny))	  
grc1leg m1 m2 m3 m4, col(4)	   nocopies xcommon name(mix, replace) title("Time use on HP: Weekend") subtitle("CE Interview")
graph combine mix,  xsize(10) ysize(5) nocopies
graph export fnl_data\compare_wend_cei.png	, replace 	  


****

graph hbar (mean) thp_levy_rp_wday (median) thp_levy_rp_wday  (sd) thp_levy_rp_wday if survey2==2 [w=anwgt], ///
	  over(wsc) legend(order(1 "Mean" 2 "Median" 3 "Sd") row(1)) ///
	  subtitle("Regression Prediction") name(m1, replace) graphregion(margin(tiny))
graph hbar (mean) thp_levy_sm_wday (median) thp_levy_sm_wday  (sd) thp_levy_sm_wday if survey2==2 [w=anwgt], ///
	  over(wsc) legend(order(1 "Mean" 2 "Median" 3 "Sd") row(1)) ///
	  subtitle("Statistical Matching") name(m2, replace) graphregion(margin(tiny))
graph hbar (mean) thp_levy_mi1_wday (median) thp_levy_mi1_wday  (sd) thp_levy_mi1_wday if survey2==2 [w=anwgt], ///
	  over(wsc) legend(order(1 "Mean" 2 "Median" 3 "Sd") row(1)) ///
	  subtitle("Multiple Imputation") name(m3, replace)	 graphregion(margin(tiny))
graph hbar (mean) thp_levy_mi1_wday (median) thp_levy_mi1_wday  (sd) thp_levy_mi1_wday if survey2==4 [w=anwgt], ///
	  over(wsc) legend(order(1 "Mean" 2 "Median" 3 "Sd") row(1)) ///
	  subtitle("ATUS") name(m4, replace)	 graphregion(margin(tiny))	  
grc1leg m1 m2 m3 m4, col(4)	   nocopies xcommon name(mix, replace) title("Time use on HP: Weekday") subtitle("CE Diary")
graph combine mix,  xsize(10) ysize(5) nocopies
graph export fnl_data\compare_wday_ced.png	, replace 
	  
***************

graph hbar (mean) thp_levy_rp_wend (median) thp_levy_rp_wend  (sd) thp_levy_rp_wend if survey2==2 [w=anwgt], ///
	  over(wsc) legend(order(1 "Mean" 2 "Median" 3 "Sd") row(1)) ///
	  subtitle("Regression Prediction") name(m1, replace) graphregion(margin(tiny))
graph hbar (mean) thp_levy_sm_wend (median) thp_levy_sm_wend  (sd) thp_levy_sm_wend if survey2==2 [w=anwgt], ///
	  over(wsc) legend(order(1 "Mean" 2 "Median" 3 "Sd") row(1)) ///
	  subtitle("Statistical Matching") name(m2, replace) graphregion(margin(tiny))
graph hbar (mean) thp_levy_mi1_wend (median) thp_levy_mi1_wend  (sd) thp_levy_mi1_wend if survey2==2 [w=anwgt], ///
	  over(wsc) legend(order(1 "Mean" 2 "Median" 3 "Sd") row(1)) ///
	  subtitle("Multiple Imputation") name(m3, replace)	 graphregion(margin(tiny))
graph hbar (mean) thp_levy_mi1_wend (median) thp_levy_mi1_wend  (sd) thp_levy_mi1_wend if survey2==5 [w=anwgt], ///
	  over(wsc) legend(order(1 "Mean" 2 "Median" 3 "Sd") row(1)) ///
	  subtitle("ATUS") name(m4, replace)	 graphregion(margin(tiny))	  
grc1leg m1 m2 m3 m4, col(4)	   nocopies xcommon name(mix, replace) title("Time use on HP: Weekend") subtitle("CE Diary")
graph combine mix,  xsize(10) ysize(5) nocopies
graph export fnl_data\compare_wend_ced.png	, replace 	  

*************

 graph hbar cook_rp_wday hwork_rp_wday ccare_rp_wday acare_rp_wday   if survey2==1 [w=anwgt], stack over(wsc) percent legend(col(4) order(1 "Cooking" 2 "Oth House Work" 3 "Child Care" 4 "Adult Care")) ytitle("") subtitle("Regression Prediction") name(m1, replace) graphregion(margin(tiny))
 
 graph hbar cook_sm_wday hwork_sm_wday ccare_sm_wday acare_sm_wday   if survey2==1 [w=anwgt], stack over(wsc) percent legend(col(4) order(1 "Cooking" 2 "Oth House Work" 3 "Child Care" 4 "Adult Care")) ytitle("") subtitle("Statistical Matching") name(m2, replace) graphregion(margin(tiny))
 
 graph hbar iicook_1_wday iihwork_1_wday  iiccare_1_wday iiacare_1_wday  if survey2==1 [w=anwgt], stack over(wsc) percent legend(col(4) order(1 "Cooking" 2 "Oth House Work" 3 "Child Care" 4 "Adult Care")) ytitle("") subtitle("Multiple Imputation") name(m3, replace) graphregion(margin(tiny))
 
 graph hbar cook_sm_wday hwork_sm_wday ccare_sm_wday acare_sm_wday   if survey2==4 [w=anwgt], stack over(wsc) percent legend(col(4) order(1 "Cooking" 2 "Oth House Work" 3 "Child Care" 4 "Adult Care")) ytitle("") subtitle("ATUS Weekday") name(m4, replace) graphregion(margin(tiny)) 
  
grc1leg m1 m2 m3 m4, col(4)	   nocopies xcommon name(mix, replace) title("Share of HP: Weekday") subtitle("CE Interview")
graph combine mix,  xsize(10) ysize(5) nocopies
graph export fnl_data\share_wday_cei1.png	, replace   

*** Super

 graph hbar supover_rp_wday supnover_rp_wday  if survey2==1 & dchild==1 [w=anwgt], stack over(wsc) percent legend(col(4) order(1 "Overlapping Sup Care" 2 "Non-overlapping Sup Care"  )) ytitle("") subtitle("Regression Prediction") name(m1, replace) graphregion(margin(tiny))
 
 graph hbar supover_sm_wday supnover_sm_wday   if survey2==1 & dchild==1 [w=anwgt], stack over(wsc) percent legend(col(4) order(1 "Overlapping Sup Care" 2 "Non-overlapping Sup Care"  ))  ytitle("") subtitle("Statistical Matching") name(m2, replace) graphregion(margin(tiny))
 
 graph hbar iisupover_1_wday iisupnover_1_wday if survey2==1 & dchild==1 [w=anwgt], stack over(wsc) percent legend(col(4) order(1 "Overlapping Sup Care" 2 "Non-overlapping Sup Care"  ))  ytitle("") subtitle("Multiple Imputation") name(m3, replace) graphregion(margin(tiny))
 
 graph hbar supover_sm_wday supnover_sm_wday  if survey2==4 & dchild==1 [w=anwgt], stack over(wsc) percent legend(col(4) order(1 "Overlapping Sup Care" 2 "Non-overlapping Sup Care"  ))  ytitle("") subtitle("ATUS Weekday") name(m4, replace) graphregion(margin(tiny)) 
  
grc1leg m1 m2 m3 m4, col(4)	   nocopies xcommon name(mix, replace) title("Share of Sup Care: Weekday") subtitle("CE Interview")
graph combine mix,  xsize(10) ysize(5) nocopies

graph export fnl_data\share_wday_cei2.png	, replace   

******


 graph hbar cook_rp_wend hwork_rp_wend ccare_rp_wend acare_rp_wend   if survey2==1 [w=anwgt], stack over(wsc) percent legend(col(4) order(1 "Cooking" 2 "Oth House Work" 3 "Child Care" 4 "Adult Care")) ytitle("") subtitle("Regression Prediction") name(m1, replace) graphregion(margin(tiny))
 
 graph hbar cook_sm_wend hwork_sm_wend ccare_sm_wend acare_sm_wend   if survey2==1 [w=anwgt], stack over(wsc) percent legend(col(4) order(1 "Cooking" 2 "Oth House Work" 3 "Child Care" 4 "Adult Care")) ytitle("") subtitle("Statistical Matching") name(m2, replace) graphregion(margin(tiny))
 
 graph hbar iicook_1_wend iihwork_1_wend  iiccare_1_wend iiacare_1_wend  if survey2==1 [w=anwgt], stack over(wsc) percent legend(col(4) order(1 "Cooking" 2 "Oth House Work" 3 "Child Care" 4 "Adult Care")) ytitle("") subtitle("Multiple Imputation") name(m3, replace) graphregion(margin(tiny))
 
 graph hbar cook_sm_wend hwork_sm_wend ccare_sm_wend acare_sm_wend   if survey2==5 [w=anwgt], stack over(wsc) percent legend(col(4) order(1 "Cooking" 2 "Oth House Work" 3 "Child Care" 4 "Adult Care")) ytitle("") subtitle("ATUS Weekday") name(m4, replace) graphregion(margin(tiny)) 
  
grc1leg m1 m2 m3 m4, col(4)	   nocopies xcommon name(mix, replace) title("Share of HP: Weekend") subtitle("CE Interview")
graph combine mix,  xsize(10) ysize(5) nocopies
graph export fnl_data\share_wend_cei1.png	, replace   

*** Super

 graph hbar supover_rp_wend supnover_rp_wend  if survey2==1 & dchild==1 [w=anwgt], stack over(wsc) percent legend(col(4) order(1 "Overlapping Sup Care" 2 "Non-overlapping Sup Care"  )) ytitle("") subtitle("Regression Prediction") name(m1, replace) graphregion(margin(tiny))
 
 graph hbar supover_sm_wend supnover_sm_wend   if survey2==1 & dchild==1 [w=anwgt], stack over(wsc) percent legend(col(4) order(1 "Overlapping Sup Care" 2 "Non-overlapping Sup Care"  ))  ytitle("") subtitle("Statistical Matching") name(m2, replace) graphregion(margin(tiny))
 
 graph hbar iisupover_1_wend iisupnover_1_wend if survey2==1 & dchild==1 [w=anwgt], stack over(wsc) percent legend(col(4) order(1 "Overlapping Sup Care" 2 "Non-overlapping Sup Care"  ))  ytitle("") subtitle("Multiple Imputation") name(m3, replace) graphregion(margin(tiny))
 
 graph hbar supover_sm_wend supnover_sm_wend  if survey2==5 & dchild==1 [w=anwgt], stack over(wsc) percent legend(col(4) order(1 "Overlapping Sup Care" 2 "Non-overlapping Sup Care"  ))  ytitle("") subtitle("ATUS Weekday") name(m4, replace) graphregion(margin(tiny)) 
  
grc1leg m1 m2 m3 m4, col(4)	   nocopies xcommon name(mix, replace) title("Share of Sup Care: Weekend") subtitle("CE Interview")
graph combine mix,  xsize(10) ysize(5) nocopies

graph export fnl_data\share_wend_cei2.png	, replace   


*** Summary by groups
**************************

tabstat thp_levy_rp_wday thp_levy_sm_wday thp_levy_mi1_wday if survey2==1 [w=anwgt], by(clust_100) save stats(mean)
capture matrix drop mnall mnall_t
forvalues i = 1/100 {
	matrix mnall=nullmat(mnall)\r(Stat`i')
}
tabstat thp_levy_rp_wday if survey2==4 [w=anwgt], by(clust_100) save stats(mean)
forvalues i = 1/100 {
	matrix mnall_t=nullmat(mnall_t)\r(Stat`i')
}
matrix mnall=mnall,mnall_t

capture frame create new
frame new: {
	clear
	svmat mnall
	replace mnall1=mnall1 -mnall4  
	replace mnall2=mnall2 -mnall4
	replace mnall3=mnall3 -mnall4
	gen n=_n
	joy_plot mnall1 mnall2 mnall3   , legend(order(1 "RP" 2 "SM" 3 "MI") row(1)) ///
	name(m1, replace) subtitle("Cell Error: Mean") dadj(2) notext
}

tabstat  thp_levy_rp_wday thp_levy_sm_wday thp_levy_mi1_wday if survey2==1 [w=anwgt], by(clust_100) save stats(median)
matrix drop mnall mnall_t
forvalues i = 1/100 {
	matrix mnall=nullmat(mnall)\r(Stat`i')
}
tabstat thp_levy_rp_wday if survey2==4 [w=anwgt], by(clust_100) save stats(median)
forvalues i = 1/100 {
	matrix mnall_t=nullmat(mnall_t)\r(Stat`i')
}
matrix mnall=mnall,mnall_t

capture frame create new
frame new: {
	clear
	svmat mnall
	replace mnall1=mnall1 -mnall4  
	replace mnall2=mnall2 -mnall4
	replace mnall3=mnall3 -mnall4
	gen n=_n
	joy_plot mnall1 mnall2 mnall3   , legend(order(1 "RP" 2 "SM" 3 "MI") row(1)) notext ///
	name(m2, replace) subtitle("Cell Error: Median") dadj(2)
}

tabstat thp_levy_rp_wday thp_levy_sm_wday thp_levy_mi1_wday if survey2==1 [w=anwgt], by(clust_100) save stats(sd)
matrix drop mnall mnall_t
forvalues i = 1/100 {
	matrix mnall=nullmat(mnall)\r(Stat`i')
}
tabstat thp_levy_rp_wday if survey2==4 [w=anwgt], by(clust_100) save stats(sd) 
forvalues i = 1/100 {
	matrix mnall_t=nullmat(mnall_t)\r(Stat`i')
}
matrix mnall=mnall,mnall_t

capture frame create new
frame new: {
	clear
	svmat mnall
	replace mnall1=mnall1 -mnall4  
	replace mnall2=mnall2 -mnall4
	replace mnall3=mnall3 -mnall4
	gen n=_n
	joy_plot mnall1 mnall2 mnall3   , legend(order(1 "RP" 2 "SM" 3 "MI") row(1)) notext ///
	name(m3, replace) subtitle("Cell Error: Std Dev") dadj(2)
}
 
grc1leg m1 m2 m3, title("Total time on Household Production: Weekday") col(3) nocopies name(mix, replace)
graph combine mix, xsize(10)


graph export fnl_data\thp_wday_cei.png	, replace   

*************************************************************

tabstat thp_levy_rp_wend thp_levy_sm_wend thp_levy_mi1_wend if survey2==1 [w=anwgt], by(clust_100) save stats(mean)
matrix drop mnall mnall_t
forvalues i = 1/100 {
	matrix mnall=nullmat(mnall)\r(Stat`i')
}
tabstat thp_levy_rp_wend if survey2==5 [w=anwgt], by(clust_100) save stats(mean)
forvalues i = 1/100 {
	matrix mnall_t=nullmat(mnall_t)\r(Stat`i')
}
matrix mnall=mnall,mnall_t

capture frame create new
frame new: {
	clear
	svmat mnall
	replace mnall1=mnall1 -mnall4  
	replace mnall2=mnall2 -mnall4
	replace mnall3=mnall3 -mnall4
	gen n=_n
	joy_plot mnall1 mnall2 mnall3   , legend(order(1 "RP" 2 "SM" 3 "MI") row(1)) ///
	name(m1, replace) subtitle("Cell Error: Mean") dadj(2) notext
}

tabstat  thp_levy_rp_wend thp_levy_sm_wend thp_levy_mi1_wend if survey2==1 [w=anwgt], by(clust_100) save stats(median)
matrix drop mnall mnall_t
forvalues i = 1/100 {
	matrix mnall=nullmat(mnall)\r(Stat`i')
}
tabstat thp_levy_rp_wend if survey2==5 [w=anwgt], by(clust_100) save stats(median)
forvalues i = 1/100 {
	matrix mnall_t=nullmat(mnall_t)\r(Stat`i')
}
matrix mnall=mnall,mnall_t

capture frame create new
frame new: {
	clear
	svmat mnall
	replace mnall1=mnall1 -mnall4  
	replace mnall2=mnall2 -mnall4
	replace mnall3=mnall3 -mnall4
	gen n=_n
	joy_plot mnall1 mnall2 mnall3   , legend(order(1 "RP" 2 "SM" 3 "MI") row(1)) notext ///
	name(m2, replace) subtitle("Cell Error: Median") dadj(2)
}

tabstat thp_levy_rp_wend thp_levy_sm_wend thp_levy_mi1_wend if survey2==1 [w=anwgt], by(clust_100) save stats(sd)
matrix drop mnall mnall_t
forvalues i = 1/100 {
	matrix mnall=nullmat(mnall)\r(Stat`i')
}
tabstat thp_levy_rp_wend if survey2==5 [w=anwgt], by(clust_100) save stats(sd) 
forvalues i = 1/100 {
	matrix mnall_t=nullmat(mnall_t)\r(Stat`i')
}
matrix mnall=mnall,mnall_t

capture frame create new
frame new: {
	clear
	svmat mnall
	replace mnall1=mnall1 -mnall4  
	replace mnall2=mnall2 -mnall4
	replace mnall3=mnall3 -mnall4
	gen n=_n
	joy_plot mnall1 mnall2 mnall3   , legend(order(1 "RP" 2 "SM" 3 "MI") row(1)) notext ///
	name(m3, replace) subtitle("Cell Error: Std Dev") dadj(2)
}
 
grc1leg m1 m2 m3, title("Total time on Household Production: Weekend") col(3) nocopies name(mix, replace)
graph combine mix, xsize(10)


graph export fnl_data\thp_wend_cei.png	, replace   

***********************************************************************************************
***********************************************************************************************
preserve
keep if dchild==1
tabstat thp_sup_rp_wday thp_sup_sm_wday thp_sup_mi1_wday if survey2==1 [w=anwgt], by(clust_100) save stats(mean)
capture matrix drop mnall mnall_t
forvalues i = 1/100 {
	matrix mnall=nullmat(mnall)\r(Stat`i')
}
tabstat thp_sup_rp_wday if survey2==4 [w=anwgt], by(clust_100) save stats(mean)
forvalues i = 1/100 {
	matrix mnall_t=nullmat(mnall_t)\r(Stat`i')
}
matrix mnall=mnall,mnall_t

capture frame create new
frame new: {
	clear
	svmat mnall
	replace mnall1=mnall1 -mnall4  
	replace mnall2=mnall2 -mnall4
	replace mnall3=mnall3 -mnall4
	gen n=_n
	joy_plot mnall1 mnall2 mnall3   , legend(order(1 "RP" 2 "SM" 3 "MI") row(1)) ///
	name(m1, replace) subtitle("Cell Error: Mean") dadj(2) notext
}

tabstat  thp_sup_rp_wday thp_sup_sm_wday thp_sup_mi1_wday if survey2==1 [w=anwgt], by(clust_100) save stats(median)
matrix drop mnall mnall_t
forvalues i = 1/100 {
	matrix mnall=nullmat(mnall)\r(Stat`i')
}
tabstat thp_sup_rp_wday if survey2==4 [w=anwgt], by(clust_100) save stats(median)
forvalues i = 1/100 {
	matrix mnall_t=nullmat(mnall_t)\r(Stat`i')
}
matrix mnall=mnall,mnall_t

capture frame create new
frame new: {
	clear
	svmat mnall
	replace mnall1=mnall1 -mnall4  
	replace mnall2=mnall2 -mnall4
	replace mnall3=mnall3 -mnall4
	gen n=_n
	joy_plot mnall1 mnall2 mnall3   , legend(order(1 "RP" 2 "SM" 3 "MI") row(1)) notext ///
	name(m2, replace) subtitle("Cell Error: Median") dadj(2)
}

tabstat thp_sup_rp_wday thp_sup_sm_wday thp_sup_mi1_wday if survey2==1 [w=anwgt], by(clust_100) save stats(sd)
matrix drop mnall mnall_t
forvalues i = 1/100 {
	matrix mnall=nullmat(mnall)\r(Stat`i')
}
tabstat thp_sup_rp_wday if survey2==4 [w=anwgt], by(clust_100) save stats(sd) 
forvalues i = 1/100 {
	matrix mnall_t=nullmat(mnall_t)\r(Stat`i')
}
matrix mnall=mnall,mnall_t

capture frame create new
frame new: {
	clear
	svmat mnall
	replace mnall1=mnall1 -mnall4  
	replace mnall2=mnall2 -mnall4
	replace mnall3=mnall3 -mnall4
	gen n=_n
	joy_plot mnall1 mnall2 mnall3   , legend(order(1 "RP" 2 "SM" 3 "MI") row(1)) notext ///
	name(m3, replace) subtitle("Cell Error: Std Dev") dadj(2)
}
 
grc1leg m1 m2 m3, title("Total time on Sup. Care: Weekday") col(3) nocopies name(mix, replace)
graph combine mix, xsize(10)


graph export fnl_data\tsup_wday_cei.png	, replace   

*************************************************************

tabstat thp_sup_rp_wend thp_sup_sm_wend thp_sup_mi1_wend if survey2==1 [w=anwgt], by(clust_100) save stats(mean)
matrix drop mnall mnall_t
forvalues i = 1/100 {
	matrix mnall=nullmat(mnall)\r(Stat`i')
}
tabstat thp_sup_rp_wend if survey2==5 [w=anwgt], by(clust_100) save stats(mean)
forvalues i = 1/100 {
	matrix mnall_t=nullmat(mnall_t)\r(Stat`i')
}
matrix mnall=mnall,mnall_t

capture frame create new
frame new: {
	clear
	svmat mnall
	replace mnall1=mnall1 -mnall4  
	replace mnall2=mnall2 -mnall4
	replace mnall3=mnall3 -mnall4
	gen n=_n
	joy_plot mnall1 mnall2 mnall3   , legend(order(1 "RP" 2 "SM" 3 "MI") row(1)) ///
	name(m1, replace) subtitle("Cell Error: Mean") dadj(2) notext
}

tabstat  thp_sup_rp_wend thp_sup_sm_wend thp_sup_mi1_wend if survey2==1 [w=anwgt], by(clust_100) save stats(median)
matrix drop mnall mnall_t
forvalues i = 1/100 {
	matrix mnall=nullmat(mnall)\r(Stat`i')
}
tabstat thp_sup_rp_wend if survey2==5 [w=anwgt], by(clust_100) save stats(median)
forvalues i = 1/100 {
	matrix mnall_t=nullmat(mnall_t)\r(Stat`i')
}
matrix mnall=mnall,mnall_t

capture frame create new
frame new: {
	clear
	svmat mnall
	replace mnall1=mnall1 -mnall4  
	replace mnall2=mnall2 -mnall4
	replace mnall3=mnall3 -mnall4
	gen n=_n
	joy_plot mnall1 mnall2 mnall3   , legend(order(1 "RP" 2 "SM" 3 "MI") row(1)) notext ///
	name(m2, replace) subtitle("Cell Error: Median") dadj(2)
}

tabstat thp_sup_rp_wend thp_sup_sm_wend thp_sup_mi1_wend if survey2==1 [w=anwgt], by(clust_100) save stats(sd)
matrix drop mnall mnall_t
forvalues i = 1/100 {
	matrix mnall=nullmat(mnall)\r(Stat`i')
}
tabstat thp_sup_rp_wend if survey2==5 [w=anwgt], by(clust_100) save stats(sd) 
forvalues i = 1/100 {
	matrix mnall_t=nullmat(mnall_t)\r(Stat`i')
}
matrix mnall=mnall,mnall_t

capture frame create new
frame new: {
	clear
	svmat mnall
	replace mnall1=mnall1 -mnall4  
	replace mnall2=mnall2 -mnall4
	replace mnall3=mnall3 -mnall4
	gen n=_n
	joy_plot mnall1 mnall2 mnall3   , legend(order(1 "RP" 2 "SM" 3 "MI") row(1)) notext ///
	name(m3, replace) subtitle("Cell Error: Std Dev") dadj(2)
}
 
grc1leg m1 m2 m3, title("Total time on Sup. Care: Weekend") col(3) nocopies name(mix, replace)
graph combine mix, xsize(10)


graph export fnl_data\tsup_wend_cei.png	, replace   
