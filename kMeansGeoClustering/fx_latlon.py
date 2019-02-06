import math

# Earth
R = 6371

class latlon:
    def __init__(self, lat, lon):
        self.lat = float(lat)
        self.lon = float(lon)

class XYZ:
    def __init__(self, x, y, z):
        self.x = x
        self.y = y
        self.z = z

def gridCentroids(row, col, maxWidth, maxHeight):
    heightInterval = maxHeight / (row + 1)
    widthInterval = maxWidth / (col + 1)
    index = 0
    for i in xrange(row):
        for j in xrange(col):
            centroids[col * i + j] = Point(widthInterval * (j + 1), heightInterval * (i + 1))
    return centroids

def randomCentroids(k, maxWidth, maxHeight):
    for i in xrange(k):
        x = random.randint(1, maxWidth + 1)
        y = random.randint(1, maxHeight + 1)
        centroids[i] = Point(x, y)

def farthestCentroids(k):
    # implement... possible? yes. costly? yes.
    return

def llXYZ(p):
    x = R * math.cos(math.radians(p.lat)) * math.cos(math.radians(p.lon))
    y = R * math.cos(math.radians(p.lat)) * math.sin(math.radians(p.lon))
    z = R * math.sin(math.radians(p.lat))
    return XYZ(x, y, z)

def xyzLL(p):
    lat = math.degrees(math.asin(p.z / R))
    lon = math.degrees(math.atan2(p.y, p.x))
    return latlon(lat, lon)

def closestPoint(point, centroids, measure):
    # given the point's long lat and array of centroids
    # return array index of closest centroid to point
    distances = []
    for centroid in centroids.values():
        distances.append(distance(point, centroid, measure))

    minIndex = 0;
    for index, nextDistance in enumerate(distances):
        if distances[minIndex] > nextDistance:
            minIndex = index

    return minIndex

def addPoints(p1, p2):
    # takes XYZ returns XYZ
    return XYZ(p1.x + p2.x, p1.y + p2.y, p1.z + p2.z)

def pointDivision(p, num):
    # takes XYZ and num returns latlon
    xyz = XYZ(p.x / num, p.y / num, p.z / num)
    return xyzLL(xyz)

def distance(p1, p2, measure):
    if (measure == "euclidean"):
        return EuclideanDistance(p1, p2)
    if (measure == "greatcircle"):
        return GreatCircleDistance(p1, p2)

def EuclideanDistance(p1, p2):
    xyz1 = llXYZ(p1)
    xyz2 = llXYZ(p2)
    return math.sqrt( (xyz1.x - xyz2.x)**2 + (xyz1.y - xyz2.y)**2 + (xyz1.z - xyz2.z)**2 )

def GreatCircleDistance(p1, p2):
    x1 = math.radians(p1.lat)
    y1 = math.radians(p1.lon)
    x2 = math.radians(p2.lat)
    y2 = math.radians(p2.lon)
    delx = abs(x1 - x2)
    dely = abs(y1 - y2)

    centralAngle = 2 * math.asin( math.sqrt(math.sin(delx / 2)**2 + math.cos(x1) * math.cos(x2) * math.sin(dely / 2)**2) )
    distance = R * centralAngle
    return distance
