***Qtables for overall sample and for 18-64
*** This is for everyone


qui {
local year `1'
matrix drop _all
    
global server "j:/Shared drives/"
global levy     "$server/levy_distribution/" 
global USLIMTIP     "$levy/Time Poverty/US/" 
global Qtables     "$USLIMTIP/Qtables" 
global rawipums "$USLIMTIP/rawcpsipums"
global rawatus "$USLIMTIP/rawatusipums"
global rawdata "$levy/data/USA/ASEC"
global morgdata "$levy/data/USA/MORG"
global spmdata "$levy/data/USA/SPM"
global savedata "$USLIMTIP/cps_asec"
global atusdata    "$USLIMTIP/rawatusipums/atus_00013.dta"
global save_aggtime "$USLIMTIP/timeuse/agg_time.dta" 
global limtipin  "$USLIMTIP/LIMTIP/input_data"
global redis "$USLIMTIP/LIMTIP/redistribution_simulation/"
		
 
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
        recode hfaminc (1/8=1) (9/11=2) (12/13=3) (14/15=4) (16=5), gen(faminc_q)
		*xtile faminc_q2 = hfaminc [w=fwt], n(5)

		foreach i in race ych  emp_child ntchild ntadult age_group iscouple educ_tb faminc_q  {
			tab `i'
		}

		** First time use
		gen hprod_wkend=ccare_wkend +acare_wkend +core_wkend +proc_wkend
		gen hprod_wkday=ccare_wkday +acare_wkday +core_wkday +proc_wkday

		replace hprod_wkend=ccare +acare  +core  +proc if survey==12
		replace hprod_wkday=ccare +acare  +core  +proc if survey==11



global full sex race ych  emp_child ntchild ntadult age_group iscouple educ_tb faminc_q
global partial $full
_dots 0 0
global rname 
local rname
 foreach i of global full {
    qui:levelsof `i', local(ilevel)
    local zero
    foreach h of global partial {
        if "`i'"!="`h'" local  zero `zero' `h'
    }
    global partial `zero'
    
    foreach j of global partial {
        qui:levelsof `j', local(jlevel)
            
            foreach ii of local ilevel {
                foreach jj of local jlevel {
                    local cnt= `cnt'+1
                    _dots `cnt' 0
                    qui:sum hprod_wkend [w=fwt] if `i' == `ii' & `j' == `jj' & survey <  20 , d
                    matrix bend_d = nullmat(bend_d)\[`ii',`jj',r(N),r(sum_w),r(mean),r(p50),r(sd)]
                    qui:sum hprod_wkend [w=fwt] if `i' == `ii' & `j' == `jj' & survey == 20 , d
                    matrix bend_r = nullmat(bend_r)\[`ii',`jj',r(N),r(sum_w),r(mean),r(p50),r(sd)]
                    qui:sum hprod_wkday [w=fwt] if `i' == `ii' & `j' == `jj' & survey <  20 , d
                    matrix bday_d = nullmat(bday_d)\[`ii',`jj',r(N),r(sum_w),r(mean),r(p50),r(sd)]
                    qui:sum hprod_wkday [w=fwt] if `i' == `ii' & `j' == `jj' & survey == 20 , d
                    matrix bday_r = nullmat(bday_r)\[`ii',`jj',r(N),r(sum_w),r(mean),r(p50),r(sd)]
                    local rname `rname' "`i':`j'"
                }
            }       
            
    }
}
local jj=0
local j="none"
 foreach i of global full {
    qui:levelsof `i', local(ilevel)
    
            foreach ii of local ilevel {
                    local cnt= `cnt'+1
                    _dots `cnt' 0
                    qui:sum hprod_wkend [w=fwt] if `i' == `ii'  & survey <  20 , d
                    matrix bend_d = nullmat(bend_d)\[`ii',`jj',r(N),r(sum_w),r(mean),r(p50),r(sd)]
                    qui:sum hprod_wkend [w=fwt] if `i' == `ii' & survey == 20 , d
                    matrix bend_r = nullmat(bend_r)\[`ii',`jj',r(N),r(sum_w),r(mean),r(p50),r(sd)]
                    qui:sum hprod_wkday [w=fwt] if `i' == `ii' & survey <  20 , d
                    matrix bday_d = nullmat(bday_d)\[`ii',`jj',r(N),r(sum_w),r(mean),r(p50),r(sd)]
                    qui:sum hprod_wkday [w=fwt] if `i' == `ii' & survey == 20 , d
                    matrix bday_r = nullmat(bday_r)\[`ii',`jj',r(N),r(sum_w),r(mean),r(p50),r(sd)]
                    local rname `rname' "`i':`j'"
                }
      }       
 

global rname `rname'

matrix rowname bend_r = $rname
matrix rowname bend_d = $rname
matrix rowname bday_r = $rname
matrix rowname bday_d = $rname
capture frame drop toplot
frame create toplot
matrix colname bend_r = vi vj n wn mean median sd
matrix colname bend_d = vi vj n wn mean median sd
matrix colname bday_r = vi vj n wn mean median sd
matrix colname bday_d = vi vj n wn mean median sd
	frame toplot: {
		clear
		lbsvmat bend_r, row name(end_r) matname
		lbsvmat bend_d, row name(end_d) matname
		lbsvmat bday_r, row name(day_r) matname
		lbsvmat bday_d, row name(day_d) matname

		gen wgtend = end_d_wn/1e6
		gen wgtday = day_d_wn/1e6

 		save "C:/Users/Fernando/Documents/GitHub/uslimtipqm/procdata/qtable_`year'", replace
	}

}

