import requests
import os
import yaml
import pandas as pd

with open('data_engineering/weather_app/config/weather_metadata.yml', 'r') as config_file:
    config = yaml.safe_load(config_file)

api_key = config['api_key']
city = config['city']
latitude = config['latitude']
longitude = config['longitude']
cnt = config['forecast_horizon']

base_url = 'https://api.openweathermap.org/data/2.5/weather?'

complete_url = f'{base_url}lat={latitude}&lon={longitude}&appid={api_key}'

forecast_data = []

response = requests.get(complete_url)

if response.status_code == 200:
    weather_data = response.json()

    # Extract relevant data from the JSON response
    temperature_kelvin = weather_data['main']['temp']
    temperature_fahrenheit = (temperature_kelvin - 273.15) * 9/5 + 32
    humidity = weather_data['main']['humidity']
    weather_description = weather_data['weather'][0]['description']

    # Create a Pandas DataFrame to store the weather data
    df = pd.DataFrame({
        'City': [city],
        'Temperature (Fahrenheit)': [temperature_fahrenheit],
        'Humidity (%)': [humidity],
        'Weather Description': [weather_description]
    })

    # Print the DataFrame
    print(df)
else:
    print(f"Error: {response.status_code}")
