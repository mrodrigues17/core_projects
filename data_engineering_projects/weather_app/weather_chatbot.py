import nltk
from nltk.tokenize import word_tokenize
from flask import Flask, request, jsonify
from weather_functions import get_weather

app = Flask(__name__)

@app.route('/chatbot', methods=['POST'])
# def chatbot():
#     user_question = request.form['question']
#     tokens = word_tokenize(user_question)
    
#     # Check if the question is related to weather
#     if 'temperature' in tokens and 'in' in tokens:
#         # Extract the city from the question
#         city_index = tokens.index('in') + 1
#         city = tokens[city_index]
#         response = get_weather(city)
#     else:
#         response = "I'm sorry, I don't understand your question."
    
#     return jsonify({'response': response})
def print_example():
    return 'hello world'

if __name__ == '__main__':
    app.run(debug=True)

