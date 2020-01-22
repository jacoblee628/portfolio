import math

# Erangel
MAX_WIDTH = 800000
MAX_HEIGHT = 800000

class XY:
    def __init__(self, x, y):
        self.x = float(x)
        self.y = float(y)

def gridCentroids(row, col):
    heightInterval = MAX_HEIGHT / (row + 1)
    widthInterval = MAX_WIDTH / (col + 1)
    index = 0
    centroids = []
    for i in xrange(row):
        for j in xrange(col):
            centroids.insert(col * i + j, XY(widthInterval * (j + 1), heightInterval * (i + 1)))
    return centroids

def randomCentroids(k, maxWidth, maxHeight):
    for i in xrange(k):
        x = random.randint(1, maxWidth + 1)
        y = random.randint(1, maxHeight + 1)
        centroids[i] = XY(x, y)

def farthestCentroids(k):
    # implement... possible? yes. costly? yes.
    return

def closestPoint(point, centroids, measure):
    # given the point's long lat and array of centroids
    # return array index of closest centroid to point
    distances = []
    for centroid in centroids.values():
        distances.append(distance(point, centroid, measure))

    minIndex = 0;
    for index,value in enumerate(distances):
        if distances[minIndex] > value:
            minIndex = index

    return minIndex;

def addPoints(p1, p2):
    # a new point which is the sum of the two points
    # used to compute centroid
    return XY(p1.x + p2.x, p1.y + p2.y)

def pointDivision(point, num):
    return XY(point.x/num, point.y/num)

def distance(p1, p2, measure):
    if (measure == "euclidean"):
        return EuclideanDistance(p1.x, p1.y, p2.x, p2.y)
    else:
        return -1;

def EuclideanDistance(x1, y1, x2, y2):
    # compute euclidian distance
    return math.sqrt( (x1 - x2)**2 + (y1 - y2)**2 )
