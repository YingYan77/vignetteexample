
## Vignette Experiment Code Example:
## Jurado, I. (2022). Economic perceptions and attitudes towards  
## the european union: A survey experiment 
## Replication with Data Generated from ChatGPT

library(rio)
library(haven)
library(ggplot2)
library(stargazer)
library(lmtest)
library(sandwich)

# Set data paths
data_path <- getwd()
data_file <- "/supplementary material-replicate codes/sj-dta-2-eup-10.1177_14651165221107100.dta"

spain <- "/data_spain.csv"
germany <- "/data_germany.csv"

########################################################################
## create functions for further analysis
########################################################################
# Function to clean Jurado data
clean_juardo_data <- function(filepath) {
  # read data and conduct balance test
  temp_df  <- import(filepath)
  
  # create two outcome variable
  temp_df$economic_mechanisms <- temp_df$eubeneficial + temp_df$euworthforcountry
  temp_df$representation_mechanisms <- temp_df$eurestrictedpolicies + temp_df$eunotallow
  
  # create the unemployed dummy variable
  temp_df$unemployed <- ifelse(temp_df$employmentstatus == 2, 1, 0)
  
  # create dummy variable for secondary and tertiary education
  temp_df <- fastDummies::dummy_cols(temp_df, select_columns = "education")
  temp_df <- plyr::rename(temp_df, c("education_2" = "secondary_education", "education_3" = "tertiary_education"))
  temp_df <- subset(temp_df, select = -c(education_1) )
  
  return(temp_df)
}

# Function to read pseudo data
read_pseudo_data <- function(path, filename1, filename2) {
  df1 <- read.csv(paste0(path, filename1))
  df2 <- read.csv(paste0(path, filename2))
  
  df1$country <- 1
  df2$country <- 2
  
  merged_df <- rbind(df1, df2)
  
  merged_df$economic_mechanisms <- merged_df$eubenefic + merged_df$euworth
  merged_df$representation_mechanisms <- merged_df$eurestric + merged_df$eunotall
  
  merged_df <- plyr::rename(merged_df, c("Gender" = "female", 
                                         "Age" = "age", 
                                         "Education" = "education", 
                                         "Employment" = "unemployed"))
  
  merged_df$treatment = merged_df$Treatment + 1
  
  # create dummy variable for secondary and tertiary education
  merged_df <- fastDummies::dummy_cols(merged_df, select_columns = "education")
  merged_df <- plyr::rename(merged_df, c("education_2" = "secondary_education", "education_3" = "tertiary_education"))
  merged_df <- subset(merged_df, select = -c(education_1, Treatment) )
  
  return(merged_df)
}

# Function for balance test
balance_test <- function(data, covar) {
  library(dplyr)
  balance_df <- data |> 
    group_by(treatment) |>
    summarise(across(covariates, mean, na.rm = TRUE), .groups = 'drop') |> 
    as.data.frame()
  setorder(balance_df, treatment)
  
  pvalues <- sapply(covar, function(v) {
    t.test(data[data$treatment == 1, v], data[data$treatment == 2, v], var.equal = TRUE)$p.value
  })
  
  balance_df <- t(balance_df)[-1,]
  balance_df <- cbind(balance_df, as.data.frame(pvalues))
  
  return(balance_df)
}

# Function to estimate models
both_model <- function(data, y) {
  model_o <- lm(as.formula(paste(y, "~ treatment")), data = data)
  print(summary(model_o))
  
  model_w <- lm(as.formula(paste(y, "~ treatment + secondary_education + tertiary_education + unemployed + female + age")), data = data)
  print(summary(model_w))
  
  return(list(model_o, model_w))
}

# Function to plot ATE
plot_ate <- function(model1, model2, axis, label) {
  library(ggplot2)
  
  plot.ate <- ggplot() + 
    geom_point(aes(x = model1$coefficients["treatment"], y = 2, color = 'With Covariate')) +
    geom_point(aes(x = model2$coefficients["treatment"], y = 1, color = 'Without Covariate')) + 
    geom_line(aes(x = confint(model1, level = 0.90)[2,], y = 2, color = 'With Covariate')) + 
    geom_line(aes(x = confint(model2, level = 0.90)[2,], y = 1, color = 'Without Covariate')) + 
    geom_vline(xintercept = 0, color = 'red', linetype = 'dashed') + 
    xlim(axis) + 
    ylim(0, 3) + 
    scale_color_manual(name = "", values = c("With Covariate" = "black", "Without Covariate" = "gray")) + 
    labs(title = paste0(label), 
         x = "", 
         y = "ATE") + 
    theme(axis.text.y = element_blank(),
          axis.ticks.y = element_blank(), 
          axis.line.x = element_line(colour = 'black', size = 0.25), 
          panel.grid.major = element_blank(), 
          panel.background = element_blank()) 
  
  ggsave(paste0("rplots/", label, ".pdf"), plot = plot.ate)
  
  return(plot.ate)

}


########################################################################
## read the dataset and descriptive analysis
########################################################################
df <- clean_juardo_data(paste0(data_path, data_file))
psuedo_df <- read_pseudo_data(data_path, spain, germany)

covariates <- c("female", "age", "education", "unemployed", "satdemo", "european_citizen")
bt_table <- balance_test(df, covariates)
print(bt_table)

psuedo_bt_table <- balance_test(psuedo_df, covariates)
print(psuedo_bt_table)



########################################################################
## manipulation checks
########################################################################

# depth economic crisis
econ_crisis <- both_model(df, "crisis_country")
plot_ate(econ_crisis[[1]], econ_crisis[[2]], c(-0.1, 0.4), "Economic Crisis")

psuedo_econ_crisis <- both_model(psuedo_df, "crisis_country") # the psuedo dataset
plot_ate(psuedo_econ_crisis[[1]], psuedo_econ_crisis[[2]], c(-0.3, 0.2), label ='Economic Crisis (Psuedo Data)')

# economic situation
econ_situation <- both_model(df, "economicsituation") # the psuedo dataset
plot_ate(econ_situation[[1]], econ_situation[[2]], c(-0.3, 0.2), label ='Economic Situation')

psuedo_econ_situation <- both_model(psuedo_df, "economicsituation") # the psuedo dataset
plot_ate(econ_situation[[1]], econ_situation[[2]], c(-0.3, 0.2), label ='Economic Situation (Psuedo Data)')

########################################################################
## outcome variables
########################################################################
## eu opinion
# general
euopinion <- both_model(df, "opinioneu")
plot_ate(euopinion[[1]], euopinion[[2]], c(-0.5, 0.1), "Positive Opinion EU - General")

psuedo_euopinion = both_model(psuedo_df, 'opinioneu')
plot_ate(psuedo_euopinion[[1]], psuedo_euopinion[[2]], c(-0.1, 0.4), label ='Potisitve Opinion EU - General (Psuedo Data)')

# spain
euopinion_es <- both_model(df[df$country == 1,], "opinioneu")
plot_ate(euopinion_es[[1]], euopinion_es[[2]], c(-0.5, 0.1), label ='Potisitve Opinion EU - Spain')

psuedo_euopinion_es = both_model(psuedo_df[psuedo_df$country == 1,], "opinioneu")
plot_ate(psuedo_euopinion_es[[1]], psuedo_euopinion_es[[2]], c(-0.1, 0.4), label ='Potisitve Opinion EU - Spain (Psuedo Data)')

# germany
euopinion_de <- both_model(df[df$country == 2,], "opinioneu")
plot_ate(euopinion_de[[1]], euopinion_de[[2]], c(-0.5, 0.1), label ='Potisitve Opinion EU - Germany')

psuedo_euopinion_de = both_model(psuedo_df[psuedo_df$country == 2,], "opinioneu")
plot_ate(psuedo_euopinion_de[[1]], psuedo_euopinion_de[[2]], c(-0.1, 0.4), label ='Potisitve Opinion EU - Germany (Psuedo Data)')

## eu good for the country
# general
countryeu <- both_model(df, "countryeu")
plot_ate(countryeu[[1]], countryeu[[2]], c(-0.3, 0.1), "EU Good for the Country - General")

psuedo_countryeu = both_model(psuedo_df, 'countryeu')
plot_ate(psuedo_countryeu[[1]], psuedo_countryeu[[2]], c(-0.3, 0.2), label ='EU Good for the Country - General (Psuedo Data)')

# spain
countryeu_es <- both_model(df[df$country == 1,], "countryeu")
plot_ate(countryeu_es[[1]], countryeu_es[[2]], c(-0.3, 0.1), label ='EU Good for the Country - Spain')

psuedo_countryeu_es = both_model(psuedo_df[psuedo_df$country == 1,], "countryeu")
plot_ate(psuedo_countryeu_es[[1]], psuedo_countryeu_es[[2]], c(-0.3, 0.2), label ='EU Good for the Country - Spain (Psuedo Data)')

# germany
countryeu_de <- both_model(df[df$country == 2,], "countryeu")
plot_ate(countryeu_de[[1]], countryeu_de[[2]], c(-0.3, 0.1), label ='EU Good for the Country - Germany')

psuedo_countryeu_de = both_model(psuedo_df[psuedo_df$country == 2,], "countryeu")
plot_ate(psuedo_countryeu_de[[1]], psuedo_countryeu_de[[2]], c(-0.3, 0.2), label ='EU Good for the Country - Germany (Psuedo Data)')

########################################################################
## two dimensions of crisis
########################################################################
## economic dimension
# spain
econ_dim_es = both_model(df[df$country == 1,], "economic_mechanisms")
plot_ate(econ_dim_es[[1]], econ_dim_es[[2]], c(-0.6, 0.1), label ='Economic Dimension - Spain')

psuedo_econ_dim_es = both_model(psuedo_df[psuedo_df$country == 1,], "economic_mechanisms")
plot_ate(psuedo_econ_dim_es[[1]], psuedo_econ_dim_es[[2]], c(-0.4, 0.5), label ='Economic Dimension - Spain (Psuedo Data)')

# germany
econ_dim_de <- both_model(df[df$country == 2,], "economic_mechanisms")
plot_ate(econ_dim_de[[1]], econ_dim_de[[2]], c(-0.6, 0.1), label ='Economic Dimension - Germany')

psuedo_econ_dim_de = both_model(psuedo_df[psuedo_df$country == 2,], "economic_mechanisms")
plot_ate(psuedo_econ_dim_de[[1]], psuedo_econ_dim_de[[2]], c(-0.4, 0.5), label ='Economic Dimension - Germany (Psuedo Data)')

## representation dimension
# spain
represent_dim_es = both_model(df[df$country == 1,], "representation_mechanisms")
plot_ate(represent_dim_es[[1]], represent_dim_es[[2]], c(-0.2, 0.4), label ='Representation Dimension - Spain')

psuedo_represent_dim_es = both_model(psuedo_df[psuedo_df$country == 1,], "representation_mechanisms")
plot_ate(psuedo_represent_dim_es[[1]], psuedo_represent_dim_es[[2]], c(-0.4, 0.3), label ='Representation Dimension - Spain (Psuedo Data)')

# germany
represent_dim_de <- both_model(df[df$country == 2,], "representation_mechanisms")
plot_ate(represent_dim_de[[1]], represent_dim_de[[2]], c(-0.2, 0.4), label ='Representation Dimension - Germany')

psuedo_represent_dim_de = both_model(psuedo_df[psuedo_df$country == 2,], "representation_mechanisms")
plot_ate(psuedo_represent_dim_de[[1]], psuedo_represent_dim_de[[2]], c(-0.4, 0.3), label ='Representation Dimension - Germany (Psuedo Data)')

