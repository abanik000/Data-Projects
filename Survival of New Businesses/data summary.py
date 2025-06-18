import pandas as pd
import numpy as np

# Load your dataset
df=pd.read_csv("/Users/arpabanik/Library/CloudStorage/OneDrive-BentleyUniversity/MA 380/Capstone/Final/founder_survival_data_ranked.csv")
# Step 1: Censoring and Survival Time Calculation
df["EndYear_Clean"] = df["CompanyEndYear"].apply(lambda x: 1990 if x == "Business still registered" else int(x))
df["Censored"] = df["CompanyEndYear"].apply(lambda x: 1 if x == "Business still registered" else 0)
df["SurvivalTime"] = df["EndYear_Clean"] - df["StartYear"]

# Convert 'FollowerBusiness' to binary: 1 if 'Follower', 0 otherwise
df["FollowerBusiness"] = df["FollowerBusiness"].apply(
    lambda x: 1 if isinstance(x, str) and x.strip().lower() == "follower" else 0
)
df["IndAffBusiness"] = df["IndAffBusiness"].apply(
    lambda x: 1 if isinstance(x, str) and x.strip().lower() == "affiliated" else 0
)


# Step 2: Keep valid observations (positive survival time)
df_survival_set = df[df["SurvivalTime"] >= 0].copy()
df_survival_set["YearsWorkExperience"] = pd.to_numeric(df_survival_set["YearsWorkExperience"], errors="coerce")
industry_map = {
    "IndustryManufacturing": "manufacturing",
    "IndustryConstruction": "construction",
    "IndustryWholesale": "wholesale",
    "IndustryTransport": "transport",
    "IndustryRestaurant": "restaurant",
    "IndustryComputer": "computer",
    "IndustryOtherService": "service"
}
print("After numeric conversion of CapitalInvested:", df_survival_set["CapitalInvested"].notna().sum())
print("After numeric conversion of EmployeeNum:", df_survival_set["EmployeeNum"].notna().sum())
print("After conversion of YearsWorkExperience:", df_survival_set["YearsWorkExperience"].notna().sum())

for new_col, keyword in industry_map.items():
    df_survival_set[new_col] = df_survival_set["industry_category"].apply(
        lambda x: 1 if isinstance(x, str) and keyword in x.lower() else 0
    )


# Step 3: Create binary flag for Munich using Location
df_survival_set["MunichFlag"] = df_survival_set["Location"].apply(lambda x: 1 if isinstance(x, str) and "munich" in x.lower() else 0)
df_survival_set["CapitalInvested"] = pd.to_numeric(df_survival_set["CapitalInvested"], errors="coerce")

df_survival_set["EmployeeNum"] = pd.to_numeric(df_survival_set["EmployeeNum"], errors="coerce")
df_survival_set["RegisteredFirm"] = df_survival_set["LegalForm"].apply(
    lambda x: 1 if isinstance(x, str) and "registered" in x.lower() else 0
)
# Convert 'GenSpeBusiness' to 1 = Specialist, 0 = Generalist
df_survival_set["GenSpeBusiness"] = df_survival_set["GenSpeBusiness"].apply(
    lambda x: 1 if isinstance(x, str) and "specialist" in x.lower() else 0
)

# Convert 'TradInnoBusiness' to 1 = Innovative, 0 = Traditional
df_survival_set["TradInnoBusiness"] = df_survival_set["TradInnoBusiness"].apply(
    lambda x: 1 if isinstance(x, str) and "innovative" in x.lower() else 0
)

# Convert 'MarketScope' to 1 = National, 0 = Local
df_survival_set["MarketScope"] = df_survival_set["MarketScope"].apply(
    lambda x: 1 if isinstance(x, str) and "national" in x.lower() else 0
)


# Step 4: Compute Descriptive Summary
summary = {}

summary["Mean years of schooling"] = (df_survival_set["YearsSchooling"].mean(), df_survival_set["YearsSchooling"].std())
summary["Mean years of work experience"] = (df_survival_set["YearsWorkExperience"].mean(), df_survival_set["YearsWorkExperience"].std())

summary["Percent with industry-specific experience"] = (df_survival_set["IndustryExperience"].mean() * 100,)
summary["Percent with self-employment experience"] = (df_survival_set["SelfEmploymentExp"].mean() * 100,)
summary["Percent with self-employed father"] = (df_survival_set["FounderFather"].mean() * 100,)
summary["Percent follower business"] = (df_survival_set["FollowerBusiness"].mean() * 100,)
summary["Percent affiliated business"] = (df_survival_set["IndAffBusiness"].mean() * 100,)

summary["Mean amount of capital invested (DM, log)"] = (
    df_survival_set["CapitalInvested"]
        .apply(lambda x: np.log(x + 1) if pd.notna(x) and x > 0 else 0)
        .mean(),
    df_survival_set["CapitalInvested"]
        .apply(lambda x: np.log(x + 1) if pd.notna(x) and x > 0 else 0)
        .std()
)


summary["Mean number of employees at founding (log)"] = (
    df_survival_set["EmployeeNum"]
        .apply(lambda x: np.log(x + 1) if pd.notna(x) and x > 0 else 0)
        .mean(),
    df_survival_set["EmployeeNum"]
        .apply(lambda x: np.log(x + 1) if pd.notna(x) and x > 0 else 0)
        .std()
)

summary["Percent registered firm"] = (df_survival_set["RegisteredFirm"].mean() * 100,)

summary["Percent specialist business"] = (df_survival_set["GenSpeBusiness"].mean() * 100,)
summary["Percent innovative business"] = (df_survival_set["TradInnoBusiness"].mean() * 100,)
summary["Percent national market-scope business"] = (df_survival_set["MarketScope"].mean() * 100,)

summary["Percent Munich"] = (df_survival_set["MunichFlag"].mean() * 100,)

summary["Percent manufacturing"] = (df_survival_set["IndustryManufacturing"].mean() * 100,)
summary["Percent construction"] = (df_survival_set["IndustryConstruction"].mean() * 100,)
summary["Percent wholesale/retail trade"] = (df_survival_set["IndustryWholesale"].mean() * 100,)
summary["Percent transportation"] = (df_survival_set["IndustryTransport"].mean() * 100,)
summary["Percent restaurants"] = (df_survival_set["IndustryRestaurant"].mean() * 100,)
summary["Percent computer services"] = (df_survival_set["IndustryComputer"].mean() * 100,)
summary["Percent other services"] = (df_survival_set["IndustryOtherService"].mean() * 100,)

summary["Mean intensity of competition"] = (
    df_survival_set["CompetitionIntensity"].mean(),
    df_survival_set["CompetitionIntensity"].std()
)
summary["Mean seasonality"] = (
    df_survival_set["Seasonality"].mean(),
    df_survival_set["Seasonality"].std()
)
summary["Mean clustering of business orders"] = (
    df_survival_set["OrderClusters"].mean(),
    df_survival_set["OrderClusters"].std()
)

summary["Number of cases"] = (len(df_survival_set),)

# Convert to DataFrame
summary_df = pd.DataFrame.from_dict(summary, orient="index", columns=["Mean", "Std Dev"])
print(summary_df)
# Print unique values of suspicious columns
print(df["FollowerBusiness"].unique())
print(df["IndAffBusiness"].unique())
