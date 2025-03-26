## creating function ks.perm
## a permutation-based version
## of the Komolgorov-Smirnov test
## for two samples

ks.perm <- function(x, y, reps){
  # drop missing values from x and y
  x <- x[!is.na(x)]
  y <- y[!is.na(y)]
  # regular KS test (suppressing warnings about ties)
  ks.real <- suppressWarnings(ks.test(x, y))
  # vector to hold simulated KS test statistics
  stat.sims <- c()
  # looping over permuations
  for(i in 1:reps){
    joint.perm <- sample(c(x,y), 
                         size=length(c(x,y)), 
                         replace=FALSE)
    x.perm <- joint.perm[1:length(x)]
    y.perm <- joint.perm[-(1:length(x))]
    test.out <- suppressWarnings(ks.test(x.perm, y.perm))
    stat.sims[i] <- test.out$statistic
  }
  perm.pval <- mean(stat.sims >= ks.real$statistic)
  cat(paste("\n","Two-sample Komolgorov-Smirnov test", "\n",
            "with permuation-based p-value", "\n", 
            "p = ", perm.pval, "\n\n"))
}
