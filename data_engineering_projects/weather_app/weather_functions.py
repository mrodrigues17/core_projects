# def get_weather(city):
#     # Replace this with code to fetch weather data from OpenWeatherMap
#     # You can use the code from the previous answer for this purpose
#     return f"The current temperature in {city} is 72°F."



from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route('/chatbot', methods=['POST'])

def print_example():
    return 'hello world'

if __name__ == '__main__':
    app.run(debug=True)
