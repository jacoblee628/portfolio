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

#Assign day to each search
searchExtra$weekdays=weekdays(as.Date(searchExtra$Date_Time, '%m/%d/%Y'))

#Merge Search_ID, Mode, and Time
search_mode_day = sqldf("select modeChosen.Search_ID, modeChosen.Mode, searchExtra.weekdays as Day from modeChosen join searchExtra on searchExtra.Search_ID = modeChosen.Search_ID")

#Data for loop
labels = c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday")
allData = c()

for (i in 1:length(labels)) {

  curQuery = "select Mode, (Count(*) * 100.0 / ((select Count(*) from search_mode_day where day = '%s')*1.0)) as Pcg from search_mode_day where day = '%s' group by Mode"
  curDF = sqldf(sprintf(curQuery, labels[i], labels[i]))

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
              labs(title="Mode Chosen by Day", x="Day", y="% of trips")

print(graph)
