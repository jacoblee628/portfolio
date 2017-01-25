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

#Assign Mode Type to searchOps
search_ops_with_mode_type = sqldf("select *, case WHEN Mode LIKE '%uber%' OR Mode = 'assist' THEN 'uber' WHEN Mode = 'walking' THEN 'walking' WHEN Mode = 'biking' THEN 'biking' WHEN Mode LIKE 'scoot%' THEN 'scoot' ELSE 'transit' END as ModeType from searchOps")

#Get min times for each mode type
search_mode_times = sqldf("select search_id, ModeType, MIN(Time) as MinTime from search_ops_with_mode_type group by search_id, ModeType")

#Add columns to mode chosen
genQuery = "select uber_vs_transit_time.*, MinTime as '%s' from uber_vs_transit_time join search_mode_times on search_mode_times.search_id = uber_vs_transit_time.search_id where ModeType = '%s'"
uber_vs_transit_time = sqldf("select * from modeChosen where Mode = 'rideshare' or Mode = 'transit'")
uber_vs_transit_time = sqldf(sprintf(genQuery, "uberTime", "uber"))
uber_vs_transit_time = sqldf(sprintf(genQuery, "transitTime", "transit"))
uber_vs_transit_time$dif = (uber_vs_transit_time$transitTime - uber_vs_transit_time$uberTime)/60.0

#Data for loop
mins = c(-10, 0, 5, 10, 15)
maxs = c(0, 5, 10, 15, 250)
labels = c("-10-0", "0-5", "5-10", "10-15", "15-250")
allData = c()

for (i in 1:length(mins)) {

  curQuery = "select Mode, (Count(*) * 100.0 / ((select Count(*) from uber_vs_transit_time where dif between %d AND %d)*1.0)) as Pcg from uber_vs_transit_time where dif between %d AND %d group by Mode"
  curDF = sqldf(sprintf(curQuery, mins[i], maxs[i], mins[i], maxs[i]))

  #Add range column
  curDF = cbind(curDF, range=labels[i])

  if (i == 1) { #first go around
    allData = curDF
  } else {
    allData = rbind(allData, curDF)
  }

}

time_vs_mode = ggplot(allData, aes(x = range, y = Pcg, fill = Mode)) +
              geom_bar(position = "fill",stat = "identity") +
              scale_y_continuous(labels = percent_format()) +
              labs(title="Mode Chosen by Time Dif Uber v Transit", x="Time (mins)", y="% of trips")

print(time_vs_mode)