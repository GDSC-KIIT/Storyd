from numpy import argmax, array
from flask import Flask, jsonify, render_template, request, url_for
from tensorflow.keras.models import load_model
from function_pool import KeyWordGenerator, SentimentDetector

app = Flask(__name__)

sentimentDetector = SentimentDetector()
keywordsDetector = KeyWordGenerator()


@app.route('/')
@app.route('/api')
def home():
    return render_template("home.html")

@app.route('/api')
@app.route('/api/sentiment', methods=['POST'])
def sentiment():
    text = ""
    if request.method == 'POST':
        text = request.form.get("text", "")

    return jsonify(sentimentDetector.get_sentiment_data(text))


@app.route('/api/keywords', methods=['POST'])
def keywords():
    text = ""
    n_ = 7
    if request.method == 'POST':
        text = request.form.get("text", "")
        n_ = int(request.form.get("n", "7"))

    return jsonify({
        "keywords": keywordsDetector.get_keywords(text, n=n_)
    })


if __name__ == '__main__':
    app.run(debug=True)
