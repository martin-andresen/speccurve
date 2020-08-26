cap program drop speccurve_gendata
{
	program define speccurve_gendata
		version 15.0
		
		syntax
	
	preserve
	
	cap which estadd
	if _rc!=0 {
		di in red "You need the estout package to add scalars to stored estimates, see -ssc install estadd-."
		exit 301
		}
	clear all
	sysuse auto, clear
	
	cap rm estiv.ster
	cap rm estfs.ster
	cap rm estmod.ster
	
	//OLS
	tokenize mpg headroom trunk gear_ratio length turn displacement

	loc no=0
	qui forvalues mpg=0/1 {
		forvalues headroom=0/1 {
			forvalues trunk=0/1 {
				forvalues gear_ratio=0/1{
						forvalues length=0/1 { 
							forvalues turn=0/1 {
								forvalues displacement=0/1 {
								loc controls
								forvalues i=1/7 {
									if ```i'''==1 loc controls `controls' ``i''
									}
									loc ++no
									reg price weight `controls'
									estadd scalar no=`no'
									loc numc: word count `controls'
									estadd scalar numcontrols=`numc'
									eststo ols`no'
								}
						}
					}
				}
			}
		}
	}
	
	//IV
	tokenize mpg headroom trunk gear_ratio turn displacement

	loc no=0
	qui forvalues mpg=0/1 {
		forvalues headroom=0/1 {
			forvalues trunk=0/1 {
				forvalues gear_ratio=0/1{
						forvalues turn=0/1 {
							forvalues displacement=0/1 {
								loc controls
								forvalues i=1/6 {
									if ```i'''==1 loc controls `controls' ``i''
								}
										loc ++no
										ivregress 2sls price (weight=length) `controls'
										estadd scalar no=`no'
										loc numc: word count `controls'
										estadd scalar numcontrols=`numc'
										estimates title: iv`no'
										est save estiv, append
										
										reg weight length `controls'
										estadd scalar no=`no'
										loc numc: word count `controls'
										estadd scalar numcontrols=`numc'
										estimates title: fs`no'
										est save estfs, append
									}
							}
						}
					}
				}
			}
			
	//DISCRETE CHOICE EXAMPLES
	tokenize mpg headroom trunk gear_ratio
	
	loc no=0
	
	foreach mod in regress logit probit {
			qui forvalues mpg=0/1 {
				forvalues headroom=0/1 {
					forvalues trunk=0/1 {
						forvalues gear_ratio=0/1 {
								loc controls
								forvalues i=1/4 {
								if ```i'''==1 loc controls `controls' ``i''
								}
								loc ++no
								`mod' foreign weight `controls'
								if "`mod'"!="regress" margins, dydx(*) post
								estadd scalar no=`no'
								if "`mod'"=="regress" estadd scalar lpm=1
								else estadd scalar lpm=0
								if "`mod'"=="probit" estadd scalar probit=1
								else estadd scalar probit=0
								if "`mod'"=="logit" estadd scalar logit=1
								else estadd scalar logit=0
								loc numc: word count `controls'
								estadd scalar numcontrols=`numc'
								estimates title: mod`no'
								est save estmod, append
								}
							}
						}
					}
				}
	restore
end
}
