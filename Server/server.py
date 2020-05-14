import pymongo
from numpy import argmax, array
from flask import Flask, jsonify, render_template, request, url_for
from tensorflow.keras.models import load_model
from function_pool import KeyWordGenerator, SentimentDetector, RecommendationEngine

app = Flask(__name__)

# Loading Mongo Driver
mongoClient = pymongo.MongoClient("localhost", 27017)
db = mongoClient.storyBasedSocialMedia

# Initializing APIs
sentimentDetector = SentimentDetector()
keywordsDetector = KeyWordGenerator()
recommendationEngine = RecommendationEngine()


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


@app.route('/api/recommend', methods=['POST'])
def recommend():
    """
    Example of a Mongo history db for 2 users:

    {
        "_id" : ObjectId("5ebd5ea683eb5b356d5c467e"),
        "uname" : "alphanikhil",
        "history" : [
            "Action~5",
            "Thriller~4"
        ]
    }
    {
        "_id" : ObjectId("5ebd5eaf83eb5b356d5c467f"),
        "uname" : "sherlock",
        "history" : [
            "Action~3",
            "Fantasy~5"
        ]
    }
    """

    history_parsed = []
    u_name = ""
    if request.method == 'POST':
        u_name = request.form.get("username", "")

    for past in list(db.history.find({"uname": u_name}))[0]["history"]:
        tag, rating = past.split('~')
        history_parsed.append((tag, float(rating)))

    recommends = recommendationEngine.recommend_genres(history_parsed)
    return jsonify({
        "recommends": recommends,
    })


if __name__ == '__main__':
    app.run(debug=True)
