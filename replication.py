#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sat Mar 22 13:44:07 2025

@author: ying
"""

import pandas as pd
import numpy as np
from scipy import stats
from statsmodels.formula.api import ols
import matplotlib.pyplot as plt 

data_path = '/Users/ying/Desktop/HSG/Research Assistant/Experiments with ChatGPT/Jurado (2022)/supplementary material-replicate codes/'
data_file = 'sj-dta-2-eup-10.1177_14651165221107100.dta'

psuedo_data_path = '/Users/ying/Desktop/HSG/Research Assistant/Experiments with ChatGPT/Jurado (2022)/'
spain = 'data_spain.csv'
germany = 'data_germany.csv'


# two attitudes variables: satdemo and european_citizen
# general outcome variables are opinioneu and countryeu 
# manipulation check variables are crisis_country and economicsituation

#%% prepare functions
def clean_juardo_data(datapath): 
    
    temp_df = pd.read_stata(datapath)
    
    # Mapping dictionary
    scale = {
        'Muy en desacuerdo': 1,
        'Más bien en desacuerdo': 2,
        'Ni de acuerdo ni en desacuerdo': 3,
        'Más bien de acuerdo': 4,
        'Muy de acuerdo': 5
    }

    gender = {
        'Mujer': 2, 
        'Hombre': 1
        }
    
    ## transform all measures into numeric 
    temp_df['eubenefic'] = temp_df['eubeneficial'].map(scale)
    temp_df['euworth'] = temp_df['euworthforcountry'].map(scale)
    temp_df['economic_mechanisms'] = temp_df['eubenefic'].astype(int) + temp_df['euworth'].astype(int)


    temp_df['eurestric'] = temp_df['eurestrictedpolicies'].map(scale)
    temp_df['eunotall'] = temp_df['eunotallow'].map(scale)
    temp_df['representation_mechanisms'] = temp_df['eurestric'].astype(int) + temp_df['eunotall'].astype(int)

    temp_df['female'] = temp_df['female'].map(gender).astype(int)
    temp_df['employmentstatus'] = (temp_df['employmentstatus'] == 'Unemployed').astype(int)
    
    education_dummies = pd.get_dummies(temp_df['education']).rename({2.0:'secondary_education', 3.0:'tetiary_education'}, axis=1)
    education_dummies.drop(1.0, axis = 1, inplace = True)
    temp_df = pd.concat([temp_df, education_dummies], axis=1)
    
    return temp_df
    

def read_psuedo_data(path, filename1, filename2): 
    df1 = pd.read_csv(path + filename1)
    df2 = pd.read_csv(path + filename2)
    
    df1['country'] = 1
    df2['country'] = 2
    
    merged_df = pd.concat([df1, df2])
    # create outcome measure
    merged_df['economic_mechanisms'] = merged_df['eubenefic'] + merged_df['euworth']
    merged_df['representation_mechanisms'] = merged_df['eurestric'] + merged_df['eunotall']
    # rename to match the variables names 
    merged_df.rename({'Age': 'age', 'Gender': 'female', 'Education': 'education', 'Employment': 'employmentstatus', 'Treatment': 'treatment'}, axis=1, inplace=True)
    # make the treatment label consistent with the original data
    merged_df['treatment'] = merged_df['treatment'] + 1
    
    education_dummies = pd.get_dummies(merged_df['education']).rename({2.0:'secondary_education', 3.0:'tetiary_education'}, axis=1)
    education_dummies.drop(1.0, axis = 1, inplace = True)
    merged_df = pd.concat([merged_df, education_dummies], axis=1)
    
    return merged_df
    

def balance_test(data, covar):
    
    balance_df = data.groupby('treatment')[covar].mean()
    balance_df = balance_df.transpose()
    treat = data[data['treatment'] == 1]
    control = data[data['treatment'] == 2]
    
    pvalues = []
    for v in covar:
        treat_list = treat[v].dropna()
        control_list = control[v].dropna()
        t_stat, p_value = stats.ttest_ind(treat_list, control_list)
        pvalues.append(p_value)
    
    balance_df['p(diff)'] = pvalues
    return balance_df


def plot_ate(model1, model2, axis, label): 
    fig, ax = plt.subplots()
    ax.plot(model1.params['treatment'], 2,'o', c = 'black', label = 'Without Covariates')
    ax.plot(model2.params['treatment'], 1,'s', c = 'lightgray', label = 'With Covariates')
    ax.plot(model1.conf_int(alpha = 0.1).loc['treatment'], [2,2], c = 'black', ls = '-')
    ax.plot(model2.conf_int(alpha = 0.1).loc['treatment'], [1,1], c = 'lightgray', ls = '-')
    ax.axis(axis)
    ax.axvline(x = 0, color = 'r', ls = '--')
    ax.set_ylabel("ATE")
    ax.set_title(label)
    plt.yticks([])
    plt.legend(loc='upper left', bbox_to_anchor=(1, 0.2))
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    ax.spines['left'].set_visible(False)
    plt.savefig(psuedo_data_path + 'plots/' + label + '.png', bbox_inches='tight')
    return plt.show()

def both_model(data, y): 
    model_o = ols(y + " ~ treatment", data = data).fit()
    print(model_o.summary())

    model_w = ols(y + " ~ treatment + secondary_education + tetiary_education + employmentstatus + female + age", data = data).fit()
    print(model_w.summary())
    
    return model_o, model_w

#%% read data and balance test
df = clean_juardo_data(data_path + data_file)
# check for missing values
df.isnull().sum() # opinioneu, satdemo and european_citizen have missing values


psuedo_df = read_psuedo_data(psuedo_data_path, spain, germany)

# balance check on six variables: female, age, education, employmentstatus, satdemo and european_citizen  
covariates = ['female', 'age', 'education', 'employmentstatus', 'satdemo', 'european_citizen']
      
bt_table = balance_test(df, covariates)
print(bt_table.to_latex(index=True,
                  formatters={"name": str.upper},
                  float_format="{:.2f}".format))

psuedo_bt_table = balance_test(psuedo_df, covariates)
print(psuedo_bt_table.to_latex(index=True,
                  formatters={"name": str.upper},
                  float_format="{:.2f}".format))

#%% manipulation checks
# depth economic crisis
econ_crisis = both_model(df, 'crisis_country') # the original dataset
plot_ate(econ_crisis[0], econ_crisis[1], 
         [-0.1, 0.4, 0, 3], label ='Economic Crisis')

psuedo_econ_crisis = both_model(psuedo_df, 'crisis_country') # the psuedo dataset
plot_ate(psuedo_econ_crisis[0], psuedo_econ_crisis[1], 
         [-0.3, 0.2, 0, 3], label ='Economic Crisis (Psuedo Data)')


# economic situation
econ_situation = both_model(df, 'economicsituation') # the original dataset
plot_ate(econ_situation[0], econ_situation[1], 
         [-0.3, 0.2, 0, 3], label ='Economic Situation')

psuedo_econ_situation = both_model(psuedo_df, 'economicsituation') # the psuedo dataset
plot_ate(psuedo_econ_situation[0], psuedo_econ_situation[1], 
         [-0.3, 0.2, 0, 3], label ='Economic Situation (Psuedo Data)')


#%% outcome variables
# eu opinion
euopinion = both_model(df, 'opinioneu')
plot_ate(euopinion[0], euopinion[1], 
         [-0.5, 0.1, 0, 3], label ='Potisitve Opinion EU - General')

psuedo_euopinion = both_model(psuedo_df, 'opinioneu')
plot_ate(psuedo_euopinion[0], psuedo_euopinion[1], 
         [-0.1, 0.4, 0, 3], label ='Potisitve Opinion EU - General (Psuedo Data)')

# spain
euopinion_es = both_model(df[df['country']==1], 'opinioneu')
plot_ate(euopinion_es[0], euopinion_es[1], 
         [-0.5, 0.1, 0, 3], label ='Potisitve Opinion EU - Spain')

psuedo_euopinion_es = both_model(psuedo_df[psuedo_df['country']==1], 'opinioneu')
plot_ate(psuedo_euopinion_es[0], psuedo_euopinion_es[1], 
         [-0.1, 0.4, 0, 3], label ='Potisitve Opinion EU - Spain (Psuedo Data)')

# germany
euopinion_de = both_model(df[df['country']==2], 'opinioneu')
plot_ate(euopinion_de[0], euopinion_de[1], 
         [-0.5, 0.1, 0, 3], label ='Potisitve Opinion EU - Germany')

psuedo_euopinion_de = both_model(psuedo_df[psuedo_df['country']==2], 'opinioneu')
plot_ate(psuedo_euopinion_de[0], psuedo_euopinion_de[1], 
         [-0.1, 0.4, 0, 3], label ='Potisitve Opinion EU - Germany (Psuedo Data)')


# eu good for the country
countryeu = both_model(df, 'countryeu')
plot_ate(countryeu[0], countryeu[1], 
         [-0.3, 0.1, 0, 3], label ='EU Good for the Country - General')

psuedo_countryeu = both_model(psuedo_df, 'countryeu')
plot_ate(psuedo_countryeu[0], psuedo_countryeu[1], 
         [-0.3, 0.1, 0, 3], label ='EU Good for the Country - General (Psuedo Data)')

# spain
countryeu_es = both_model(df[df['country']==1], 'countryeu')
plot_ate(countryeu_es[0], countryeu_es[1], 
         [-0.3, 0.1, 0, 3], label ='EU Good for the Country - Spain')

psuedo_countryeu_es = both_model(psuedo_df[psuedo_df['country']==1], 'countryeu')
plot_ate(psuedo_countryeu_es[0], psuedo_countryeu_es[1], 
         [-0.3, 0.1, 0, 3], label ='EU Good for the Country - Spain (Psuedo Data)')

# germany
countryeu_de = both_model(df[df['country']==2], 'countryeu')
plot_ate(countryeu_de[0], countryeu_de[1], 
         [-0.3, 0.1, 0, 3], label ='EU Good for the Country - Germany')

psuedo_countryeu_de = both_model(psuedo_df[psuedo_df['country']==2], 'countryeu')
plot_ate(psuedo_countryeu_de[0], psuedo_countryeu_de[1], 
         [-0.3, 0.1, 0, 3], label ='EU Good for the Country - Germany (Psuedo Data)')

#%% two dimensions of the crisis
# economic dimension
# spain
econ_dim_es = both_model(df[df['country']==1], 'economic_mechanisms')
plot_ate(econ_dim_es[0], econ_dim_es[1], 
         [-0.6, 0.1, 0, 3], label ='Economic Dimension - Spain')

psuedo_econ_dim_es = both_model(psuedo_df[psuedo_df['country']==1], 'economic_mechanisms')
plot_ate(psuedo_econ_dim_es[0], psuedo_econ_dim_es[1], 
         [-0.4, 0.5, 0, 3], label ='Economic Dimension - Spain (Psuedo Data)')

# germany
econ_dim_de = both_model(df[df['country']==2], 'economic_mechanisms')
plot_ate(econ_dim_de[0], econ_dim_de[1], 
         [-0.6, 0.1, 0, 3], label ='Economic Dimension - Germany')

psuedo_econ_dim_de = both_model(psuedo_df[psuedo_df['country']==2], 'economic_mechanisms')
plot_ate(psuedo_econ_dim_de[0], psuedo_econ_dim_de[1], 
         [-0.4, 0.5, 0, 3], label ='Economic Dimension - Germany (Psuedo Data)')


# representation dimension
# spain
represent_dim_es = both_model(df[df['country']==1], 'representation_mechanisms')
plot_ate(represent_dim_es[0], represent_dim_es[1], 
         [-0.2, 0.4, 0, 3], label ='Representation Dimension - Spain')

psuedo_represent_dim_es = both_model(psuedo_df[psuedo_df['country']==1], 'representation_mechanisms')
plot_ate(psuedo_represent_dim_es[0], psuedo_represent_dim_es[1], 
         [-0.4, 0.3, 0, 3], label ='Representation Dimension - Spain (Psuedo Data)')

# germany
represent_dim_de = both_model(df[df['country']==2], 'representation_mechanisms')
plot_ate(represent_dim_de[0], represent_dim_de[1], 
         [-0.2, 0.4, 0, 3], label ='Representation Dimension - Germany')

psuedo_represent_dim_de = both_model(psuedo_df[psuedo_df['country']==2], 'representation_mechanisms')
plot_ate(psuedo_represent_dim_de[0], psuedo_represent_dim_de[1], 
         [-0.4, 0.3, 0, 3], label ='Representation Dimension - Germany (Psuedo Data)')


