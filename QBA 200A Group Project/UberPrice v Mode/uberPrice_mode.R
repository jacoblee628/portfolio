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

####Travel times vs Mode Choice
## At a basic level, we can ask if people tend to pick options that take more/less time
## We can also segment times and see what the most popular options are for different time segments
## We can also do something with the difference in time between walking, uber, and transit

#Get min times for each mode type
search_mode_uberx = sqldf("select modeChosen.search_id, modeChosen.Mode, searchOps.Price from modeChosen join searchOps on searchOps.search_id = modeChosen.search_id where searchOps.Mode = 'uberx'")

#Data for loop
mins = c(0, 5, 10, 15, 20, 25)
maxs = c(5, 10, 15, 20, 25, 200)
labels = c("0-5", "5-10", "10-15", "15-20", "20-25", "25+")
allData = c()

for (i in 1:length(mins)) {
  
  curQuery = "select Mode, (Count(*) * 100.0 / ((select Count(*) from search_mode_uberx where Price between %d AND %d)*1.0)) as Pcg from search_mode_uberx where Price between %d AND %d group by Mode"
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
  labs(title="Mode Chosen by Uber Price", x="Price ($)", y="% of trips")

print(graph)