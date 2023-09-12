import requests
import os
import pandas as pd

current_dir = os.path.dirname(os.path.realpath(__file__))

csv_file_path = os.path.join(current_dir, 'data', 'worldcities.csv')

world_cities = pd.read_csv(csv_file_path)

base_url = 'https://api.openweathermap.org/data/2.5/weather?'
# with open('data_engineering/weather_app/config/weather_metadata.yml', 'r') as config_file:
#     config = yaml.safe_load(config_file)
api_key = 'ece1736d167de11071d24bc9aae8ba71'

def get_weather(city):
    latitude = world_cities[world_cities['city'] == city]['lat']
    longitude = world_cities[world_cities['city'] == city]['lng']
    complete_url = f'{base_url}lat={latitude}&lon={longitude}&appid={api_key}'
    response = requests.get(complete_url)
    return latitude
    # if response.status_code == 200:
    #     weather_data = response.json()

    #     # Extract relevant data from the JSON response
    #     temperature_kelvin = weather_data['main']['temp']
    #     temperature_fahrenheit = (temperature_kelvin - 273.15) * 9/5 + 32
    #     humidity = weather_data['main']['humidity']
    #     weather_description = weather_data['weather'][0]['description']
    #     # return complete_url
    #     return f"The current temperature in {city} is {temperature_fahrenheit}"
    # else:
        # return f"Error: {response.status_code}"





