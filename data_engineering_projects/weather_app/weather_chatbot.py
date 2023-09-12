from flask import Flask, request, render_template
from weather_functions import get_weather
from nltk.tokenize import word_tokenize
import nltk
nltk.download('punkt')


app = Flask(__name__)

@app.route('/chatbot', methods=['GET', 'POST'])
def chatbot():
    if request.method == 'POST':
        user_question = request.form['question']
        tokens = word_tokenize(user_question)

        # Check if the question is related to weather
        if 'temperature' in tokens and 'in' in tokens:
            # Extract the city from the question
            city_index = tokens.index('in') + 1
            city = tokens[city_index]
            response = get_weather(city)
        else:
            response = "I'm sorry, I don't understand your question."

        return render_template('chatbot.html', response=response)

    return render_template('chatbot.html', response=None)

if __name__ == '__main__':
    app.run()