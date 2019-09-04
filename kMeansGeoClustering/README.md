## Cloud Computing Final Project - k Means Clustering
For this project, we analyzed the relationship between player position and probability of death in the video game *Player Unknown's Battlegrounds*.

Language: Python, Spark, MATLAB\
Course: CSE 427S Cloud Computing with Big Data Applications\
Team Members:\
Jacob Lee (Project Manager)\
Frank Moon (Developer Local)\
David Yang (Developer Cloud)\
Nigel Kim (Key User)\


# Methodology
We first transformed and loaded [this dataset from Kaggle.com](https://www.kaggle.com/skihikingkevin/pubg-match-deaths) onto Amazon Web Services servers. The dataset has 64 million rows and 12 columns. We ingested the data using Spark and Flume.

We then implemented and ran the k-means clustering algorithm in Spark. We were pleased to find the map could be divided into several different regions. We then visualized the data using MATLAB.

