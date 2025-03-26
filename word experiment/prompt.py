#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Mar 26 10:40:24 2025

@author: ying
"""
import pandas as pd
import numpy as np

# Regenerate the full dataset

# Set random seed for reproducibility
np.random.seed(42)

# Sample size
n = 1590

# Generate demographic distributions

# Age distribution (realistic age brackets)
age = np.random.normal(loc=45, scale=15, size=n).astype(int)
age = np.clip(age, 16, 95)  # Ensuring age limits

# Gender distribution (approximate U.S. distribution)
gender_probs = [0.49, 0.50, 0.005, 0.005]  # Man, Woman, Non-binary, Self-describe
gender = np.random.choice([1, 2, 3, 4], size=n, p=gender_probs)

# Education distribution (based on U.S. Census)
education_probs = [0.1, 0.3, 0.2, 0.1, 0.2, 0.1]
education = np.random.choice([1, 2, 3, 4, 5, 6], size=n, p=education_probs)

# Adjusted Income distribution (normalized)
income_probs = np.array([0.15, 0.10, 0.10, 0.10, 0.10, 0.10, 0.10, 0.10, 0.05, 0.05, 0.025, 0.025, 0.025])
income_probs /= income_probs.sum()
income = np.random.choice(range(1, 14), size=n, p=income_probs)

# Ethnicity distribution (based on U.S. Census estimates)
ethnicity_probs = [0.60, 0.12, 0.18, 0.06, 0.01, 0.02, 0.005, 0.005]
ethnicity = np.random.choice([1, 2, 3, 4, 5, 6, 7, 9], size=n, p=ethnicity_probs)

# Multi-select ethnicity for those selecting "Two or more races" (value=6)
multi_ethnicity = np.where(ethnicity == 6, 
                           np.random.choice([1, 2, 3, 4, 5, 6, 7], size=n), 
                           np.nan)

# Ideology distribution
ideology_probs = [0.25, 0.15, 0.30, 0.15, 0.15]
ideology = np.random.choice([1, 2, 3, 4, 5], size=n, p=ideology_probs)

# Experimental conditions
welfare_word = np.random.choice([0, 1], size=n)
rr_post = np.random.choice([0, 1], size=n)

# Generate responses
def policy_response(word):
    if word == 0:
        return np.random.choice([1, 2, 3], p=[0.45, 0.35, 0.20])
    else:
        return np.random.choice([1, 2, 3], p=[0.30, 0.50, 0.20])

Q32 = np.where(welfare_word == 1, [policy_response(1) for _ in range(n)], np.nan)
Q33 = np.where(welfare_word == 0, [policy_response(0) for _ in range(n)], np.nan)

def racial_resentment(ideo, eth):
    bias = ideo - 3  
    if eth == 2 or eth == 3:  
        bias -= 1
    return np.clip(np.random.normal(3 + bias, 1), 1, 5).astype(int)

Q22 = [racial_resentment(ideology[i], ethnicity[i]) for i in range(n)]
Q23 = [racial_resentment(ideology[i], ethnicity[i]) for i in range(n)]
Q24 = [racial_resentment(ideology[i], ethnicity[i]) for i in range(n)]
Q25 = [racial_resentment(ideology[i], ethnicity[i]) for i in range(n)]

# Construct dataframe
df = pd.DataFrame({
    "age": age,
    "gender": gender,
    "education": education,
    "income": income,
    "ethnicity": ethnicity,
    "multi_ethnicity": multi_ethnicity,
    "ideology": ideology,
    "welfare_word": welfare_word,
    "rr_post": rr_post,
    "Q32": Q32,
    "Q33": Q33,
    "Q22": Q22,
    "Q23": Q23,
    "Q24": Q24,
    "Q25": Q25
})

# Save dataset
csv_filename = "data_recialresentment.csv"
df.to_csv(csv_filename, index=False)
csv_filename
