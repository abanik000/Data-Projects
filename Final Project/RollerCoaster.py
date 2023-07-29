"""
Name:       Arpa Banik
CS230:      Section 4
Data:       RollerCoasters-Geo.csv
URL:        Link to your web application on Streamlit Cloud (if posted)

Description:

This program ... (List all the features you included)
"""



import streamlit as st
st.set_option('deprecation.showPyplotGlobalUse', False)
import pandas as pd
import altair as alt
import matplotlib.pyplot as plt
import folium
import seaborn as sns
import numpy as np
from streamlit_folium import folium_static

path='/Users/arpabanik/Library/CloudStorage/OneDrive-BentleyUniversity/CS230/Final Project/'
df = pd.read_csv(path+'RollerCoasters-Geo.csv')
#theme
primaryColor="#d33682"
backgroundColor="#002b36"
secondaryBackgroundColor="#586e75"
textColor="#fafafa"
font="sans serif"


#logo
logo = "/Users/arpabanik/Library/CloudStorage/OneDrive-BentleyUniversity/CS230/Final Project/logo.png"
st.image(logo, width=200)

#Title
st.markdown("<h1 style='text-align: center; color:red; white-space: nowrap;'>Roller Coasters Around United States </h1>", unsafe_allow_html=True)
#Giphy
st.markdown("![Alt Text](https://media.giphy.com/media/ux05pfGiNIkIQdUAi0/giphy.gif)")
st.divider()
st.subheader(':red[Where are the Coasters?]')

def create_map(state):
    # Filter data by state
    filtered_df = df[df["State"] == state]

    # Create map centered on state
    center_lat = filtered_df["Latitude"].mean()
    center_lon = filtered_df["Longitude"].mean()
    m = folium.Map(location=[center_lat, center_lon], zoom_start=8,tiles='Stamen Toner')

    # Add custom text to the map
    html = f'<h3><b>{state}</b></h3>'
    folium.Marker(location=[center_lat, center_lon], tooltip=state, icon=folium.Icon(color="red", icon="star")).add_to(m)
    folium.Marker(location=[center_lat, center_lon], icon=folium.Icon(color="red", icon="star")).add_to(m)
    for index, row in filtered_df.iterrows():
        name = row["Coaster"]
        park = row["Park"]
        design = row["Design"]
        year = row["Year_Opened"]
        popup_text = f"<b>{name}</b><br><i>{park}</i><br><b>Design:</b> {design}<br><b>Year opened:</b> {year}"
        folium.Marker([row["Latitude"], row["Longitude"]], popup=popup_text, tooltip=name, icon=folium.Icon(color="yellow", icon="info-sign")).add_to(m)

    return m


# Create dropdown menu for selecting state
states = df["State"].dropna().unique().tolist()
selected_state = st.selectbox(":red[Select a state]", states)

# Define the tabs
tabs = ["US Map", "State Map"]
selected_tab = st.radio(":red[Select a tab]", tabs)

# Create the maps based on the selected tab
if selected_tab == "US Map":
    # Create a map centered on the United States
    us_map = folium.Map(location=[39.8283, -98.5795], zoom_start=4,tiles='Stamen Terrain')
    tooltip = "Click me!"
    # Add a marker for each roller coaster
    for index, row in df.iterrows():
        name = row['Coaster']
        park = row['Park']
        state = row['State']
        coaster_type = row['Type']
        year_opened = row['Year_Opened']
        location = [row['Latitude'], row['Longitude']]
        popup = f"<b>Name:</b> {name}<br><b>Park:</b> {park}<br><b>State:</b> {state}<br><b>Type:</b> {coaster_type}<br><b>Year Opened:</b> {year_opened}"
        marker = folium.Marker(location=location, popup=popup,icon=folium.Icon(color='red', icon='star'))
        marker.add_to(us_map)

    # Display the US map
    folium_static(us_map)

elif selected_tab == "State Map":
    # Create map based on selected state
    if pd.isna(selected_state):
        st.write(":red[Please select a state.]")
    else:
        st.write(f":red[**Coasters in {selected_state}**]")
        state_map = create_map(selected_state)
        folium_static(state_map)

#PIVOT TABLE 1
# Pivot table with Type as the index and the mean of Max_Height and Top_Speed as the values. This will output a pivot table with the roller coaster type as the index and the mean values for the Max_Height and Top_Speed columns.
pivot1 = pd.pivot_table(df, index='Type', values=['Max_Height', 'Top_Speed'], aggfunc='mean')

#PIVOT TABLE 2
#Pivot table with the average length of coasters by state.It groups the data by state and calculates the average length of coasters in each state.
pivot2 = df.pivot_table(index='State', values='Length', aggfunc='mean')

# Display the pivot tables side by side using Streamlit columns layout
col1, col2 = st.columns(2)

with col1:
    st.subheader(":red[Max Height and Top Speed]")
    st.write(pivot1)
    st.write("**Outputs a pivot table with the roller coaster type as the index and the mean values for the Max_Height and Top_Speed columns.**")

with col2:
    st.subheader(":red[Average Length of Coasters by State]")
    st.write(pivot2)
    st.write("**This table groups the data by state and calculates the average length of coasters in each state**")
st.divider()
# Add a slider for year opened
year_slider = st.slider(':red[Year opened]', 1900, 2023, (1970, 2023))
st.divider()
# Adds a multiselect for coaster type
coaster_type = st.multiselect(':red[Coaster type]', df['Type'].unique())
st.divider()
# Adds a text input for park name
park_name = st.text_input(':red[Park name]')
# Text input field for the user to enter the name of the coaster
coaster_name = st.text_input(":red[Enter the name of the coaster:]")

# Filters the coaster data based on the user input using one condition
if coaster_name:
    filtered_data = df[df["Coaster"].str.contains(coaster_name, case=False)]
    st.write(filtered_data)


# Filters the data based on the user's selections using two conditions
filtered_data = df[(df['Year_Opened'] >= year_slider[0]) & (df['Year_Opened'] <= year_slider[1])]
if coaster_type:
    filtered_data = filtered_data[filtered_data['Type'].isin(coaster_type)]
if park_name:
    filtered_data = filtered_data[filtered_data['Park'].str.contains(park_name, case=False)]
# Display the filtered data in a table
st.write(filtered_data)
# Or display a bar chart of the top coaster types
if coaster_type:
    top_coasters = filtered_data['Type'].value_counts().head()
    st.bar_chart(top_coasters)
st.divider()
# Create a drop-down menu for selecting the coaster type
coaster_type = st.sidebar.selectbox(
    ":red[Select a coaster type:]",
    options=df["Type"].unique())

# Filter the data by the selected coaster type
filtered_df = df[df["Type"] == coaster_type]

# Group the data by park and count the number of coasters
park_count = filtered_df.groupby("Park")["Coaster"].count().reset_index()
park_count.columns = ["Park", "Coaster Count"]

# Find the park with the highest number of coasters
max_count = park_count["Coaster Count"].max()
max_park = park_count[park_count["Coaster Count"] == max_count]["Park"].values[0]
# Show the results
st.write(f"**The park with the most {coaster_type} coasters is {max_park} with {max_count} coasters.**")
st.divider()
st.write(":red[Here's a bar chart of the number of coasters by park:]")
#Specifies that the chart will be a bar chart
chart = alt.Chart(park_count).mark_bar().encode(
    x=alt.X("Coaster Count", title="Number of Coasters"),
    y=alt.Y("Park", title="Park"),
    tooltip=["Park", "Coaster Count"]
#Set the width and height of the chart
).properties(
    width=600,
    height=400
)
st.altair_chart(chart)
st.write("**As shown by the bar chart, Big Chief Carts and Coasters has the highest number of coasters of 3.**")
st.divider()
# Create a radio button to select a column
selected_column = st.sidebar.radio(":red[Select a column:]", df.columns)
# Display the selected column
st.write(f":red[You selected the column:] {selected_column}")

st.write(df[[selected_column]])
st.divider()
# Define function to calculate average coaster length by state
df['Length'] = df['Length'].fillna(df['Length'].mean())
def get_average_coaster_length_by_state(state):
    state_coasters = df[df["State"] == state]
    return state_coasters["Length"].mean()

# Create drop-down menu for user to select state
states = df["State"].dropna().unique().tolist()
selected_state = st.selectbox(":red[Select a state]", states, key="state_selector")

# Calculate average length of coasters in selected state
average_length = get_average_coaster_length_by_state(selected_state)

# Display results to user
if pd.isna(average_length):
    st.write("Sorry, no data available for selected state.")
else:
    st.write(f"**The average length of coasters in {selected_state} is {round(average_length, 2)} feet.**")

# Visualize results with line chart
state_lengths = df[df["Length"].apply(lambda x: isinstance(x, (int, float)))].groupby("State").agg({"Length": "mean"}).reset_index()

state_lengths = state_lengths[state_lengths["State"].isin(states)]
state_lengths = state_lengths.sort_values("Length", ascending=False)
fig, ax = plt.subplots()
ax.plot(state_lengths["State"], state_lengths["Length"])
ax.set_xlabel("State")
ax.set_ylabel("Average Coaster Length (feet)")
ax.set_title("Average Coaster Length by State")
ax.tick_params(axis='x', labelrotation=90)
st.pyplot(fig)


# sort the DataFrame by the "Inversions" column in descending order
sorted_df = df.sort_values('Num_of_Inversions', ascending=False)

# get the name of the coaster with the most inversions
coaster_with_most_inversions = sorted_df.iloc[0]['Coaster']

print(coaster_with_most_inversions)
# create a scatter plot with coaster length on the x-axis and number of inversions on the y-axis
plt.scatter(df['Length'], df['Num_of_Inversions'])

# add axis labels
plt.xlabel('Coaster Length')
plt.ylabel('Number of Inversions')

# show the plot
plt.show()

# Define a checkbox to filter coasters with inversions
inversions_checkbox = st.sidebar.checkbox(":red[Include only coasters with inversions]")

# Apply the inversion filter if the checkbox is checked
if inversions_checkbox:
    df = df[df["Inversions"] == 'Y']
# Display the filtered data in a table
st.write(df)

#Plot histogram
plt.hist(df["Max_Height"], bins=20)
plt.xlabel("Max Height (feet)")
plt.ylabel("Count")

# Display plot in Streamlit app
#st.pyplot()
st.divider()
# Set style and context for Seaborn
sns.set_style("whitegrid")
sns.set_context("talk")

# Joint plot with hexbins and marginal distributions
joint_plot = sns.jointplot(data=df, x="Max_Height", y="Top_Speed", kind="hex",
                           color="skyblue", height=10)

# Set labels and title for plot
joint_plot.set_axis_labels("Max Height (feet)", "Top Speed (mph)")
joint_plot.fig.suptitle("Max Height vs Top Speed of Roller Coasters")

# Display plot in Streamlit app
st.pyplot()

st.write("**This is a joint plot with hexbins and marginal distributions using Seaborn library. The data used for the plot is from a Pandas DataFrame df, with Max_Height and Top_Speed columns as x and y axes respectively. The plot is styled with white grid and a larger context size.**")
st.divider()
# Set style and context for Seaborn
sns.set_style("whitegrid")
sns.set_context("talk")

# Create scatter plot with multiple semantics
scatter_plot = sns.scatterplot(data=df, x="Max_Height", y="Top_Speed", hue="Type", size="Length", sizes=(50, 200),
                               palette="Set2", alpha=0.8)

# Set labels and title for plot
scatter_plot.set(xlabel="Max Height (feet)", ylabel="Top Speed (mph)")
scatter_plot.set_title("Max Height vs Top Speed of Roller Coasters by Type and Length")

# Display plot in Streamlit app
st.pyplot()
st.write("**This is a scatter plot with multiple semantics using Seaborn library. The dataset used has columns such as 'Max_Height', 'Top_Speed', 'Type', and 'Length'.**")
st.divider()
# Calculate summary statistics using NumPy
max_height_mean = round(np.mean(df["Max_Height"]),2)
max_height_std = round(np.std(df["Max_Height"]),2)
top_speed_mean = round(np.mean(df["Top_Speed"]),2)
top_speed_std = round(np.std(df["Top_Speed"]),2)
max_inversions_mean = np.mean(df["Num_of_Inversions"])
max_inversions_std = np.std(df["Num_of_Inversions"])

st.subheader(":red[Summary Report]")
# Create summary report
summary_report = pd.DataFrame({
    'Statistic': ['Mean Max Height', 'Standard Deviation of Max Height', 'Mean Top Speed', 'Standard Deviation of Top Speed', 'Mean Number of Inversions', 'Standard Deviation of Number of Inversions'],
    'Value': [max_height_mean, max_height_std, top_speed_mean, top_speed_std, max_inversions_mean, max_inversions_std]
})
st.write(summary_report)