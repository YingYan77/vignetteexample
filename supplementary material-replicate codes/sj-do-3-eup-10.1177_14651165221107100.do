

*****************************
*Economic Perceptions and Attitudes towards the European Union: a Survey Experiment
*Corresponding Author: Ignacio Jurado, 
*Department of Social Sciences, Carlos III University of Madrid, Calle Madrid 126, CP:28093, Getafe (Madrid), Spain. 
*Email ignacio.jurado@uc3m.es
*************************************


gen economic_mechanisms= eubenefic + euworth
gen representation_mechanisms=  eurestric + eunotall

replace vote= vote+100 if vote <7 & country==2
label define vote 1 "PP" 2 "PSOE" 3 "UP" 4 "Cs"  5 "PNV" 6 "PDeCat"  7 "ERC" 8 "Otro" ///
9 "Blank" 10 "Did not vote" 11 "DK/DA" 101 "CDU/CSU" 102 "SPD" 103 "AfD" ///
104 "FDP" 105 "Grune" 106 "Linke"
label values vote vote

gen vote_incumbent=0
replace vote_incumbent=1 if vote==2 
replace vote_incumbent=1 if vote==101
replace vote_incumbent=1 if vote==102

gen unemployed = 0
replace unemployed=1 if employments==2




******************
***FIGURE 1
***************
***DV: OPINION EU

reg opinioneu tre
margins, dydx(treatment) post
estimates store s1

reg opinioneu tre i.educ unempl female  age
margins, dydx(treatment) post
estimates store s2


coefplot (s1, label(Without Covariates)) (s2 ,label(With Covariates)), title ("General sample") xline(0) xlabel( -.5 -.4 -.3 -.2 -.1 0 .1) ///
ytitle ("ATE") ylabel("") level(90)
graph copy g1

reg opinioneu tre if country==1
margins, dydx(treatment) post
estimates store s3

reg opinioneu tre i.educ unempl female age if country==1 
 margins, dydx(treatment) post
estimates store s4

coefplot (s3, label(Without Covariates)) (s4 ,label(With Covariates)), title ("Spain") xline(0) xlabel( -.5 -.4 -.3 -.2 -.1 0 .1) ///
ytitle ("ATE") ylabel("") level(90)
graph copy g2

reg opinioneu tre if country==2
margins, dydx(treatment) post
estimates store s5
reg opinioneu tre i.educ unempl female age if country==2
margins, dydx(treatment) post
estimates store s6


coefplot (s5, label(Without Covariates)) (s6 ,label(With Covariates)), title ("Germany") xline(0) xlabel( -.5 -.4 -.3 -.2 -.1 0 .1) ///
ytitle ("ATE") ylabel("") level(90)
graph copy g3

graph combine g1 g2 g3, title("Dependent Variable: Positive Opinion EU") holes(2) 
graph drop g1 g2 g3



******************
***FIGURE 2
***************
*** EU FOR COUNTRY

reg countryeu tre
margins, dydx(treatment) post
estimates store s1

reg countryeu tre i.educ unempl female age
margins, dydx(treatment) post
estimates store s2

coefplot (s1, label(Without Covariates)) (s2 ,label(With Covariates)), title ("General sample") xline(0) xlabel(-.3 -.2 -.1 0 .1) ///
ytitle ("ATE") ylabel("") level(90)
graph copy g4

reg countryeu tre if country==1
margins, dydx(treatment) post
estimates store s3

reg countryeu tre i.educ unempl female age if country==1
margins, dydx(treatment) post
estimates store s4

coefplot (s3, label(Without Covariates)) (s4 ,label(With Covariates)), title ("Spain") xline(0) xlabel( -.3 -.2 -.1 0 .1) ///
ytitle ("ATE") ylabel("") level(90)
graph copy g5


reg countryeu tre if country==2
margins, dydx(treatment) post
estimates store s5
reg countryeu tre i.educ unempl female age if country==2
margins, dydx(treatment) post
estimates store s6

coefplot (s5, label(Without Covariates)) (s6 ,label(With Covariates)), title ("Germany") xline(0) xlabel(  -.3 -.2 -.1 0 .1) ///
ytitle ("ATE") ylabel("") level(90)
graph copy g6

graph combine g4 g5 g6 ,holes(2) title("Dependent Variable: EU good for the country")
graph drop g4 g5 g6


 
 

***************************
*** MECHANISMS
*********

***FIGURE 3A:
*MECHANISM 1: ECONOMY

reg economic_mechanisms tre if country==1
margins, dydx(treatment) post
estimates store e1

reg economic_mechanisms tre i.educ unempl female age if country==1
margins, dydx(treatment) post
estimates store e2

coefplot (e1, label(Without Covariates)) (e2 ,label(With Covariates)), title ("Spain") xline(0) xlabel (-.6 -.5 -.4 -.3 -.2 -.1 0 .1) ///
ytitle ("ATE") ylabel("")  level(90)
graph copy e1

reg economic_mechanisms tre if country==2
margins, dydx(treatment) post
estimates store e3

reg economic_mechanisms tre i.educ unempl female age if country==2
margins, dydx(treatment) post
estimates store e4

coefplot (e3, label(Without Covariates)) (e4 ,label(With Covariates)), title ("Germany") xline(0) xlabel   (-.6 -.5 -.4 -.3 -.2 -.1 0 .1) ///
ytitle ("ATE") ylabel("")  level(90)
graph copy e2

graph combine e1 e2, holes(2) title("(a) Economic Dimension")
graph copy eco
graph drop e1 e2

***FIGURE 3B:
*** MECHANISM 2: REPRESENTATION
reg representation_mechanisms tre if country==1
margins, dydx(treatment) post
estimates store r1
eststo: reg representation_mechanisms tre i.educ unempl female age if country==1
margins, dydx(treatment) post
estimates store r2

coefplot (r1, label(Without Covariates)) (r2 ,label(With Covariates)), title ("Spain") xline(0) xlabel  (  -.2 -.1 0 .1 .2 .3 .4) ///
ytitle ("ATE") ylabel("")  level(90)
graph copy r1

reg representation_mechanisms tre if country==2
margins, dydx(treatment) post
estimates store r3

reg representation_mechanisms tre i.educ unempl female age if country==2
margins, dydx(treatment) post
estimates store r4



coefplot (r3, label(Without Covariates)) (r4 ,label(With Covariates)), title ("Germany") xline(0) xlabel  (-.2 -.1 0 .1 .2 .3 .4) ///
ytitle ("ATE") ylabel("")  level(90)
graph copy r2

graph combine r1 r2, holes(2) title("(b) Representation Dimension") 
est clear
graph copy representation
graph drop r1 r2

graph combine eco representation
graph drop eco representation


 
 
 
 
 
 
 ****************************************
 *****ONLINE APPENDIX**********+
 ******************** ********************
 
 *** Table A.1 Balance test
ttest female, by(tr)
ttest age, by(tr)
ttest education, by (tr)
ttest unempl, by (tr)
ttest satdemo, by(tr)
ttest european_c, by(tr)



 
 
*Figure A.1
***MANIPULATION CHECK


reg crisis_co tre 
margins, dydx(treatment) post
estimates store s1

reg crisis_co tre i.educ unempl female age 
margins, dydx(treatment) post
estimates store s2

coefplot (s1, label(Without Covariates)) (s2 ,label(With Covariates)), title ("Depth Economic Crisis") xline(0) xlabel(-.1 0 .1 .2 .3) ///
ytitle ("ATE") ylabel("") level(90)
graph copy m1


reg  economics tre 
margins, dydx(treatment) post
estimates store s3

reg economics tre i.educ unempl female age 
margins, dydx(treatment) post
estimates store s4

coefplot (s1, label(Without Covariates)) (s2 ,label(With Covariates)), title ("Economic Situation") xline(0) xlabel (-.1 0 .1 .2 .3 .4) ///
ytitle ("ATE") ylabel("")  level(90)
graph copy m2


graph combine m1 m2 , title("Manipulation Checks")
graph drop m1 m2



***********
**Table A.2
*********


 est clear
eststo: reg opinioneu tre i.educ unempl female age
eststo: reg opinioneu tre i.educ unempl female age if country==1
eststo: reg opinioneu tre i.educ unempl female age if country==2


 ********+***
 **Table A.3
 *********
 
 est clear
eststo: reg countryeu tre i.educ unempl female age
eststo: reg countryeu tre i.educ unempl female age if country==1
eststo: reg countryeu tre i.educ unempl female age if country==2


 **************
 ****Table A.4
 ***********
 
 est clear
eststo: reg economic_mechanisms tre i.educ unempl female age if country==1
eststo: reg economic_mechanisms tre i.educ unempl female age if country==2
 
 

  **************
 ****Table A.5
 ***********
 est clear
eststo: reg representation_mechanisms tre i.educ unempl female age if country==1
eststo: reg representation_mechanisms tre i.educ unempl female age if country==2




************
**** Predicted Effects
******************+
*******************
***Figure A.2
*DV: OPINION EU
***************


reg opinioneu tre  i.educ unempl female age 
margins, at(treatment=0) post
estimates store s1
reg opinioneu tre  i.educ unempl female age 
margins, at(treatment=1) post
estimates store s2
coefplot (s1, label(Control Group)) (s2 ,label(Treatment Group)), title ("General sample") vertical xlabel ("") ylabel(2.7(.3)4.2) ///
ytitle ("Predicted Value (1-5)")  level(90) name(g1)



reg opinioneu tre  i.educ unempl female age  if country==1
margins, at(treatment=0) post
estimates store s1
reg opinioneu tre  i.educ unempl female age  if country==1
margins, at(treatment=1) post
estimates store s2
coefplot (s1, label(Control Group)) (s2 ,label(Treatment Group)), title ("Spain") vertical xlabel ("")  ylabel(2.7(.3)4.2)  ///
ytitle ("Predicted Value (1-5)")  level(90) name(g2)




reg opinioneu tre  i.educ unempl female age  if country==2
margins, at(treatment=0) post
estimates store s1
reg opinioneu tre  i.educ unempl female age  if country==2
margins, at(treatment=1) post
estimates store s2
coefplot (s1, label(Control Group)) (s2 ,label(Treatment Group)), title ("Germany") vertical xlabel ("")  ylabel(2.7(.3)4.2) ///
ytitle ("Predicted Value (1-5)")  level(90) name(g3)

grc1leg g1 g2 g3 ,  title("Dependent Variable: Positive Opinion EU")
graph drop g1 g2 g3


*******************
***Figure A.3
*DV:COUNTRY EU
**********************


reg countryeu tre  i.educ unempl female age 
margins, at(treatment=0) post
estimates store s1
reg  countryeu tre  i.educ unempl female age 
margins, at(treatment=1) post
estimates store s2
coefplot (s1, label(Control Group)) (s2 ,label(Treatment Group)), title ("General sample") vertical xlabel ("") ylabel(2.7(.3)4.2) ///
ytitle ("Predicted Value (1-5)")  level(90) name(g1)



***DV:  COUNTRY EU
reg  countryeu tre  i.educ unempl female age  if country==1
margins, at(treatment=0) post
estimates store s1
reg  countryeu tre  i.educ unempl female age  if country==1
margins, at(treatment=1) post
estimates store s2
coefplot (s1, label(Control Group)) (s2 ,label(Treatment Group)), title ("Spain") vertical xlabel ("")   ylabel(2.7(.3)4.2)  ///
ytitle ("Predicted Value (1-5)")  level(90) name(g2)




***DV:  COUNTRY EU
reg  countryeu tre  i.educ unempl female age  if country==2
margins, at(treatment=0) post
estimates store s1
reg  countryeu tre  i.educ unempl female age  if country==2
margins, at(treatment=1) post
estimates store s2
coefplot (s1, label(Control Group)) (s2 ,label(Treatment Group)), title ("Germany") vertical xlabel ("")   ylabel(2.7(.3)4.2)  ///
ytitle ("Predicted Value (1-5)")  level(90) name(g3)



grc1leg g1 g2 g3 ,   title("Dependent Variable: EU good for the country")
graph drop g1 g2 g3




*****Table A.6: VOTE INCUMBENT

est clear
eststo: reg opinion i.treatment##vote_incumbent i.educ unempl female age
eststo: reg countryeu  i.treatment##vote_incumbent i.educ unempl female age

 
 
 
****FIGURE A.4: MORE EU INTEGRATION

reg integration tre
margins, dydx(treatment) post
estimates store i1

reg integration tre i.educ unempl female age
margins, dydx(treatment) post
estimates store i2

coefplot (i1, label(Without Covariates)) (i2 ,label(With Covariates)), title ("General sample") xline(0) xlabel( -.5 -.4 -.3 -.2 -.1 0 .1 .2 .3) ///
ytitle ("ATE") ylabel("") level(90)
graph copy g1


reg integration tre if country==1
margins, dydx(treatment) post
estimates store i3

reg integration tre i.educ unempl female age if country==1
margins, dydx(treatment) post
estimates store i4

coefplot (i3, label(Without Covariates)) (i4 ,label(With Covariates)), title ("Spain") xline(0) xlabel( -.5 -.4 -.3 -.2 -.1 0 .1  .2 .3) ///
ytitle ("ATE") ylabel("") level(90)
graph copy g2

reg integration tre if country==2
margins, dydx(treatment) post
estimates store i5

reg integration tre i.educ unempl female age if country==2
margins, dydx(treatment) post
estimates store i6

coefplot (i5, label(Without Covariates)) (i6 ,label(With Covariates)), title ("Germany") xline(0) xlabel( -.5 -.4 -.3 -.2 -.1 0 .1  .2 .3) ///
ytitle ("ATE") ylabel("") level(90)
 graph copy g3
 

graph combine g1 g2 g3, title("Dependent Variable: More EU Integration") holes(2) 
graph drop g1 g2 g3






