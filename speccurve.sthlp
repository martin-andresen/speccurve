	{smcl}
	{cmd:help speccurve}
	{hline}

	{title:Title}

	{p2colset 5 20 22 2}{...}
	{p2col:{cmd:speccurve} {hline 2}} Plot specification curve for estimates in memory or on disk.{p_end}
	{p2colreset}{...}


	{marker syntax}{...}
	{title:Syntax}

	{p 8 11 2}
	{cmd:speccurve} [namelist] [using] {cmd:,} param(name) [main(name) panel(namelist, {it:panel_opts}) controls[({it:panel_opts})] addplot([namelist] 
					[samemodel] [using], param(name) {it:panel_opts}) levels(numlist) keep(numlist) sort(name|none) fill graphopts(string) title(string)]

	{synoptset 30}{...}
	{synopthdr:options}
	{synoptline}
	{synopt:{opt param(name)}} exact name of the coefficient of interest.{p_end}
	{synopt:{opt main(name)}} name of the main specification, which will be marked in the figure.{p_end}
	{synopt:{opt panel(namelist, [panel_opts])}} specification of a panel of characteristics for each estimate, 
	see availabe options below. This option may be repeated multiple times for more panels. The order they are 
	specified determines plot order.{p_end}
	{synopt:{opt controls([panel_opts])}} specifies that a specification panel is drawn, plotting which 
	covariates (excluding the parameter of interest) is present in each specification. Options (which may
	be specified within parentheses) are detailed below. Order of the specification of this panel relative 
	to the other specifications determines plot order.{p_end}
	{synopt:{opt addplot([samemodel] [namelist], param(name) [panel_opts])}} specifies that an additional plot is drawn, plotting
	the distribution of another parameter of interest. param(name)-suboption is required, other options detailed
	below. Estimates are sorted according to the sort order in the main panel.{p_end}
	{synopt:{opt levels(numlist)}} levels for confidence intervals, maximum 2. Default is 90 and 95% intervals.{p_end}
	{synopt:{opt keep(numlist)}} Must contain 3 nonnegative integers. Only the #1 smallest point estimates and the #3 largest point estimates are plotted, together with #2 other randomly drawn estimates.{p_end}
	{synopt:{opt graphopts(string)}} twoway options added to the main coefficient panel, use with caution.{p_end}
	{synopt:{opt sort(none|varname)}} changes sorting behavior. "none" does not sort estimates at all, "varname" sorts by specified variable. Default behaviour is to sort by estimate size.{p_end}
	{synopt:{opt title}} specifies the title of the main coefficient panel.{p_end}

	{synoptline}

	{marker description}{...}
	{title:Description}

	{pstd}
	{cmd:speccurve} plots specifcation curves using stored or saved estimates of the same parameter with various specifications.{p_end}

	{pstd}
	If {it:using} is not specified, speccurve takes estimates from memory. If {it:using} is specified, speccurve takes estimates from the file 
	using.ster. Either way, if {it:namelist} is specified, only estimates specified in namelist are used. Abbreviations and wildcards are allowed.
	If  {it:namelist} are unspecified, all estimates in memory or in using.ster are used. When saving estimates, store one-word estimate names 
	in estimates title using estimates title: yourname before saving if you want to use namelist to refer to some of them.{p_end}

	{pstd}
	Speccurve by default plots all estimates of the parameter of interest specified in param(name) with confidence bands.{p_end}
	
	{pstd}
	If the controls[()] option is specified (without parentheses allowed if not using suboptions), speccurve additionally plots a specification 
	panel indicating with dots which covariates are included in each specification. Subobtions allowed, see below. If fixed effects are included, this 
	option adds one line to this panel for each value of the fixed effects. Alternatively, users may manually specify an indicator for each set of fixed
	effects using the panel() option.{p_end}
	
	{pstd}If panel() is specified, speccurve additionally plots a user-specified specification panel using data specified in the panel() option. 
	Panel() requires a namelist consisting of the names of scalars stored with each estimate to be plotted. This option may be repeated multiple 
	times, and the order in which they are specified (and their relation to controls()-panel, if using) determines the order in which they are plotted. 
	Subptions allowed, see below.{p_end}

	{pstd}
	If addplot() is specified, speccurve plots an additional set of coefficients in a separate panel. param(name) suboption is required, specifying
	the name of the additional parameter of interest. If samemodel is specified in this option, speccurve looks for this coefficient in the same 
	models already specified, in essence plotting a control variable. Alternatively, using may be specified to take these estimate from models stored
	in using.ster. If neither using nor samemodel is specified speccurve takes estimates from models in memory. Either way, only estimates specified
	in namelist is used, allowing wildcards, so that you may specify a subset of the estimates in memory or using.ster be used. Unless taking estimates
	from the same model as the main panel using samemodel, speccurve throws an error if the number of models specified in addplot is not equal to the 
	number of models specified for the main panel. Addplot allows further suboptions, see below.{p_end}
	
	{pstd}Panel(), controls() and addplot() options all allow the suboptions title() and graphopts(), where the first specifies a title of the relevant
	panel and the latter specifies other {helpb twoway_options} to be added to the panel - use with caution because these may interfere with the panel 
	spacing and alignment. Panel() and controls() also allows labels(), where the user can specify alternative one-word labels for each entry in the panel
	that appear on the y axis.{p_end}

	{marker examples}{...}
	{title:Examples}

	{pstd}
	Estimate a bunch of models to use for examples. Load auto data and estimate 192 regressions of price on weight, controlling for all combinations 
	of mpg, headroom, trunk, gear_ratio, length and turn, in samples of a) all cars, b) only foreign cars and c) only domestic cars. Store these in
	memory, calling them ols1-ols192. Also estimate 96 2SLS models of price on weight, using length as an instrument for weight, and store these in 
	estiv.ster, and the associated first stage regressions, storing them in estfs.ster. {p_end}

	{phang2}({stata "speccurve_gendata, save(speccurve_data)":{it:click to run})}{p_end}

	{pstd}
	Straightforward specification plot of all estimates in memory, highlight main specification {p_end}
	{phang2}{cmd:. speccurve, param(weight) main(ols3)}{p_end}
	{phang2}({stata "speccurve, param(weight) main(ols3)":{it:click to run}}){p_end}

	{pstd}
	Now add a panel indicating what covariates are included{p_end}
	{phang2}{cmd:. speccurve, param(weight) controls(title(control variables)) main(ols3))} {p_end}
	{phang2}({stata "speccurve, param(weight) controls(title(control variables)) main(ols3)":{it:click to run}}) {p_end}

	{pstd}
	Unfortunately this figure is a bit cluttered. Therefore just plot the smallest and largest 25 estimates and 25 random estimates in the middle:{p_end}
	{phang2}{cmd:. speccurve, param(weight) controls(title(control variables)) main(ols3) keep(25 25 25)} {p_end}
	{phang2}({stata "speccurve, param(weight) controls(title(control variables)) main(ols3) keep(25 25 25)":{it:click to run}}) {p_end}

	{pstd}
	Drop the control panel, adding instead a panel indicating the number of control variables used, and what parts of the sample was used :{p_end}
	{phang2}{cmd:. speccurve, param(weight) main(ols3) keep(25 25 25) panel(numcontrols foreign domestic)} {p_end}
	{phang2}({stata "speccurve, param(weight) main(ols3) keep(25 25 25) panel(numcontrols foreign domestic)":{it:click to run}}) {p_end}
	
	{pstd}
	Use the addplot() option to plot the values of the control variable length, bring back the control panel:{p_end}
	{phang2}{cmd:. speccurve, param(weight) main(ols3) keep(25 25 25) controls(title(control variables)) addplot(samemodel, param(length) title(covariate length))} {p_end}
	{phang2}({stata "speccurve, param(weight) main(ols3) keep(25 25 25) controls(title(control variables)) addplot(samemodel, param(length) title(covariate length)) title(specification curve)":{it:click to run}}) {p_end}


	{pstd}
	Plot the IV estimates from estiv.ster, a control panel and use the addplot() option to plot the associated first stage estimates for each model, taking them from estfs.ster:{p_end}
	{phang2}{cmd:. speccurve using estiv, param(weight) main(iv195) keep(25 25 25) controls(title(control variables)) addplot(using estfs, param(length) title(first stage estimates)) title(IV estimates)} {p_end}
	{phang2}({stata "speccurve using estiv, param(weight) main(iv195) keep(25 25 25) controls(title(control variables)) addplot(using estfs, param(length) title(first stage estimates)) title(IV estimates)":{it:click to run}}) {p_end}

	{marker Author}{...}
	{title:Author}

	{pstd}Martin Eckhoff Andresen{p_end}
	{pstd}University of Oslo & Statistics Norway{p_end}
	{pstd}Oslo, NO{p_end}
	{pstd}martin.eckhoff.andresen@gmail.com{p_end}
	{pstd}bugs, comments, feedback and feature requests welcome{p_end}

	{marker Thanks}{...}
	{title:Thanks to}
	{pstd}Uri Simonsohn, Joseph Simmons and Leif D. Nelson for their paper "Specification Curve: Descriptive and Inferential Statistics on All Reasonable Specifications", first (?) suggesting the specification curve.{p_end}
	{pstd}Hans H. Sievertsen for posting a graph that inspired this program on {browse "twitter.com/hhsievertsen/status/1188780383736909825":Twitter} {p_end}
