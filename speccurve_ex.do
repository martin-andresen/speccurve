clear all
speccurve_gendata

speccurve, param(weight) main(ols3)
graph export ex1.png, replace

speccurve, param(weight) controls(title(control variables)) main(ols3)
graph export ex2.png, replace

speccurve, param(weight) controls(title(control variables)) main(ols3) keep(25 25 25)
graph export ex3.png, replace

speccurve, param(weight) main(ols3) keep(25 25 25) panel(numcontrols foreign domestic)
graph export ex4.png, replace

speccurve, param(weight) main(ols3) keep(25 25 25) controls(title(control variables)) addplot(samemodel, param(length) title(covariate length)) title(specification curve)
graph export ex5.png, replace

speccurve using estiv, param(weight) main(iv3) keep(25 25 25) controls(title(control variables)) addplot(using estfs, param(length) title(first stage estimates))  title(IV estimates)
graph export ex6.png, replace