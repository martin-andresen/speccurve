*! speccurve v1.1, 26082020
* Author: Martin Eckhoff Andresen

cap program drop speccurve panelparse speccurverun sortpreserve addcoefparse savecoefs

program define speccurve
	version 16.0
	
	preserve
	
	loc panelno=0
	loc controlpanelno=0
	while `"`0'"' ! = "" {
		gettoken mac 0: 0, parse(" ") bind
		if substr("`mac'",1,5)=="panel" {
			loc panels `panels' `mac'
			loc ++panelno
			}
		else if substr("`mac'",1,8)=="controls" {
			loc ++panelno
			loc controlpanelno=`panelno'
			if strpos("`mac'","(")>0 loc content `=substr("`mac'",strpos("`mac'","(")+1,`=strlen("`mac'")-strpos("`mac'","(")-1')'
			while "`content'"!="" {
				gettoken tok content: content, parse(" ") bind
				if substr("`tok'",1,6)=="labels" loc controllabels `=substr("`tok'",8,`=strlen("`tok'")-8')'
				else if substr("`tok'",1,5)=="title" loc controltitle `=substr("`tok'",7,`=strlen("`tok'")-7')'
				else if substr("`tok'",1,10)=="graphopts" loc controlgraphopts `=substr("`tok'",12,`=strlen("`tok'")-12')'
				else {
					noi di in red "Suboption `tok' not allowed in controls()."
					exit 301
					}
				}
			}
		else loc syntax `syntax' `mac'
		}
	
	speccurverun `syntax' panels(`panels') controlpanelno(`controlpanelno') controlgraphopts(`controlgraphopts') controltitle(`controltitle') controllabels(`controllabels')


	end


* Author: Martin Eckhoff Andresen
* Inspired by Uri Simonsohn, Joseph Simmons and Leif D. Nelson's paper on the specification curve and Hans H. Sievertsen @ Twitter

	program define speccurverun, rclass
		version 15.0
		
		syntax [anything] [using/] , param(name) [controlpanelno(integer 0) addcoef(string) controlpanel graphopts(string) controltitle(string) controllabels(string) controlgraphopts(string) main(string) panels(string) keep(numlist min=3 max=3 >=0 integer) level(numlist min=1 max=2 ascending integer >0 <100) title(string) sort(name) save(name) fill addscalar(string)]
		
		
		qui {
			tempvar spec coefs r keepvar bin
			tempfile output
			
			loc numpanels=0
			while "`panels'"!="" {
				loc ++numpanels
				if `numpanels'==`controlpanelno' continue
				gettoken panel panels: panels, bind
				panelparse `=substr("`panel'",7,strlen("`panel'")-7)'
				loc panelvars`numpanels' `=s(panelvars)'
				loc numvars`numpanels'=s(numvars)
				loc labels`numpanels' `=s(labels)'
				if "`=s(graphopts)'"!="." loc graphopts`numpanels' `=s(graphopts)'
				if "`=s(title)'"!="." loc title`numpanels' `=s(title)'
				loc panelvars `panelvars' `panelvars`numpanels''
				}
			if `controlpanelno'>`numpanels' loc ++numpanels
			
			//sort option
			if !inlist("`sort'","none","") {
				loc sortvar `sort'		
				}
			
			//control main opt
			if "`main'"!="" {
				loc nummain: word count `main'
				if `nummain'>1 {
					noi di in red "Specify only one word or number in main(), corresponding to the name or number of the main specification."
					exit 301
					}
				}
			
			//levels option
			if "`level'"=="" loc level 90 95
			loc numlevel: word count `level'
			loc i=0
			foreach lev in `level' {
				loc ++i
				loc level`i'=`lev'
				}
			
			//Parse addcoef() option
			if "`addcoef'"!="" {
				addcoefparse `addcoef'
				loc namelistaddcoef `s(namelist)'
				loc paramaddcoef `s(param)'
				loc addcoeftitle `s(title)'
				loc samemodel `s(samemodel)'
				loc addcoefusing `s(using)'
				loc addcoefscalar `s(scalar)'
				loc addcoefgraphopts `s(graphopts)'
				tempfile addcoefdata
			}
			
			//parse addscalar() option

			if "`addscalar'"!="" {
				addscalarparse `addscalar'
				loc addscalar `s(namelist)'
				loc addscalartitle `s(title)'
				loc addscalargraphopts `s(graphopts)'
				}
			
	
		//Create dataset from estimates
		clear
		foreach var in estimate `panelvars' `sortvar' `addscalar' modelno {
			cap gen `var'=.
			}
		gen parm=""
		gen name=""
		foreach lev in `level' {	
			gen min`lev'=.
			gen max`lev'=.
			}
		
		if "`using'"!="" { //if taking data from .ster file
			cap estimates describe using `using'
			if _rc!=0 {
				noi di in red "Using file `using'.ster not found."
				exit 301
				}
			forvalues i=1/`=r(nestresults)' {
				estimates use `using', number(`i')
				loc modname `e(estimates_title)'
				if "`anything'"!="" {
					loc numwordstitle: word count `modname'
					if `numwordstitle'>1 {
						noi di in red "Use only one-word names for estimates titles when storing them on disk and specifying namelist. Estimate `modname' contains more than one word."
						exit 301
						}
					}
				if `controlpanelno'!=0 loc colnames: colnames e(b)
				else if "`addcoef'"!="" loc colnames `param' `paramaddcoef'
				else loc colnames `param'
				savecoefs `colnames', level(`level') scalars(`panelvars' `sortvar' `addscalar')
				replace modelno=`i' if modelno==.
				replace name="`modname'" if name==""
				}
			if "`anything'"!="" {
				gen `keepvar'==0
				foreach okname in `anything' {
					replace `keepvar'=1 if strmatch(name,"`okname'")==1
					}
				drop if `keepvar'==0
				drop `keepvar'
				levelsof name, local(namelist)
				}

			}
			
		else { //when taking estimates from memory
			est dir `anything'
			loc namelist `=r(names)'
			loc i=0
			foreach est in `namelist' {
				loc ++i
				est restore `est'
				if `controlpanelno'!=0 loc colnames: colnames e(b)
				else if "`addcoef'"!=""&"`samemodel'"!="" loc colnames `param' `paramaddcoef'
				else loc colnames `param'
				savecoefs `colnames', level(`level') scalars(`panelvars' `sortvar' `addscalar')
				replace name="`est'" if name==""
				replace modelno=`i' if modelno==.
				}
			}
		
		drop if parm=="_cons"
		
		

		//automatic control panel
		if `controlpanelno'!=0 {
			
			if "`samemodel'"=="" levelsof parm if parm!="`param'", local(parmlist) clean
			else levelsof parm if parm!="`param'"&parm!="`paramaddcoef'", local(parmlist) clean
			gen byte `bin'=.
			loc c=0
			foreach parm in `parmlist' {
					loc ++c
					replace `bin'=parm=="`parm'"
					bys name: egen `parm'=max(`bin')
					loc panelvars`controlpanelno' `panelvars`controlpanelno'' `parm'
					}
			local numvars`controlpanelno': word count `panelvars`controlpanelno''
			if "`controltitle"!="" loc title`controlpanelno' `controltitle'
			if "`controllabels'"!="" loc labels`controlpanelno' `controllabels'
			else loc labels`controlpanelno' `parmlist'
			loc graphopts`controlpanelno' `controlgraphopts'
			
			
			}
		
		if "`samemodel'"!="" keep if inlist(parm,"`param'","`paramaddcoef'")
		else keep if parm=="`param'"
		
		//addcoef option
		if "`addcoef'"!="" {
			if "`samemodel'"=="" {
					if "`addcoefusing'"!="" { //when taking addcoef estimates from file
					cap estimates describe using `addcoefusing'
					if _rc!=0 {
						noi di in red "Using file `addcoefusing'.ster not found."
						exit 301
						}
					forvalues i=1/`=r(nestresults)' {
						estimates use `addcoefusing', number(`i')
						loc modname `e(estimates_title)'
						if "`namelistaddcoef'"!="" {
							loc numwordstitle: word count `e(estimates_title)'
							if `numwordstitle'>1 {
								noi di in red "Use only one-word names for estimates titles when storing them on disk and specifying namelist. Estimate `modname' contains more than one word."
								exit 301
								}
							}
						savecoefs `paramaddcoef', level(`level')
						replace modelno=`i' if modelno==.
						replace name="`modname'" if name==""
						}
					if "`namelistaddcoef'"!="" {
						gen `keepvar'=0
						foreach okname in `anything' {
							replace `keepvar'=1 if strmatch(name,"`okname'")==1
							}
						drop if `keepvar'==0
						drop `keepvar'
						}

				}
			
				else { //when taking estimates from memory
					est dir `namelistaddcoef'
					loc namelistaddcoef `=r(names)'
					loc i=0
					foreach est in `namelistaddcoef' {
						loc ++i
						est restore `est'
						savecoefs `paramaddcoef', level(`level')
						replace name="`est'" if name==""
						replace modelno=`i' if modelno==.
						}
					}
				}
		
		keep if inlist(parm,"`param'","`paramaddcoef'")
		gen n=1 if parm=="`param'"
		replace n=2 if parm=="`paramaddcoef'"
		keep min* max* estimate modelno name n parm `panelvars' `sortvar' `panelvars`controlpanelno''
		reshape wide estimate min* max* parm name `panelvars' `sortvar' `panelvars`controlpanelno'', i(modelno) j(n)
		foreach var in name `panelvars' `sortvar' `panelvars`controlpanelno'' {
			drop `var'2
			rename `var'1 `var'
			}
		fvexpand min* max* estimate* parm*
		foreach var in `r(varlist)' {
			if substr("`var'",-1,1)=="1" rename `var' `=substr("`var'",1,strlen("`var'")-1)'
			else rename `var' `=substr("`var'",1,strlen("`var'")-1)'_a
			}	
		}
		
		
		//finalize dataset
		if "`sort'"!="none" {
			if "`sort'"=="" sort estimate
			else sort `sortvar'
			}
		gen `spec'=_n
		
		loc Nspec=_N
		if "`save'"!="" save `save', replace
			
		//DROP ESTIMATES IF KEEP() option specified
		if "`keep'"!="" {
			if "`sort'"!="" {
				noi di in red "Do not combine sort() and keep() options - keep requires default sorting on estimate size."
				exit 301
				}
			gettoken keep1 keep: keep
			gettoken keep2 keep3: keep
			if `keep1'+`keep2'+`keep3'>=`Nspec' {
				noi di as text "Sum of number of specifications to keep specified in keep() is larger than or equal to the total number of specifications. Option keep() ignored".
				loc keep
				}
			else {
				tempvar dum run
				gen `r'=runiform()
				gen `dum'=name=="`main'"
				sort `dum' `spec'
				bys `dum': gen `run'=_n
				gen `keepvar'=(`dum'==1|`run'<=`keep1'|`run'>=_N-`keep3')
				sort `keepvar' `r'
				bys `keepvar': replace `keepvar'=1 if _n<=`keep2'&`keepvar'==0
				drop if `keepvar'!=1
				sort estimate
				replace `spec'=_n
				su `spec'
				loc Nspec=_N
				if "`main'"!="" {
					su `spec' if name=="`main'"
					if r(mean)<=`=`keep1'+`keep2'' {
						loc xline2=`keep1'+`keep2'+1.5
						if r(mean)<=`keep1' loc xline1=`keep1'+1.5
						}
					}
				if "`main'"==""|"`xline1'"=="" loc xline1=`keep1'+0.5
				if "`main'"==""|"`xline2'"=="" loc xline2=`Nspec'-`keep3'+0.5
				loc xlines xline(`xline1', lpattern(dot)) xline(`xline2', lpattern(dot))
				}
			}
		
		//Determine appropriate scatter symbol size
		loc msize `=4.5/`Nspec''
		loc labsize `=min(`=7/`Nspec'',0.25)'in
		
		//Determine appropriate text size
		loc cols=`numlevel'+1
		if "`main'"!="" {
			loc ++cols
			loc notifmain if name!="`main'"
			loc scattermain (scatter estimate `spec' if name=="`main'", mcolor(maroon) msize(`msize'in) msymbol(diamond))
			if "`addcoef'"!="" loc scattermain_a (scatter estimate_a `spec' if name=="`main'", mcolor(maroon) msize(`msize'in) msymbol(diamond))
			loc labmain label(`=`numlevel'+2' "main")
			loc mainorder=`numlevel'+2
			}

		su min`level`numlevel''
		loc ymin=r(min)
		
		if "`addcoef'"!="" {
			su min`level`numlevel''_a
			loc ymin_a=r(min)
			}
		
		if "`addscalar'"!="" {
			su `addscalar'
			loc minscalar=r(min)
			}
		
		if `numlevel'==2 loc orderci 1 2
		else loc orderci 1
		
		//Phantom labels, to align panels
		if `numpanels'>0 {
			forvalues pan=1/`numpanels' {
				foreach i in `labels`pan'' {
					loc phantomlabs `phantomlabs' `ymin'  "`i'"
					loc phantomlabsscat `phantomlabsscat' 1 "`i'"
					if "`addcoef'"!="" loc phantomlabs_a `phantomlabs_a' `ymin_a'  "`i'"
					if "`addscalar'"!="" loc phantomlabs_s `phantomlabs_s' `minscalar'  "`i'"
					}
				}
			
			
			loc extraylabs ylabel(`phantomlabs', add custom  labcolor(white%0) labsize(`labsize') angle(horizontal) tlcolor(white%0))
			if "`addcoef'"!="" loc extraylabs_a ylabel(`phantomlabs_a', add custom  labcolor(white%0) labsize(`labsize') angle(horizontal) tlcolor(white%0))
			if "`addscalar'"!="" loc extraylabs_s ylabel(`phantomlabs_s', add custom  labcolor(white%0) labsize(`labsize') angle(horizontal) tlcolor(white%0))
			loc extraylabsscat ylabel(`phantomlabsscat', add custom  labcolor(white%0) labsize(`labsize') angle(horizontal) tlcolor(white%0))	
			}
		

		loc i=0
		foreach level in `level' {
			loc ++i
			loc rbars  (rbar min`level`i'' max`level`i'' `spec', color(gs`=10+2*`i'') lwidth(none)) `rbars'
			if "`addcoef'"!=""	loc rbarsaddcoef (rbar min`level`i''_a max`level`i''_a `spec', color(gs`=10+2*`i'') lwidth(none)) `rbarsaddcoef'
			loc labels `labels'  label(`i' "`level`i''% CI")
			loc varnamesci `varnamesci' min`level' max`level'
			}
		
		//Determine relative sizes of panels
		if "`title'"!="" loc ysizemain=4.3
		else loc ysizemain=4
		loc ysize=`ysizemain'
		if `numpanels'>0 {
				forvalues pan=1/`numpanels' {
				if "`title`pan''"=="" loc ysize`pan'=`msize'*(`numvars`pan''+1)+0.1
				else loc ysize`pan'=`msize'*(`numvars`pan''+1)+0.4
				loc ysize=`ysize'+`ysize`pan''
				}
			}
		if "`addcoef'"!="" {
			if "`addcoeftitle'"!="" loc ysizeaddcoef =4.3
			else loc ysizeaddcoef=4
			loc ysize=`ysize'+`ysizeaddcoef'
			}
		
		if "`addscalar'"!="" {
			if "`addscalartitle'"=="" loc ysizeaddscalar=4
			else loc ysizeaddscalar=4.3
			loc ysize=`ysize'+`ysizeaddscalar'
			}
			
		//Plot estimates
		if `numpanels'>0|"`addcoef'"!=""|"`addscalar'"!="" {
			loc nodraw nodraw
			loc coefname `coefs'
			loc margins 0 0 0 0
			}
		else loc coefname speccurve
		
		twoway 	`rbars' (scatter estimate `spec' `notifmain', mcolor(black) msize(`msize'in) msymbol(circle)) `scattermain'  ///
				, name(`coefname', replace) scheme(s2mono) xscale(range(0.5 `=`Nspec'+0.5')) ///
				xlabel(none) xtitle("") graphregion(color(white)) plotregion(lcolor(black)) `xlines' ///
				title(`title', size(0.3in)) ylabel(#6,  nogrid) ytitle("coefficient on `param'") ///
				`extraylabs' `nodraw'    plotregion(margin(0.5 0.5 0.5 0.5)) graphregion(margin(`margins')) ///
				yline(0, lpattern(dash)) fysize(`=150*`ysizemain'/`ysize'')  legend(`labels' label(`=`numlevel'+1' "estimates") `labmain' cols(`cols') order(`mainorder' `=`numlevel'+1' `orderci') position(5) ring(0))  `graphopts'
				
		
		//plot specification panel(s) + control panel
		if `numpanels'>0 {
		
			if strpos("`graphopts'","ytitle("")")>0&strpos("`addcoefgraphopts'","ytitle("")")>0&strpos("`addscalargraphopts'","ytitle("")")>0 loc pad
			else loc pad pad
				
			loc j=0
			forvalues pan=1/`numpanels' {
				
				loc labels
				loc i=0
				foreach lab in `labels`pan'' {
					loc ++i
					loc labels `labels' `=`numvars`pan''+1-`i'' "`lab'"
					}
				
				loc two
				loc k=0
				foreach i in `panelvars`pan'' {
					loc ++j
					loc ++k
					cap gen y`j'=`=`numvars`pan''+1-`k''
					levelsof `i', local(tmp)
					loc vals: word count `tmp'
					loc bin=0
					foreach val in `tmp' {
						if inlist(`val',0,1) loc bin=`bin'+1 
						}
					if "`fill'"!="" loc fillstr |`i'==.
					if (`bin'==2&`vals'==2)|(`bin'==1&`vals'==1) { //plot scatters with dots
						loc two `two' (scatter y`j' `spec' if `i'==1&name!="`main'", msymbol(circle) mcolor(black) msize(`msize'in) mlwidth(vthin)) ///
						(scatter y`j' `spec' if `i'==0`fillstr'&name!="`main'", msymbol(circle_hollow) mlcolor(gs0) mcolor(white) msize(`msize'in) mlwidth(vthin)) ///
						(scatter y`j' `spec' if `i'==1&name=="`main'", msymbol(circle) mcolor(maroon) msize(`msize'in) mlwidth(vthin)) ///
						(scatter y`j' `spec' if `i'==0`fillstr'&name=="`main'", msymbol(circle_hollow) mlcolor(maroon) mcolor(white) msize(`msize'in) mlwidth(vthin))
						}
					else { //plot scatters with numbers/values
						loc two `two' 	(scatter y`j' `spec' if name!="`main'"&`i'!=., mlabel(`i') mlabpos(0) msymbol(i) mlabsize(`msize'in)) ///
										(scatter y`j' `spec' if name=="`main'"&`i'!=., mlabel(`i') mlabpos(0) msymbol(i) mlabcolor(maroon) mlabsize(`msize'in)) 
						}
					}
				
				tempvar plot`pan'
				twoway `two', nodraw ylabels(`labels', angle(horizontal) labsize(`labsize') nogrid) `extraylabsscat'  ///
						scheme(s2mono) xscale(range(0.5 `=`Nspec'+0.5')) yscale(range(0.5 `=`numvars`pan''+0.5')) ///
						xlabel(none) xtitle("") legend(off) title(`title`pan'', size(0.3in))  ///
						plotregion(margin(0.5 0.5 0.5 0.5)) graphregion(margin(0 0 0 0)) ///
						graphregion(color(white)) plotregion(lcolor(black)) yscale(range(0.5 `=`numvars`pan''+0.5')) name(`plot`pan'', replace) fysize(`=150*`ysize`pan''/`ysize'') ysize(`ysize`pan'') ytitle("`pad'", color(white%0) ) `graphopts`pan''
				
				loc scatters `scatters' `plot`pan'' 
			}
			
		
		}
		
		//Plot additional coefficients or scalars from addcoef() or addscalar(
		if "`addcoef'"!="" {
				tempname addcoef1
				twoway 	`rbarsaddcoef' (scatter estimate_a `spec' `notifmain', mcolor(black) msize(`msize'in) msymbol(circle)) `scattermain_a' ///
				, name(`addcoef1', replace) scheme(s2mono) xscale(range(0.5 `=`Nspec'+0.5')) ///
				title(`addcoeftitle', size(0.3in)) xlabel(none) xtitle("") graphregion(color(white)) plotregion(lcolor(black)) `xlines' ///
				 ylabel(#6,  nogrid) ytitle("coefficient on `paramaddcoef'") plotregion(margin(0.5 0.5 0.5 0.5)) graphregion(margin(0 0 0 0)) ///
				`extraylabs_a' `nodraw'  ///
				yline(0, lpattern(dash)) legend(off) fysize(`=150*`ysizeaddcoef'/`ysize'') `addcoefraphopts'
			}
		
		if "`addscalar'"!="" {
				tempname addscalar1
				if "`main'"!="" loc scattermain_s (scatter `addscalar' `spec' if name=="`main'", mcolor(maroon) msize(`msize'in) msymbol(diamond))
				twoway 	(scatter `addscalar' `spec' `notifmain', mcolor(black) msize(`msize'in) msymbol(circle)) `scattermain_s' ///
				, name(`addscalar1', replace) scheme(s2mono) xscale(range(0.5 `=`Nspec'+0.5')) ///
				title(`addscalartitle', size(0.3in)) xlabel(none) xtitle("") graphregion(color(white)) plotregion(lcolor(black)) `xlines' ///
				 ylabel(#6,  nogrid) ytitle("`addscalar'") plotregion(margin(0.5 0.5 0.5 0.5)) graphregion(margin(0 0 0 0)) `nodraw'  ///
				yline(0, lpattern(dash)) legend(off) fysize(`=150*`ysizeaddscalar'/`ysize'') `addscalargraphopts' `extraylabs_s'
			}
		
		if `numpanels'>0|"`addcoef'"!=""|"`addscalar'"!="" graph combine `coefs' `scatters' `addcoef1' `addscalar1', cols(1) graphregion(color(white)) imargin(0 0 0 0) ysize(`ysize') name(speccurve, replace)
	
	

	//Add resulting table to r(table)
	rename `spec' specno
	tempname table
	mkmat specno modelno estimate `varnamesci' `panelvars' `panelvars`controlpanelno'' `addscalar', matrix(`table') rownames(name)
	return matrix table=`table'
	
	}
	
end

	
//panelparse version 0.1

program panelparse, sclass
	syntax namelist, [labels(string)) title(string) graphopts(string)]
	loc numvars: word count `namelist'
	sret local numvars=`numvars'
	sret local panelvars `namelist'
	while `"`labels'"'!="" {
		gettoken lab labels: labels
		loc labs `labs' `lab'
		gettoken name namelist: namelist
		}
	while "`namelist'"!="" {
		gettoken name namelist: namelist
		loc labs `labs' `name'
		}
	sret local labels `labs'
	sret local title `title'

	sret local graphopts `graphopts'
end

//addcoefparse

program addcoefparse, sclass
	syntax [anything] [using/], param(name) [title(string) graphopts(string) scalar(name)]
	if strpos("`anything'","samemodel")>0 {
		loc numnames: word count `anything'
		if `numnames'>1 {
			noi di in red "When specifying samemodel in addcoef(), do not specify a namelist - addcoef() coefficients are `param' from main models."
			exit 301 
			}
		loc namelist
		loc samemodel samemodel
		}
	sret local param `param'
	sret local namelist `anything'
	sret local title `title'
	sret local graphopts `graphopts'
	sret local samemodel `samemodel'
	sret local using `using'
	sret local scalar `scalar'

end

//addscalarparse

program addscalarparse, sclass
	syntax name, [title(string) graphopts(string)]
	foreach str in namelist title graphopts {
		sret local `str' ``str''
		}

end



//savecoefs
program savecoefs
syntax [namelist], level(numlist min=1 max=2 ascending integer >0 <100) [scalars(namelist)] 
	loc k=0
	foreach lev in `level' {
		loc ++k
		tempname r`lev'
		eret di, level(`lev')
		mat `r`lev''=r(table)
		loc level`k'=`lev'
		}
		
if "`namelist'"=="" loc namelist: colnames e(b)
loc nparms: word count `namelist' 
loc N=_N
set obs `=_N+`nparms''
foreach var in `scalars' {
	replace `var'=e(`var') if `var'==.
	}
loc j=0
foreach parm in `namelist' {
	loc ++j
	cap replace parm="`parm'" in `=`N'+`j''
	cap replace estimate=`r`level1''[`=rownumb(`r`level1'',"b")',`=colnumb(`r`level1'',"`parm'")'] in `=`N'+`j''
	cap replace min`level1'=`r`level1''[`=rownumb(`r`level1'',"ll")',`=colnumb(`r`level1'',"`parm'")'] in `=`N'+`j''
	cap replace max`level1'=`r`level1''[`=rownumb(`r`level1'',"ul")',`=colnumb(`r`level1'',"`parm'")'] in `=`N'+`j''
	if `k'==2 {
		cap replace min`level2'=`r`level2''[`=rownumb(`r`level2'',"ll")',`=colnumb(`r`level2'',"`parm'")'] in `=`N'+`j''
		cap replace max`level2'=`r`level2''[`=rownumb(`r`level2'',"ul")',`=colnumb(`r`level2'',"`parm'")'] in `=`N'+`j''
		}
	}

end
		
		


