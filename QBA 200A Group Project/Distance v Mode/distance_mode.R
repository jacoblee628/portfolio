#Activate libraries
library(sqldf)
library(ggplot2)
library(scales)

#Set working directory
setwd("~/Dropbox/School/QBA 200A/Group Project/Data Given")

#Import Data
modeChosen = read.csv("mode_chosen.csv")
searchExtra = read.csv("search_extra_info.csv")
searchOps = read.csv("search_options.csv")

####Notes on Data
##Time in UTC, Distance in meters, Travel time in seconds

####Distance vs Mode Choice

#Get avg distance for each search
avg_distance_for_searches = sqldf("select Search_ID, AVG(Distance) as Distance from searchOps where Distance != -1 group by Search_ID")

#Merge Search_ID, Mode, and Distance
search_mode_distance = sqldf("select modeChosen.Search_ID, modeChosen.Mode, avg_distance_for_searches.Distance from modeChosen join avg_distance_for_searches on avg_distance_for_searches.Search_ID = modeChosen.Search_ID")

#Get avg distance for each mode type
avg_distance_per_mode = sqldf("select Mode, AVG(Distance) as AvgDist from search_mode_distance group by Mode")

#Data for loop
mins = c(0, 2000, 5000, 10000, 20000)
maxs = c(2000, 5000, 10000, 20000, 50000)
labels = c("0-2", "2-5", "5-10", "10-20", "20-50")
allData = c()

#Get proportion of usage for each mode type
prop_of_use_per_mode = sqldf("select Mode, (Count(*) * 100.0 / ((select Count(*) from search_mode_distance where distance between 0 AND 500)*1.0)) as Pcg from search_mode_distance where distance between 0 AND 500 group by Mode")

for (i in 1:length(mins)) {
  
  curQuery = "select Mode, (Count(*) * 100.0 / ((select Count(*) from search_mode_distance where distance between %d AND %d)*1.0)) as Pcg from search_mode_distance where distance between %d AND %d group by Mode"
  curDF = sqldf(sprintf(curQuery, mins[i], maxs[i], mins[i], maxs[i]))
  
  #Add range column
  curDF = cbind(curDF, range=labels[i])
  
  if (i == 1) { #first go around
    allData = curDF
  } else {
    allData = rbind(allData, curDF)
  }
  
}

dist_vs_mode = ggplot(allData, aes(x = range, y = Pcg, fill = Mode)) +
              geom_bar(position = "fill",stat = "identity") +
              scale_y_continuous(labels = percent_format()) + 
              labs(title="Mode Chosen by Distance", x="Distance (km)", y="% of trips")

print(dist_vs_mode)
