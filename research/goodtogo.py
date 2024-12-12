import pandas as pd
import plotly.express as px
import streamlit as st
import folium
from streamlit_folium import st_folium

# Set Streamlit page layout
st.set_page_config(
    page_title="Admin Traffic Dashboard",
    page_icon="🚦",
    layout="wide"
)

# Load the dataset
@st.cache_data
def load_data(file_path):
    df = pd.read_excel(file_path)
    df['Start Time'] = pd.to_datetime(df['Start Time'], format='%H:%M:%S')
    df['Expected Arrival Time'] = pd.to_datetime(df['Expected Arrival Time'], format='%H:%M:%S')
    df['Actual Arrival Time'] = pd.to_datetime(df['Actual Arrival Time'], format='%H:%M:%S')
    df['Date'] = pd.to_datetime(df['Start Time']).dt.date
    df['Delay Minutes'] = df['Delay Time'].str.extract(r'(\d+)').astype(float)
    return df

file_path = "C:/Users/bvggu/OneDrive/Desktop/WEBSITE BUILD/dashbord data.xlsx"
df = load_data(file_path)

# Filters
st.sidebar.header("Filters")
start_date, end_date = st.sidebar.date_input("Select Date Range:", [df['Date'].min(), df['Date'].max()])
selected_location = st.sidebar.multiselect("Select Locations:", options=df['Stop Name'].unique(), default=df['Stop Name'].unique())

filtered_df = df[(df['Date'] >= start_date) & (df['Date'] <= end_date) & df['Stop Name'].isin(selected_location)]

# 1. Geospatial Insights: Map with Traffic Density
st.markdown("<h2 style='color: #39ff14;'>🗺️ Traffic Density Map</h2>", unsafe_allow_html=True)

# Ensure data has Latitude and Longitude columns
if 'Latitude' in filtered_df.columns and 'Longitude' in filtered_df.columns:
    map_center = [filtered_df['Latitude'].mean(), filtered_df['Longitude'].mean()]

    m = folium.Map(location=map_center, zoom_start=12)
    for _, row in filtered_df.iterrows():
        folium.CircleMarker(
            location=[row['Latitude'], row['Longitude']],
            radius=5,
            color='blue',
            fill=True,
            fill_color='blue',
            popup=f"Location: {row['Stop Name']}\nTraffic: {row['Traffic Condition']}"
        ).add_to(m)

    st_folium(m, width=800, height=500)
else:
    st.warning("Latitude and Longitude columns are missing in the dataset. Unable to generate the map.")

# 2. Traffic Conditions by Location (Bar Graph)
st.markdown("<h3 style='color: #FF69B4;'>📍 Traffic Conditions by Location</h3>", unsafe_allow_html=True)
location_traffic = filtered_df.groupby('Stop Name')['Traffic Condition'].value_counts().unstack().fillna(0)
location_traffic_plotly = px.bar(
    location_traffic,
    x=location_traffic.index,
    y=location_traffic.columns,
    title="📍 Traffic Conditions by Location",
    labels={"x": "Location", "value": "Traffic Count", "variable": "Traffic Condition"},
    color_discrete_sequence=["#FF6347", "#FFEB3B", "#32CD32"]  # Red, Yellow, Green colors
)
location_traffic_plotly.update_layout(
    template='plotly_dark',
    font=dict(color="#FFFFFF"),
    title_font=dict(size=20, color="#FFFFFF"),
    paper_bgcolor='#1f1f1f',
    plot_bgcolor='#1f1f1f'
)
st.plotly_chart(location_traffic_plotly, use_container_width=True)

# 3. Delay Time for Each Route (Bar Graph)
st.markdown("<h3 style='color: #FF69B4;'>⏱️ Delay Time for Each Route</h3>", unsafe_allow_html=True)
route_delay = filtered_df.groupby(['Source', 'Destination'])['Delay Minutes'].sum().reset_index()
fig_bar = px.bar(
    route_delay,
    x='Source',
    y='Delay Minutes',
    color='Destination',
    barmode='group',
    title="🚐 Total Delay Time for Each Route",
    text_auto=True,
    color_discrete_sequence=px.colors.qualitative.Set2
)
fig_bar.update_layout(
    template='plotly_dark',
    font=dict(color="#FFFFFF"),
    title_font=dict(size=20, color="#FFFFFF"),
    paper_bgcolor='#1f1f1f',
    plot_bgcolor='#1f1f1f'
)
st.plotly_chart(fig_bar, use_container_width=True)

# 4. Overall Traffic Conditions (Pie Chart)
st.markdown("<h3 style='color: #FF69B4;'>🚦 Overall Traffic Conditions</h3>", unsafe_allow_html=True)
overall_traffic = filtered_df['Traffic Condition'].value_counts()
fig_pie = px.pie(
    values=overall_traffic.values,
    names=overall_traffic.index,
    title="Overall Traffic Conditions",
    color_discrete_sequence=px.colors.qualitative.Pastel
)
fig_pie.update_layout(
    template='plotly_dark',
    font=dict(color="#FFFFFF"),
    title_font=dict(size=20, color="#FFFFFF"),
    paper_bgcolor='#1f1f1f'
)
st.plotly_chart(fig_pie, use_container_width=True)

# Feedback Form at the end of the dashboard
st.markdown("<h2 style='color: #39ff14;'>📊 User Feedback</h2>", unsafe_allow_html=True)
with st.form("feedback_form"):
    user_name = st.text_input("Your Name:")
    feedback = st.text_area("Your Feedback:")
    rating = st.slider("Rate the Dashboard:", min_value=1, max_value=5, step=1)
    submitted = st.form_submit_button("Submit Feedback")

    if submitted:
        st.success("Thank you for your feedback!")
        # Save feedback to a CSV or database (not implemented here)

# Displaying additional images/icons at the bottom of the dashboard
st.markdown(
    """
    <div style='text-align: center; margin: 20px;'>
        <img src='https://img.icons8.com/doodle/100/000000/bus--v1.png' alt='Bus' style='margin: 0 20px;'/>
        <img src='https://img.icons8.com/doodle/100/000000/car--v1.png' alt='Car' style='margin: 0 20px;'/>
    </div>
    """,
    unsafe_allow_html=True
)

