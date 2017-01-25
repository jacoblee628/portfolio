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
searchWeather = read.csv("search_weather.csv")

####Notes on Data
##Time in UTC, Distance in meters, Travel time in seconds

#Merge Search_ID, Mode, and Temp
search_mode_temp = sqldf("select modeChosen.Search_ID, modeChosen.Mode, searchWeather.Precip from modeChosen join searchWeather on searchWeather.Search_ID = modeChosen.Search_ID")

#Data for loop
mins = c(0, 50)
maxs = c(50, 100)
labels = c("No Rain", "Raining")
allData = c()

for (i in 1:length(mins)) {

  curQuery = "select Mode, (Count(*) * 100.0 / ((select Count(*) from search_mode_temp where Precip between %d AND %d)*1.0)) as Pcg from search_mode_temp where Precip between %d AND %d group by Mode"
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
              labs(title="Mode Chosen by Rain", x="Weather Condition", y="% of trips")

print(graph)
