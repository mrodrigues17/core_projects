import requests

question = "What is the current temperature in Chicago?"
response = requests.post('http://localhost:5000/chatbot', data={'question': question})
print(response.json()['response'])