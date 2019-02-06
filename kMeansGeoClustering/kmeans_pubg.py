import sys
import re
from pyspark import SparkContext, SparkConf
from fx_pubg import *
import time
start = time.time()
### K MEANS FOR X - Y COORDINATES

if __name__ == "__main__":
    if len(sys.argv) != 5:
        print >> sys.stderr, \
            "Usage: kmeans_pubg.py <k> <euclidean / greatcircle> <input path> <output path>"
        exit(-1)

    sconf = SparkConf() \
        .setAppName("KMeans Spark for X - Y Coordinate ") \
        .set("spark.ui.port", "4141")
    sc = SparkContext(conf=sconf)

    k = int(sys.argv[1])
    measure = str(sys.argv[2])
    file = str(sys.argv[3])
    outPath = str(sys.argv[4])

    # FIXME
    convergeDist = 1000
    sumDist = 2000
    maxIter = 1000
    # all points theta(n)
    # ETL: [0] = x, [1] = y
    points =  sc.textFile(file) \
    	.map(lambda line: line.split(",")) \
    	.map(lambda line: [XY(line[0], line[1]), line[2:]]) \
        .cache()

    # initialize random sample centroids
    centroids = points.map(lambda point: point[0]).takeSample(False, k)
    centroids = dict(zip(range(k), centroids))
    i=0
    closestIndex = None
    while (sumDist > convergeDist) and (i<maxIter):
    	i+=1
        # requires lat lon points
        closestIndex = points \
            .map(lambda point: \
                (closestPoint(point[0], centroids, measure), point))
        # index,point - theta(kn)

        # 3D (lat-long) sum -- theta(n)
        clusterSum = closestIndex \
            .map(lambda (index, point): (index, point[0])) \
            .reduceByKey(addPoints)
            # points are now xyz

        # calculate size of each cluster theta(n)
        clusterSize = closestIndex.countByKey() # index,size

        # theta(k)
        newCentroids = clusterSum \
            .map(lambda (index, sum): \
                (index, pointDivision(sum, clusterSize[index])))
                # points are now lat-lon

        # theta(k)
        sumDist = newCentroids \
            .map(lambda (index, newCentroid): \
                distance(newCentroid, centroids[index], measure)) \
                .sum()

        print sumDist

    	# set the means as the new centroids
        centroids = newCentroids.collectAsMap()

    print i
    avgDiameter = closestIndex \
        .map(lambda (index, point): \
            (index, distance(point[0], centroids[index], measure))) \
        .reduceByKey(max) \
        .map(lambda (index, diameter): diameter) \
        .mean()

    for index, centroid in centroids.items():
        print "Centroid #" + str(index + 1) + " at," \
            + str(centroid.x) + "," + str(centroid.y)

    print "Mean Diameter of all Clusters: " + str(avgDiameter)

    # USE THIS TO PRODUCE:
    # CENTROID LAT, CENTROID LON, POINT LAT, POINT LON, POINT DESCRIPTION
    output = closestIndex \
        .map(lambda (index, point): \
        str(centroids[index].x) + "," + str(centroids[index].y) \
            + "," + str(point[0].x) + "," + str(point[0].y) \
            + ",".join(s.encode("utf-8", "ignore") for s in point[1])) \
        .saveAsTextFile(outPath)

    # USE THIS TO PRODUCE:
    # CENTROID INDEX, POINT LAT, POINT LON, POINT DESCRIPTION
    #output = closestIndex \
    #    .map(lambda (index, point): \
    #    str(index) + "," + str(point[0].lat) + "," + str(point[0].lon) \
    #    + ",".join(s.encode("utf-8", "ignore") for s in point[1])) \
    #    .saveAsTextFile(outPath)

    print "fin."

end = time.time()
print end - start
