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

#Assign get the hour from each date

hours = c()

for (i in 1:nrow(searchExtra)) {

  curDate = as.character(searchExtra$Date_Time[i])
  hours[i] = strsplit(strsplit(curDate, " ")[[1]][2], ":")[[1]][1]

}

searchExtra$hour = hours

#Merge Search_ID, Mode, and Time
search_mode_hours = sqldf("select modeChosen.Search_ID, modeChosen.Mode, searchExtra.hour from modeChosen join searchExtra on searchExtra.Search_ID = modeChosen.Search_ID")

#Data for loop
mins = c(0, 5, 10, 14, 18, 22)
maxs = c(4, 9, 13, 17, 21, 23)
labels = c("12-5a", "5-10a", "10a-2p", "2-6p", "6-10p", "10p-12a")
allData = c()

for (i in 1:length(mins)) {
  
  curQuery = "select Mode, (Count(*) * 100.0 / ((select Count(*) from search_mode_hours where hour between %d AND %d)*1.0)) as Pcg from search_mode_hours where hour between %d AND %d group by Mode"
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
              labs(title="Mode Chosen by Hour", x="Hour", y="% of trips")

print(graph)
