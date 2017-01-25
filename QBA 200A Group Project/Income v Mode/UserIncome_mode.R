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

#Limit search extra to ones where we have income info
searchExtra = sqldf("select * from searchExtra where Start_Home = 1 OR End_Home = 1")
searchExtra = sqldf("select Search_ID, Case WHEN Start_Home = 1 THEN Start_Income WHEN End_Home = 1 THEN End_Income ELSE 0 END as Income from searchExtra")

#Merge Search_ID, Mode, and Income
search_mode_income = sqldf("select modeChosen.Search_ID, modeChosen.Mode, searchExtra.Income from modeChosen join searchExtra on searchExtra.Search_ID = modeChosen.Search_ID")

#Data for loop
mins = c(0, 30000, 60000, 90000, 120000)
maxs = c(30000, 60000, 90000, 120000, 500000)
labels = c("0-30", "30-60", "60-90", "90-120", "120-500")
allData = c()

for (i in 1:length(mins)) {

  curQuery = "select Mode, (Count(*) * 100.0 / ((select Count(*) from search_mode_income where income between %d AND %d)*1.0)) as Pcg from search_mode_income where income between %d AND %d group by Mode"
  curDF = sqldf(sprintf(curQuery, mins[i], maxs[i], mins[i], maxs[i]))

  #Add range column
  curDF = cbind(curDF, range=labels[i])

  if (i == 1) { #first go around
    allData = curDF
  } else {
    allData = rbind(allData, curDF)
  }

}

income_vs_mode = ggplot(allData, aes(x = range, y = Pcg, fill = Mode)) +
              geom_bar(position = "fill",stat = "identity") +
              scale_y_continuous(labels = percent_format()) +
              labs(title="Mode Chosen by User Income", x="Income ($K)", y="% of trips")

print(income_vs_mode)
