import pandas as pd
import numpy as np
# Load both datasets
df = pd.read_csv("/Users/arpabanik/Library/CloudStorage/OneDrive-BentleyUniversity/MA 380/Capstone/Final/founder_survival_data_ranked.csv")

# Clean and create survival time variable
# We'll convert "Business still registered" to a right-censored flag and calculate duration
current_year = 1990
df["EndYear_Clean"] = df["EndYear_Clean"].apply(lambda x: 1900 + x if x < 100 else x)
df["Censored"] = df["CompanyEndYear"].apply(lambda x: 1 if x == "Business still registered" else 0)
df["SurvivalTime"] = df["EndYear_Clean"] - df["StartYear"]

# Display a preview of the survival data
df[["befnr", "StartYear", "CompanyEndYear", "EndYear_Clean", "Censored", "SurvivalTime"]].head()

'''
# Capital invested (convert to numeric, log)
df["CapitalInvested"] = pd.to_numeric(df["CapitalInvested"], errors='coerce')
df["LogCapital"] = df["CapitalInvested"].apply(lambda x: np.log(x + 1) if pd.notna(x) and x > 0 else 0)

# Employees (convert to numeric, log)
df["EmployeeNum"] = pd.to_numeric(df["EmployeeNum"], errors='coerce')
df["LogEmployees"] = df["EmployeeNum"].apply(lambda x: np.log(x + 1) if pd.notna(x) and x > 0 else 0)

# Registered firm: 1 if not 'Small tradesman'
df["RegisteredFirm"] = df["LegalForm"].apply(lambda x: 0 if isinstance(x, str) and "small tradesman" in x.lower() else 1)

# National market scope
df["NationalMarket"] = df["MarketScope"].apply(lambda x: 1 if isinstance(x, str) and "national" in x.lower() else 0)

# Specialist vs Generalist
df["Specialist"] = df["GenSpeBusiness"].apply(lambda x: 1 if isinstance(x, str) and "specialist" in x.lower() else 0)

# Innovative vs Traditional
df["Innovative"] = df["TradInnoBusiness"].apply(lambda x: 1 if isinstance(x, str) and "innovative" in x.lower() else 0)

df["IndustryExp"] = df["IndustryExperience"].fillna(0).astype(int)
df["SelfEmployedFather"] = df["FounderFather"].fillna(0).astype(int)

df["Follower"] = df["FollowerBusiness"].apply(lambda x: 1 if isinstance(x, str) and x.strip().lower() == "follower" else 0)
df["Affiliated"] = df["IndAffBusiness"].apply(lambda x: 1 if isinstance(x, str) and x.strip().lower() == "affiliated" else 0)


# Recalculate the descriptive statistics of cleaned independent variables
df[[
    "YearsSchooling", "YearsWorkExperience", "IndustryExp", "SelfEmployedFather",
    "Follower", "Affiliated", "LogCapital", "LogEmployees", "RegisteredFirm",
    "NationalMarket", "Specialist", "Innovative"
]].describe()

import pandas as pd
import numpy as np
from lifelines import LogLogisticAFTFitter


# Load your dataset
df = pd.read_csv("final_founder_dataset.csv")

# STEP 1: Create Survival Variables
current_year = 1990
df["EndYear_Clean"] = df["CompanyEndYear"].apply(lambda x: current_year if x == "Business still registered" else int(x))
df["Censored"] = df["CompanyEndYear"].apply(lambda x: 1 if x == "Business still registered" else 0)
df["SurvivalTime"] = df["EndYear_Clean"] - df["StartYear"]

# STEP 2: Create Independent Variables (Replicating Brüderl et al. Model)
df["IndustryExp"] = df["IndustryExperience"].fillna(0).astype(int)
df["SelfEmployedFather"] = df["FounderFather"].fillna(0).astype(int)
df["YearsWorkExperience"] = pd.to_numeric(df["YearsWorkExperience"], errors='coerce')
df["YearsSchooling"] = pd.to_numeric(df["YearsSchooling"], errors='coerce')

df["Follower"] = df["FollowerBusiness"].apply(lambda x: 1 if isinstance(x, str) and x.strip().lower() == "follower" else 0)
df["Affiliated"] = df["IndAffBusiness"].apply(lambda x: 1 if isinstance(x, str) and x.strip().lower() == "affiliated" else 0)

df["CapitalInvested"] = pd.to_numeric(df["CapitalInvested"], errors='coerce')
df["LogCapital"] = df["CapitalInvested"].apply(lambda x: np.log(x + 1) if pd.notna(x) and x > 0 else 0)

df["EmployeeNum"] = pd.to_numeric(df["EmployeeNum"], errors='coerce')
df["LogEmployees"] = df["EmployeeNum"].apply(lambda x: np.log(x + 1) if pd.notna(x) and x > 0 else 0)

df["RegisteredFirm"] = df["LegalForm"].apply(lambda x: 0 if isinstance(x, str) and "small tradesman" in x.lower() else 1)
df["NationalMarket"] = df["MarketScope"].apply(lambda x: 1 if isinstance(x, str) and "national" in x.lower() else 0)
df["Specialist"] = df["GenSpeBusiness"].apply(lambda x: 1 if isinstance(x, str) and "specialist" in x.lower() else 0)
df["Innovative"] = df["TradInnoBusiness"].apply(lambda x: 1 if isinstance(x, str) and "innovative" in x.lower() else 0)

# STEP 3: Subset and Clean the Data for Modeling
model_df = df[[
    "SurvivalTime", "Censored",
    "YearsSchooling", "YearsWorkExperience", "IndustryExp", "SelfEmployedFather",
    "Follower", "Affiliated", "LogCapital", "LogEmployees", "RegisteredFirm",
    "Specialist", "Innovative", "NationalMarket"
]].dropna()

# Drop non-positive durations
model_df = model_df[model_df["SurvivalTime"] > 0]

# STEP 4: Fit the Log-Logistic Survival Model


from lifelines import LogLogisticAFTFitter

llf = LogLogisticAFTFitter(penalizer=0.01)
llf.fit(model_df, duration_col="SurvivalTime", event_col="Censored")
llf.print_summary()
'''
df.to_csv("/Users/arpabanik/Library/CloudStorage/OneDrive-BentleyUniversity/MA 380/Capstone/Final/founder_survival_data_ranked.csv", index=False)
