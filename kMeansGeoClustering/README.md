# kMeansGeoClustering
Final Project on Big data application of k-means clustering to both synthetic data and real-world data.

Topic: k-means for Geolocation Clustering in Spark
Language: Python, PySpark, pandas, MATLAB\
Course: CSE 427S Cloud Computing with Big Data Applications\
Team Members:\
Jacob Lee (Project Manager)\
Frank Moon (Developer Local)\
David Yang (Developer Cloud)\
Nigel Kim (Key User)\
Instructor: Marion Neumann Ph.D.\
Institution: Washington University In St. Louis


For this project, we implemented the  k-  means clustering algorithm using Apache Spark. The  k -means clustering algorithm is an unsupervised learning algorithm that groups  n  points of data into  k  different clusters, based on a similarity measure between each datapoint and the center of the nearest cluster. It then returns the location of each cluster center and classifications for each point in the dataset. We implemented the algorithm using Spark because it is optimized for distributed computing on volumes of data too large for a single computer to store and process. This proved to be crucial, as we eventually ran the algorithm on a very large dataset from the video game PlayerUnknown’s Battlegrounds (PUBG), using a cluster on Amazon Web Services (AWS).
