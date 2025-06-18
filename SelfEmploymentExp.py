import pandas as pd

# Load the uploaded file
df = pd.read_csv("/Users/arpabanik/Library/CloudStorage/OneDrive-BentleyUniversity/MA 380/Capstone/Final/founder_survival_data_ranked.csv")

# Transform 'SelfEmploymentExp' to binary: 1 if any value, 0 if 0, and NaN if missing
df['SelfEmploymentExp_binary'] = df['SelfEmploymentExp'].apply(
    lambda x: 1 if pd.notna(x) and x != 0 else (0 if pd.notna(x) else pd.NA)
)

df.to_csv("/Users/arpabanik/Library/CloudStorage/OneDrive-BentleyUniversity/MA 380/Capstone/Final/founder_survival_data_ranked.csv", index=False)


