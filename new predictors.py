import pandas as pd
import numpy as np
# Load the uploaded file
df = pd.read_csv("/Users/arpabanik/Library/CloudStorage/OneDrive-BentleyUniversity/MA 380/Capstone/Final/founder_survival_data_ranked.csv")

# Rename the necessary columns for clarity
df.rename(columns={
    'v78': 'PlanningDurationMonths',
    'v79': 'WrittenBusinessPlan',
    'v110': 'Problem_FinancialIssues',
    'v111': 'Problem_WorkContribution',
    'v112': 'Problem_BusinessOrganization',
    'v113': 'Problem_Staffing',
    'v114': 'Problem_PrivateMatters',
    'v115': 'Problem_Other'
}, inplace=True)

# Cleaning PlanningDurationMonths: treat 0 and 98 as missing
df['PlanningDurationMonths'] = df['PlanningDurationMonths'].replace({0: pd.NA, 98: pd.NA})

# Cleaning WrittenBusinessPlan: 1 -> 1 (yes), 2 -> 0 (no)
df['WrittenBusinessPlan'] = df['WrittenBusinessPlan'].replace({1: 1, 2: 0})

# Clean Problem columns: ensure numeric
problem_cols = [
    'Problem_FinancialIssues', 'Problem_WorkContribution', 'Problem_BusinessOrganization',
    'Problem_Staffing', 'Problem_PrivateMatters', 'Problem_Other'
]

for col in problem_cols:
    df[col] = df[col].replace({8: pd.NA, 1: 1, 2: 0})
    df[col] = pd.to_numeric(df[col], errors='coerce')  # <- VERY IMPORTANT

# Create ProblemType
def assign_problem_type(row):
    for col in problem_cols:
        if row[col] == 1:
            return col.replace('Problem_', '')  # clean label
    return np.nan

df['ProblemType'] = df.apply(assign_problem_type, axis=1)

# Create AnyProblem safely
df['AnyProblem'] = df[problem_cols].sum(axis=1).apply(lambda x: 1 if x > 0 else (0 if x == 0 else np.nan))

# Save cleaned dataset if needed
df.to_csv("founder_survival_data_final.csv", index=False)

