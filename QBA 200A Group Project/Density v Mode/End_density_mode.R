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

#Limit search extra to search_ID and Start_Density
searchExtra = sqldf("select Search_ID, End_Density as Density from searchExtra")

#Merge Search_ID, Mode, and Density
search_mode_density = sqldf("select modeChosen.Search_ID, modeChosen.Mode, searchExtra.Density from modeChosen join searchExtra on searchExtra.Search_ID = modeChosen.Search_ID")

#Data for loop
mins = c(0, 10000, 20000, 30000, 40000)
maxs = c(10000, 20000, 30000, 40000, 60000)
labels = c("0-10", "10-20", "20-30", "30-40", "40+")
allData = c()

for (i in 1:length(mins)) {

  curQuery = "select Mode, (Count(*) * 100.0 / ((select Count(*) from search_mode_density where density between %d AND %d)*1.0)) as Pcg from search_mode_density where density between %d AND %d group by Mode"
  curDF = sqldf(sprintf(curQuery, mins[i], maxs[i], mins[i], maxs[i]))

  #Add range column
  curDF = cbind(curDF, range=labels[i])

  if (i == 1) { #first go around
    allData = curDF
  } else {
    allData = rbind(allData, curDF)
  }

}

graph = ggplot(allData, aes(x = range, y = Pcg, fill = Mode)) +
              geom_bar(position = "fill",stat = "identity") +
              scale_y_continuous(labels = percent_format()) +
              labs(title="Mode Chosen by End Density", x="Density (in k)", y="% of trips")

print(graph)
