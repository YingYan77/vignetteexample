#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Mar 24 23:17:54 2025

@author: ying
"""

import pandas as pd
import numpy as np

# Set random seed for reproducibility
np.random.seed(42)

# Define sample sizes
n_spain = 1166
n_germany = 1147

# Define distributions based on Eurostat and other sources
age_spain = np.random.normal(loc=44, scale=18, size=n_spain).astype(int)  # Mean ~44 years
age_germany = np.random.normal(loc=46, scale=19, size=n_germany).astype(int)  # Mean ~46 years

gender_spain = np.random.choice([1, 2], size=n_spain, p=[0.49, 0.51])  # Approximate male-female ratio
gender_germany = np.random.choice([1, 2], size=n_germany, p=[0.48, 0.52])

education_spain = np.random.choice([1, 2, 3], size=n_spain, p=[0.25, 0.45, 0.30])
education_germany = np.random.choice([1, 2, 3], size=n_germany, p=[0.18, 0.40, 0.42])

employment_spain = np.random.choice([0, 1], size=n_spain, p=[0.85, 0.15])  # Unemployment ~15%
employment_germany = np.random.choice([0, 1], size=n_germany, p=[0.94, 0.06])  # Unemployment ~6%

treatment_spain = np.random.choice([0, 1], size=n_spain, p=[0.5, 0.5])
treatment_germany = np.random.choice([0, 1], size=n_germany, p=[0.5, 0.5])

# Generate responses based on sociodemographic variables
def generate_responses(n, treatment):
    satdemo = np.random.choice(range(7), size=n, p=[0.10, 0.15, 0.20, 0.20, 0.15, 0.10, 0.10])
    european_citizen = np.random.choice(range(1, 7), size=n, p=[0.10, 0.15, 0.20, 0.20, 0.25, 0.10])
    
    crisis_country = np.random.choice(range(11), size=n, p=[0.05, 0.05, 0.10, 0.10, 0.15, 0.15, 0.10, 0.10, 0.10, 0.05, 0.05])
    economicsituation = np.random.choice(range(1, 6), size=n, p=[0.10, 0.15, 0.20, 0.25, 0.30])
    
    # Attitudinal questions about the EU
    responses = np.array([
        np.random.choice(range(1, 7), size=n, p=[0.10, 0.15, 0.20, 0.25, 0.20, 0.10]) for _ in range(6)
    ]).T

    return np.column_stack([satdemo, european_citizen, crisis_country, economicsituation, responses])

responses_spain = generate_responses(n_spain, treatment_spain)
responses_germany = generate_responses(n_germany, treatment_germany)

# Create DataFrames
columns = ["satdemo", "european_citizen", "crisis_country", "economicsituation",
           "opinioneu", "countryeu", "eubenefic", "euworth", "eurestric", "eunotall"]

df_spain = pd.DataFrame(responses_spain, columns=columns)
df_germany = pd.DataFrame(responses_germany, columns=columns)

df_spain.insert(0, "Nationality", 1)
df_spain.insert(1, "Age", age_spain)
df_spain.insert(2, "Gender", gender_spain)
df_spain.insert(3, "Education", education_spain)
df_spain.insert(4, "Employment", employment_spain)
df_spain.insert(5, "Treatment", treatment_spain)

df_germany.insert(0, "Nationality", 2)
df_germany.insert(1, "Age", age_germany)
df_germany.insert(2, "Gender", gender_germany)
df_germany.insert(3, "Education", education_germany)
df_germany.insert(4, "Employment", employment_germany)
df_germany.insert(5, "Treatment", treatment_germany)

# Save to CSV
spain_path = "/mnt/data/data_spain.csv"
germany_path = "/mnt/data/data_germany.csv"

df_spain.to_csv(spain_path, index=False)
df_germany.to_csv(germany_path, index=False)

spain_path, germany_path
