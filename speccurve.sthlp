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
					[samemodel] [using], param(name) {it:panel_opts}) level(numlist) keep(numlist) sort(name|none) fill graphopts(string) title(string) save(name)]

{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
	{synopt:{opt param(name)}} exact name of the coefficient of interest.{p_end}
	{synopt:{opt main(name)}} name of the main specification, which will be marked in the figure.{p_end}
	{synopt:{opt panel(namelist, [panel_opts])}} specification of a panel of characteristics for each estimate, 
	see availabe options below. This option may be repeated multiple times for more panels. The order they are 
	specified determines plot order.{p_end}
	{synopt:{opt controls([panel_opts])}} specifies that a specification panel is drawn, plotting which 
	covariates (excluding the parameter of interest) is present in each specification. Options (which may
	be specified within parentheses) are detailed below. Order of the specification of this panel relative 
	to the other specifications determines plot order.{p_end}
	{synopt:{opt addcoef([samemodel] [namelist] [using], param(name) [panel_opts])}} specifies that an additional plot is drawn, plotting
	the distribution of another coefficient of interest. param(name)-suboption is required, other options detailed
	below. Estimates are sorted according to the sort order in the main panel.{p_end}
	{synopt:{opt addscalar(name, [panel_opts])}} specifies that an additional scalar from e() is plotted in a separate panel. 	Estimates are sorted according to the sort order in the main panel.{p_end}
	{synopt:{opt level(numlist)}} level for confidence intervals, maximum 2. Default is 90 and 95% intervals.{p_end}
	{synopt:{opt keep(numlist)}} Must contain 3 nonnegative integers. Only the #1 smallest point estimates and the #3 largest point estimates are plotted, together with #2 other randomly drawn estimates.{p_end}
	{synopt:{opt graphopts(string)}} twoway options added to the main coefficient panel, use with caution.{p_end}
	{synopt:{opt sort(none|varname)}} changes sorting behavior. "none" does not sort estimates at all, "varname" sorts by specified variable. Default behaviour is to sort by estimate size.{p_end}
	{synopt:{opt title}} specifies the title of the main coefficient panel.{p_end}
	{synopt:{opt fill}} sets missing data for scalars specified in panel to 0.{p_end}
	{synopt:{opt save(name)}} saves the dataset in {it:name}, replacing any existing file by that name, before plotting and applying keep().{p_end}
	{synopt:{opt ytitle(string)}} names the main y-axis. Default is "coefficient on <<param>>", where param is the main parameter of interest.{p_end}

	{syntab:panel_opts}
	{synopt:{opt labels(string)}} one-word labels used for each characteristic in the panel. Default: Name of scalar. {p_end}
	{synopt:{opt title(string)}} title of panel.{p_end}
	{synopt:{opt graphopts(string)}} other graph options, parsed directly to the twoway command that draws the panel.{p_end}
	{synoptline}

	
	{marker description}{...}
	{title:Description}

	{pstd}
	{cmd:speccurve} plots specifcation curves using stored or saved estimates of the same parameter with various specifications.{p_end}

	{pstd}
	If {it:using} is not specified, speccurve takes estimates from memory. If {it:using} is specified, speccurve takes estimates from the file 
	using.ster. Either way, if {it:namelist} is specified, only estimates specified in namelist are used. Abbreviations and wildcards are allowed.
	If  {it:namelist} is unspecified, all estimates in memory or in using.ster are used. When saving estimates, store one-word estimate names 
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
	If addcoef() is specified, speccurve plots an additional set of coefficients in a separate panel. param(name) suboption is required, specifying
	the name of the additional parameter of interest. If samemodel is specified in this option, speccurve looks for this coefficient in the same 
	models already specified, in essence plotting a control variable. Alternatively, using may be specified to take these estimate from models stored
	in using.ster. If neither using nor samemodel is specified speccurve takes estimates from models in memory. Either way, only estimates specified
	in namelist is used, allowing wildcards, so that you may specify a subset of the estimates in memory or using.ster be used. Unless taking estimates
	from the same model as the main panel using samemodel, speccurve will assume that the order in which the models appear are the same as specified
	for the main coefficient of interest. Addplot allows further suboptions, see below.{p_end}
	
	{pstd}
	Addscalar() works similarly as addcoef, but plots an additional panel with a scatter plot of a scalar stored in e().
	{p_end}
	
	{pstd}Panel(), controls() and addplot() options all allow the suboptions title() and graphopts(), where the first specifies a title of the relevant
	panel and the latter specifies other {helpb twoway_options} to be added to the panel - use with caution because these may interfere with the panel 
	spacing and alignment. Panel() and controls() also allows labels(), where the user can specify alternative one-word labels for each entry in the panel
	that appear on the y axis.{p_end}

	{pstd}Main() also allows the suboption graphopts(), which can similarly be used specify {helpb twoway_options} modifying its style.

	{marker preparation}{...}
	{title:Saving or storing your models before using speccurve}

	{pstd}
	{cmd:speccurve} takes results from saved (if specifying {it:using}) or stored (if not) models. Stata can store a maximum of 512 models in memory, so 
	if the number of specifications exceed this, you need to save the estimates.{p_end}
	
	{pstd}
	First estimate your model using any e-class command that stores b and V in e(). If you want to use custom specification panels, you need to store 
	scalars with the estimates indicating the details of the specification using estadd. As an example, add a scalar indicating that the "foreign" 
	subsample was used by specifying estadd scalar "foreign=1" or add the number of the polynomial of some control using "estadd scalar polynomial=2".
	estadd is part of the estout package, see ssc -install estout-. If you are comparing estiamtes using different functional forms, 
	you may wish to compute marginal effects using -margins, dydx(*) post- to store the marginal effects in e() before running speccurve.{p_end}
	
	{pstd}
	After all details of the specification is added to the estimate, either store the estimate using "eststo name", or add a title and save the estimate 
	using "estimates title: name" (one word names only) followed by "estimates save filename, append", where append assures that you add the model to 
	"filename" in addition to any models already stored there - all models must be saved in the same file.{p_end}
	
	{pstd}
	If you want a custom control panel, where for example fixed effects are indicated with a single line for a full set of fixed effect rather than a
	line for each level of the fixed effect, you'll need to add indicators for this manually, for example using estadd scalar county_fe=1 and later
	panel(county_fe) in speccurve to specify the panel manually.{p_end}
	
	{pstd}
	After doing this for all your specifications, you are ready to plot specification curves.{p_end}
	
	{marker confint}{...}
	{title:An note on confidence intervals}
	
	{pstd}
	Speccurve plots pointwise confidence intervals, meaning confidence intervals on the parameter of interest estimated for 
	each model separately. This is in line with what is typically reported in robustness tables and figures. Note, however,
	that when formally testing the hypothesis that a coefficient from an alternative model is different from the coefficient from
	the baseline model, correct inference requires the models to be estimated simultaneously rather than simply comparing whether
	the pointwise confidence intervals overlap. Speccurve is purely a plotting tool and so does not estimate the models, 
	 but users are encouraged to estimate models simultaneously when formally testing hypotheses.

	
	{marker examples}{...}
	{title:Examples}

	{pstd} 
	Examples models are estimated in speccurve_gendata:
	
	{pstd}
	Estimate a bunch of (arguably silly) models to use for examples. Load auto data and estimate 128 regressions of price on weight, controlling for all combinations 
	of mpg, headroom, trunk, gear_ratio, length, turn and displacement. Store these in 	memory, calling them ols1-ols128. Add a dummy variable indicating the inclusion 
	of each control, and also a numerical variable indicating the number of control variables used. 
	
	{pstd}
	Estimate the same models again, but absorb fixed effects for rep78 using xtreg. Add a dummy for whether these factor variables was controlled for.
	
	{ptsd}
	Also estimate 48 2SLS models of price on weight with various controls, using length as an instrument for weight, and store these in 
	estiv.ster, and the associated first stage regressions, storing them in estfs.ster. 
	
	{ptsd}
	Estimate linear probability, logit and probit models of the probability that a car is foreign based on weight
	and various controls, store these in estmod.ster. {p_end}
	
	{ptsd}
	Finally estimate all the linear regressions models separately for foreign and domestic cars, and add a dummy indicating what sample was used.

	{ptsd}
	
	{phang2}({stata "speccurve_gendata":{it:click to run})}{p_end}

	{pstd}
	Specification plot with automatic control panel, highlight main specification {p_end}
	{phang2}{cmd:. speccurve, param(weight) controls main(ols1)}{p_end}
	{phang2}({stata "speccurve, param(weight) controls main(ols1)":{it:click to run}}){p_end}

	{pstd}
	Unfortunately this figure is a bit cluttered. Therefore just plot the smallest and largest 20 estimates and 20 random estimates in the middle:{p_end}
	{phang2}{cmd:. speccurve, param(weight) controls main(ols1) keep(20 20 20)} {p_end}
	{phang2}({stata "speccurve, param(weight) controls main(ols1) keep(20 20 20)":{it:click to run}}) {p_end}

	{pstd}
	Plot a panel indicating just the number of controls instead {p_end}
	{phang2}{cmd:. speccurve, param(weight) panel(numcontrols) main(ols1)}{p_end}
	{phang2}({stata "speccurve, param(weight) panel(numcontrols) main(ols1)":{it:click to run}}){p_end}

	
	{pstd}
	Use the addcoef() option to plot the values of the control variable length{p_end}
	{phang2}{cmd:. speccurve, param(weight) main(ols1) keep(20 20 20) controls addcoef(samemodel, param(length))} {p_end}
	{phang2}({stata "speccurve, param(weight) main(ols1) keep(20 20 20) controls addcoef(samemodel, param(length))":{it:click to run}}) {p_end}
	
	{pstd}
	Use the addscalar() option to plot a separate plot of R^2 from each model.{p_end}
	{phang2}{cmd:. speccurve, param(weight) main(ols1) keep(20 20 20) controls addscalar(r2, graphopts(ytitle(R squared)))} {p_end}
	{phang2}({stata "speccurve, param(weight) main(ols1) keep(20 20 20) controls addscalar(r2, graphopts(ytitle(R squared)))":{it:click to run}}) {p_end}


	{pstd}
	Plot the IV estimates from estiv.ster, a control panel and use the addcoef() option to plot the associated first stage estimates for each model, taking them from estfs.ster:{p_end}
	{phang2}{cmd:. speccurve using estiv, param(weight) main(iv1) keep(20 20 20) controls addcoef(using estfs, param(length) graphopts(ytitle(first stage estimates))) graphopts(ytitle(IV estimates))} {p_end}
	{phang2}({stata "speccurve using estiv, param(weight) main(iv1) keep(20 20 20) controls addcoef(using estfs, param(length) graphopts(ytitle(first stage estimates))) graphopts(ytitle(IV estimates))":{it:click to run}}) {p_end}

	{pstd}
	Plot the marginal effects of weight on the probability that a car is foreign from linera probability, logit and probit models with various controls, from estmod.ster:{p_end}
	{phang2}{cmd:. 	speccurve using estmod, param(weight) controls panel(lpm logit probit)} {p_end}
	{phang2}({stata "speccurve using estmod, param(weight) controls panel(lpm logit probit)":{it:click to run}}) {p_end}


	{pstd}
	Plot results of fixed effects models, adding a panel that indicates the inclusion of fixed effects:{p_end}
	{phang2}{cmd:. 	speccurve ols* fe*, param(weight) controls panel(i_rep78) keep(20 20 20)} {p_end}
	{phang2}({stata "speccurve ols* fe*, param(weight) controls panel(i_rep78) keep(20 20 20)":{it:click to run}}) {p_end}

	{pstd}
	Plot results subgroup specific models (foreign vs domestic cars vs. both), adding a panel that indicates the subgroup:{p_end}
	{phang2}{cmd:. 	speccurve using subgroups, param(weight) panel(foreign domestic,title(subgroup)) controls(title(subgroup)) keep(20 20 20)} {p_end}
	{phang2}({stata "speccurve using subgroups, param(weight) panel(foreign domestic,title(subgroup)) controls(title(subgroup)) keep(20 20 20)":{it:click to run}}) {p_end}
	
	{marker saved_results}{...}
	{title:Stored results}

	{pstd}
	{cmd:speccurve} stores the following in {cmd:r()}:

	{synoptset 20 tabbed}{...}
	{synopt:{cmd:r(table)}}Matrix of plotted data{p_end}

	{marker Author}{...}
	{title:Author}

	{pstd}Martin Eckhoff Andresen{p_end}
	{pstd}University of Oslo & Statistics Norway{p_end}
	{pstd}Oslo, NO{p_end}
	{pstd}martin.eckhoff.andresen@gmail.com{p_end}
	{pstd}bugs, comments, feedback and feature requests welcome{p_end}

	{marker Thanks}{...}
	{title:Thanks to}
	{pstd}Uri Simonsohn, Joseph Simmons and Leif D. Nelson for their paper "Specification Curve Analysis" 
	(Nat Hum Behav, 2020, and previous working paper), first (?) suggesting the specification curve.{p_end}
	
	{pstd}Hans H. Sievertsen for posting a graph that inspired this program on {browse "twitter.com/hhsievertsen/status/1188780383736909825":Twitter} {p_end}
