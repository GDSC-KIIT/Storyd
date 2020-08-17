"""
Requirements:
    Python 3.7+
"""

import os
import time
from itertools import combinations

from google.cloud import firestore
from flask import Flask, jsonify, render_template, request, url_for, Response
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
    user_info = db.collection("user-data")
    story_collection = db.collection("story-collection")
    uid = ""

    if request.method == 'POST':
        uid = request.form.get("uid", "")

    recommends = list()

    preferred_topics = user_info.document(uid).get().to_dict()["preferredTopics"]
    print(preferred_topics)
    """for n in range(3, 0, -1):
        for tags in combinations(preferred_topics, n):
            most_recommended_posts = set(story_collection.where("topics", "array_contains", tags[0]).stream())
            
            for tag in tags[1:]:
                most_recommended_posts &= set(story_collection.where("topics", "array_contains", tag).stream())

        for story in most_recommended_posts:
            if story.id not in recommends:
                recommends.append(story.id)


    print(recommends)"""

    return jsonify({
        "recommends": recommends,
    })


if __name__ == '__main__':
    app.run(debug=True)
