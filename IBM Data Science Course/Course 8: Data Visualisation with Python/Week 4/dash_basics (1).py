# Import required packages
import pandas as pd
import plotly.express as px
import dash
import dash_html_components as html
import dash_core_components as dcc

# Read the airline data into pandas dataframe
airline_data =  pd.read_csv('https://cf-courses-data.s3.us.cloud-object-storage.appdomain.cloud/IBMDeveloperSkillsNetwork-DV0101EN-SkillsNetwork/Data%20Files/airline_data.csv', 
                            encoding = "ISO-8859-1",
                            dtype={'Div1Airport': str, 'Div1TailNum': str, 'Div2Airport': str, 'Div2TailNum': str})

# Randomly sample 500 data points. Setting the random state to be 42 so that we get same result.
data = airline_data.sample(n=500, random_state=42)

# Pie Chart Creation
fig = px.pie(data, values='Flights', names='DistanceGroup', title='Distance group proportion by flights')

# Create a dash application
app = dash.Dash(__name__)

# Get the layout of the application and adjust it.
# Create an outer division using html.Div and add title to the dashboard using html.H1 component
# Add description about the graph using HTML P (paragraph) component
# Finally, add graph component.

#  Exercise:
#  Change the title to the dashboard from "Airline Dashboard" to "Airline On-time Performance Dashboard" using HTML H1 component and font-size as 50. 
#  Save the above changes and relaunch the dashboard application to see the updated dashboard title. Then
#  Click on file --> save file.Then go to terminal and Run the command python3 dash_basics.py to open the updated file again and relaunch the application by entering the port number.The updated dashboard title will be seen.
app.layout = html.Div(children=[html.H1('Airline On-time Performance Dashboard', style={'textAlign': 'center', 'color': '#503D36', 'font-size': 50}),
                                html.P('Proportion of distance group (250 mile distance interval group) by flights.', style={'textAlign':'center', 'color': '#F57241'}),
                                dcc.Graph(figure=fig),

                    ])

# Run the application                   
if __name__ == '__main__':
    app.run_server()

# See Image Figure1C8WK4