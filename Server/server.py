import os
from google.cloud import firestore
from flask import Flask, jsonify, render_template, request, url_for
from function_pool import KeyWordGenerator, SentimentDetector, RecommendationEngine

app = Flask(__name__)

# Loading Cloud Firestore
os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = "config/socialmediabystory-b29cac6b2055.json"
db = firestore.Client()

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
    Example of a Firestore history db structure for 2 users:

    5ebd5ea683eb5b356d5c467e => {
        "name": "Nikhil Nayak"
        "history" : [
            "Action~5",
            "Thriller~4"
        ]
    }
    fsd32fr283eb5b3daf5c467f => {
        "uname" : "John Doe",
        "history" : [
            "Action~3",
            "Fantasy~5"
        ]
    }
    """
    user_info = db.collection("user-data")
    history_parsed = []
    uid = ""
    top_n = 10
    if request.method == 'POST':
        uid = request.form.get("uid", "")
        top_n = int(request.form.get("n", "10"))

    for past in user_info.document(uid).get().to_dict()["history"]:
        tag, rating = past.split('~')
        history_parsed.append((tag, float(rating)))

    recommends = recommendationEngine.recommend_genres(history_parsed)[:top_n]
    return jsonify({
        "recommends": recommends,
    })


if __name__ == '__main__':
    app.run(debug=True)
