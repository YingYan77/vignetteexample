## Replication code for:
## Moderator Placement in Survey Experiments: 
## Racial Resentment and the “Welfare” vs. 
## “Assistance to the Poor” Question Wording Experiment
##
## Bethany Albertson and Stephen Jessee
##
## Journal of Experimental Political Science
##

## NOTE: requires packages rio, mice, stargazer and car 
##       to be installed prior to running code below

# loading data
library(rio)
DAT <- import("raw_data.dta")

#####################################
## creating variables for analysis ##
#####################################


# creating indicator for welfare/aid to poor 
# question wording
DAT$welfare_word <- NA
DAT$welfare_word[!is.na(DAT$Q32)] <- 1
DAT$welfare_word[!is.na(DAT$Q33)] <- 0

# creating welfare/assistance to the poor spending 
# response, combining across question wordings
DAT$spend <- ifelse(DAT$welfare_word==1, c(1, -1, 0)[DAT$Q32],
                    ifelse(DAT$welfare_word==0, c(1, -1, 0)[DAT$Q33], NA))

# dropping the 1 observation with everything missing
DAT <- subset(DAT, !is.na(spend))

# dummy for asking RR battery post-experiment
DAT$rr_post <- 1 - DAT$race_first

# racial resentment scale
# first recoding each item 
DAT$rr1.raw <- (5 - DAT$Q22) / 4
DAT$rr2.raw <- (DAT$Q23 - 1) / 4
DAT$rr3.raw <- (DAT$Q24 - 1) / 4
DAT$rr4.raw <- (5 - DAT$Q25) / 4

# imputing missing RR items 
library(mice)
RRmice <- mice(cbind(DAT$rr1.raw, DAT$rr2.raw, DAT$rr3.raw, DAT$rr4.raw),
                  seed=12345, method="pmm", maxit=100, m=10, print=FALSE)
RRimputed <- complete(RRmice)

DAT$rr1 <- RRimputed[,1]
DAT$rr2 <- RRimputed[,2]
DAT$rr3 <- RRimputed[,3]
DAT$rr4 <- RRimputed[,4]

# RR scale
DAT$rr_scale <- (DAT$rr1 + DAT$rr2 + DAT$rr3 + DAT$rr4) / 4


#############
## TABLE 1 ##
#############

# Model 1
reg11 <- lm(spend ~ welfare_word, data=DAT)
summary(reg11)

# Model 2
reg12 <- lm(spend ~ welfare_word + rr_scale, data=DAT)
summary(reg12)

# Model 3
reg13 <- lm(spend ~ welfare_word*rr_scale, data=DAT)
summary(reg13)

# outputting to formatted txt table
library(stargazer)
stargazer(reg11, reg12, reg13, 
          digits=2, intercept.bottom=FALSE,
          type="text", out="Table1.txt")


#############
## TABLE 2 ##
#############

# Model 1
reg21 <- lm(spend ~ welfare_word*rr_post,
           data=DAT)
summary(reg21)

# Model 2
reg22 <- lm(spend ~ welfare_word*rr_post*rr_scale,
            data=DAT)
summary(reg22)

# outputting to nice txt table
# NOTE: R's ordering of coefficients in Model 2
#       differs slightly from that in the text
stargazer(reg21, reg22,
          digits=2, intercept.bottom=FALSE,
          type="text", out="Table2.txt")

#############
## TABLE 3 ##
#############

# Model 1
reg31 <- lm(rr_scale ~ rr_post + I(rr_post*welfare_word),
           data=DAT)
summary(reg31)

# outputting to nice txt table
stargazer(reg31,
          digits=2, intercept.bottom=FALSE,
          type="text", out="Table3.txt")

# test of linear hypothesis that difference in 
# racial resentment between those receiving the 
# racial resentment battery first and those 
# receiving it afterwards who were shown the 
# “welfare” wording is equal to zero based on 
# linear regression model in Table 3
library(car)
linearHypothesis(reg31, "1*rr_post + 1*I(rr_post * welfare_word) = 0")


##############
## TABLE A1 ##
##############

# proportion female
mean(DAT$Q72==2, na.rm=TRUE)

# proportion Democrat (with leaners)
DAT$pid7 <- ifelse(DAT$Q61==1, DAT$Q62,
                   ifelse(DAT$Q61==2, 8-DAT$Q63,
                          ifelse(DAT$Q61==3, c(5,3,4)[DAT$Q64], NA)))
mean(DAT$pid7 %in% 1:3)

# proportion Republican (with leaners)
mean(DAT$pid7 %in% 5:7)

# proportion College or higher
mean(DAT$Q73 >= 5, na.rm=TRUE)

# proportion White (alone)
mean(DAT$Q75 == 1, na.rm=TRUE)

# proportion African American (alone)
mean(DAT$Q75 == 2, na.rm=TRUE)

# proportion Asian American (alone)
mean(DAT$Q75 == 4, na.rm=TRUE)

# proportion liberal or slightly liberal
mean(DAT$Q77 %in% 1:2)

# proportion conservative or slightly conservative
mean(DAT$Q77 %in% 4:5)


###############
## FIGURE A1 ##
###############

# plotting histograms of rr_scale
# for each of these three groups
pdf("FigA1.pdf",
    height=8, width=5)
par(mfrow=c(3,1))
hist(DAT$rr_scale[DAT$rr_post==0],
     breaks=seq(0 - .0625/2, 1 + .0625/2, by=.0625),
     main="RR measured first",
     xlab="racial resentment scale", freq=FALSE)
hist(DAT$rr_scale[DAT$rr_post==1 & DAT$welfare_word==0],
     breaks=seq(0 - .0625/2, 1 + .0625/2, by=.0625),
     main="RR measured last, \"assistance to the poor\" wording",
     xlab="racial resentment scale", freq=FALSE)
hist(DAT$rr_scale[DAT$rr_post==1 & DAT$welfare_word==1],
     breaks=seq(0 - .0625/2, 1 + .0625/2, by=.0625),
     main="RR measured last, \"welfare\" wording",
     xlab="racial resentment scale", freq=FALSE)
dev.off()

## empirical CDF plots
pdf("FigA2.pdf",
    height=7, width=7)
par(mfrow=c(1,1), pty="s")
plot(ecdf(DAT$rr_scale[DAT$rr_post==0]), verticals=TRUE, do.points=FALSE,
     lwd=2, bty="n", main="",
     xlab="racial resentment score", 
     ylab="empirical CDF")
lines(ecdf(DAT$rr_scale[DAT$rr_post==1 & DAT$welfare_word==1]),
      verticals=TRUE, do.points=FALSE,
      lty=3, lwd=2)
lines(ecdf(DAT$rr_scale[DAT$rr_post==1 & DAT$welfare_word==0]),
      verticals=TRUE, do.points=FALSE,
      col="gray", lwd=2)
legend(.4, .2, #'bottomright', 
       c("RR first", 
         "RR last, \"welfare\" wording", 
         "RR last, \"assistance\" wording"),
       lty=c(1,3,1), lwd=2,
       col=c("black", "black", "gray"))
dev.off()


##############
## TABLE A2 ##
##############

# NOTE: Coefficients are printed by R all together for each
#       model, not side by side as in appendix table

# Model 1
regA21 <- lm(spend ~ -1 + rr_post + I(welfare_word*rr_post) + 
               I(1-rr_post) + I(welfare_word*(1-rr_post)), 
             data=DAT)
summary(regA21)
# Interactive version of Model 1
# to get p-values for tests of equality
# of coefficients between pre- vs post-RR
regA21.interact <- lm(spend ~ rr_post*welfare_word, 
                     data=DAT)
summary(regA21.interact)
# testing hypothesis that pre-post coeffs are equal
anova(reg11, regA21)

# Model 2
regA22 <- lm(spend ~ -1 + rr_post + I(welfare_word*rr_post) + I(rr_scale*rr_post) +
               I(1-rr_post) + I(welfare_word*(1-rr_post)) + I(rr_scale*(1-rr_post)), 
             data=DAT)
summary(regA22)
# Interactive version of Model 2
# to get p-values for tests of equality
# of coefficients between pre- vs post-RR
regA22.interact <- lm(spend ~ rr_post * (welfare_word + rr_scale), 
                     data=DAT)
summary(regA22.interact)
# testing hypothesis that pre-post coeffs are equal
anova(reg12, regA22)

# Model 3
regA23 <- lm(spend ~ -1 + rr_post + I(welfare_word*rr_post) + 
               I(rr_scale*rr_post) + I(welfare_word*rr_scale*rr_post) +
               I(1-rr_post) + I(welfare_word*(1-rr_post)) + 
               I(rr_scale*(1-rr_post)) + I(welfare_word*rr_scale*(1-rr_post)), 
             data=DAT)
summary(regA23)
# Interactive version of Model 2
# to get p-values for tests of equality
# of coefficients between pre- vs post-RR
regA23.interact <- lm(spend ~ rr_post * (welfare_word*rr_scale),
                     data=DAT)
summary(regA23.interact)
# testing hypothesis that pre-post coeffs are equal
anova(reg13, regA23)





##############
## TABLE A3 ##
#######################################################################
# Komolgorov-Smirnof test of RR dist b/t                             ##
# 3 groups: POST_RR==0, (rr_post==1 & welfare_word==0)               ##
# (rr_post==1 & welfare_word==0), and (rr_post==1 & welfare_word==1) ##
#######################################################################

## loading permutation-based KS test function in separate code file
source("permutation ks test function.R")

# setting random seed so permuation test p-vals
# will replicate
set.seed(78712)

# respondents who were asked RR battery first
# compared with 
# respondents asked RR battery after who had
# "assistance to the poor" question wording
ks.test(DAT$rr_scale[DAT$rr_post==0],
        DAT$rr_scale[DAT$rr_post==1 & DAT$welfare_word==0])
ks.perm(DAT$rr_scale[DAT$rr_post==0],
        DAT$rr_scale[DAT$rr_post==1 & DAT$welfare_word==0],
        reps=100000)

# respondents who were asked RR battery first
# compared with 
# respondents asked RR battery after who had
# "welfare" question wording
ks.test(DAT$rr_scale[DAT$rr_post==0],
        DAT$rr_scale[DAT$rr_post==1 & DAT$welfare_word==1])
ks.perm(DAT$rr_scale[DAT$rr_post==0],
        DAT$rr_scale[DAT$rr_post==1 & DAT$welfare_word==1],
        reps=100000)

# respondents asked RR battery after who had
# "assistance to the poor" question wording
# compared with 
# respondents asked RR battery after who had
# "welfare" question wording
ks.test(DAT$rr_scale[DAT$rr_post==1 & DAT$welfare_word==0],
        DAT$rr_scale[DAT$rr_post==1 & DAT$welfare_word==1])
ks.perm(DAT$rr_scale[DAT$rr_post==1 & DAT$welfare_word==0],
        DAT$rr_scale[DAT$rr_post==1 & DAT$welfare_word==1],
        reps=100000)
