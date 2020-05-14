import pandas as pd
import numpy as np


class Recommender_engine:

    def __init__(self):
        self.p_similarity = pd.read_csv('datasets/p_similarity_dataset.csv', index_col=['genres'])
        
    
    def list_available_single_genres(self):
        '''
        returns: list containing all the available genres to choose and recommend from, 
                 the recommendation can be combination of these too.
        '''

        single_genres = list([genres for genres in self.p_similarity.columns if len(genres.split('|')) < 2])
        return single_genres
    

    def _get_similar_genre(self, genre_name, user_rating):
        score = self.p_similarity[genre_name] * (user_rating - 2.5)
        score = score.sort_values(ascending = False)
        return score
    

    def recommend_genres(self, user_info):
        '''
        takes input as a list of tuples where in each tuple -
        index 0 - contains a genre (string(only fromt the genres those are available))
        index 1 - contains a rating (range - 0.0 - 5.0 (float))

        returns: a list containing the similar genres calculated with similarity in descending order.
        '''

        similar_genre = pd.DataFrame()

        for genre, rating in user_info:
            similar_genre = similar_genre.append(self._get_similar_genre(genre, rating), ignore_index=True)
        
        recommendations = similar_genre.sum().sort_values(ascending = False)

        calculated_genres = []
        for genre, score in recommendations.items():
            calculated_genres.append(genre)
        
        return calculated_genres

