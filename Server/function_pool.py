import re
import sys

import nltk
import pickle
from numpy import array, argmax
from nltk.corpus import stopwords
from nltk.stem.wordnet import WordNetLemmatizer
from tensorflow.python.keras.models import load_model


# RUN below 2 lines for New Systems
# nltk.download("stopwords")
# nltk.download("wordnet")


class KeyWordGenerator:
    def __init__(self):
        sys.stderr.write("Keyword API loading...")
        sys.stderr.flush()
        self.stop_words = set(stopwords.words("english"))

        self.tfidf_transformer = pickle.load(open("models/tfidfTransformer.pickle", 'rb'))
        self.cv = pickle.load(open("models/countVectorizer.pickle", 'rb'))
        sys.stderr.write("Complete!\n")
        sys.stderr.flush()

    @staticmethod
    def sort_coo(coo_matrix_):
        tuples = zip(coo_matrix_.col, coo_matrix_.data)
        return sorted(tuples, key=lambda x: (x[1], x[0]), reverse=True)

    @staticmethod
    def extract_top_n_from_vector(feature_names_, sorted_items_, top_n):
        """get the feature names and tf-idf score of top n items"""

        # use only top n items from vector
        sorted_items_ = sorted_items_[:top_n]

        score_vals = []
        feature_vals = []

        # word index and corresponding tf-idf score
        for idx, score in sorted_items_:
            # keep track of feature name and its corresponding score
            score_vals.append(round(score, 3))
            feature_vals.append(feature_names_[idx])

        # create a tuples of feature,score
        # results = zip(feature_vals,score_vals)
        results = {}
        for idx in range(len(feature_vals)):
            results[feature_vals[idx]] = score_vals[idx]

        return results

    def get_keywords(self, sentence, n=7):
        text = re.sub('[^a-zA-Z]', ' ', sentence)
        # Convert to lowercase
        text = text.lower()
        # remove tags
        text = re.sub("&lt;/?.*?&gt;", " &lt;&gt; ", text)
        # removal special characters and digits
        text = re.sub("(\\d|\\W)+", " ", text)
        # Convert to list from string
        text = text.split()
        # Lemmatization
        lem = WordNetLemmatizer()

        text = [lem.lemmatize(word) for word in text if word not in self.stop_words]

        text = " ".join(list(set(text)))

        text = self.cv.transform([text])
        tf_idf_vector = self.tfidf_transformer.transform(text)
        feature_names = self.cv.get_feature_names()

        sorted_items = self.sort_coo(tf_idf_vector.tocoo())

        keywords = self.extract_top_n_from_vector(feature_names, sorted_items, top_n=n)

        # print the results

        return list(keywords.keys())


class SentimentDetector:
    def __init__(self):
        sys.stderr.write("Sentiment API loading...")
        sys.stderr.flush()
        with open("models/tokenizer.pickle", "rb") as handle:
            self.tokenizer = pickle.load(handle)

        self.sentimental_model = load_model("models/sentiment_analysis_model_scale_of_8.h5")
        sys.stderr.write("Complete!\n")
        sys.stderr.flush()

    def get_sentiment_data(self, sentence):
        prediction = self.sentimental_model.predict(
            self.tokenizer.texts_to_sequences(
                array([sentence])
            )
        )[0]

        return {
            "prediction": str(argmax(prediction)),
            "confidence": str(max(prediction)),
        }


if __name__ == '__main__':
    kwg = KeyWordGenerator()
    print(kwg.get_keywords("""
    The indefinite article takes two forms.
    It’s the word a when it precedes a word
    that begins with a consonant. It’s the 
    word an when it precedes a word that
    begins with a vowel. The indefinite article 
    indicates that a noun refers to a general 
    idea rather than a particular thing. 
    For example, you might ask your friend, 
    “Should I bring a gift to the party?” 
    Your friend will understand that you are 
    not asking about a specific type of gift 
    or a specific item. “I am going to bring 
    an apple pie,” your friend tells you. 
    Again, the indefinite article indicates 
    that she is not talking about a specific 
    apple pie. Your friend probably doesn’t 
    even have any pie yet. 
    The indefinite article only appears with 
    singular nouns. Consider the following 
    examples of indefinite articles used 
    in context
    """))

    sd = SentimentDetector()
    print(sd.get_sentiment_data("What an awful day"))
