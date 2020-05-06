cap program drop speccurve_gendata
{
	program define speccurve_gendata
		version 15.0
		
		syntax , [save(name)]
		
	clear all
	sysuse auto, clear
	
	cap rm estiv.ster
	cap rm estfs.ster
	
	tokenize mpg headroom trunk gear_ratio length turn

	loc no=0
	qui forvalues mpg=0/1 {
		forvalues headroom=0/1 {
			forvalues trunk=0/1 {
				forvalues gear_ratio=0/1{
						forvalues length=0/1 { 
							forvalues turn=0/1 {
								loc controls
								forvalues i=1/6 {
									if ```i'''==1 loc controls `controls' ``i''
								}
								forvalues foreign=0/1 {
									forvalues domestic=0/1 {
										if `foreign'==0&`domestic'==0 continue 
										loc ++no
										if `foreign'==1&`domestic'==1 loc iff
										else if `foreign'==1 loc iff if foreign==1
										else loc iff if foreign==0
										reg price weight `controls' `iff'
										estadd scalar no=`no'
										estadd scalar foreign=`foreign'
										estadd scalar domestic=`domestic'
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
	}
	
	tokenize mpg headroom trunk gear_ratio turn

	loc no=0
	qui forvalues mpg=0/1 {
		forvalues headroom=0/1 {
			forvalues trunk=0/1 {
				forvalues gear_ratio=0/1{
						forvalues turn=0/1 {
							loc controls
							forvalues i=1/5 {
								if ```i'''==1 loc controls `controls' ``i''
							}
							forvalues foreign=0/1 {
								forvalues domestic=0/1 {
									if `foreign'==0&`domestic'==0 continue 
									loc ++no
									if `foreign'==1&`domestic'==1 loc iff
									else if `foreign'==1 loc iff if foreign==1
									else loc iff if foreign==0
									ivregress 2sls price (weight=length) `controls' `iff'
									estadd scalar no=`no'
									estadd scalar foreign=`foreign'
									estadd scalar domestic=`domestic'
									loc numc: word count `controls'
									estadd scalar numcontrols=`numc'
									estimates title: iv`no'
									est save estiv, append
									
									reg weight length `controls' `iff'
									estadd scalar no=`no'
									estadd scalar foreign=`foreign'
									estadd scalar domestic=`domestic'
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
	}
	
	

end
}
