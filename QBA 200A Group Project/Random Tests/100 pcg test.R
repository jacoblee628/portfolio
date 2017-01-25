library(ggplot2)
library(plyr)
library(reshape2)
library(scales)

data = c(20, 10, 10, 20, 30,
        30, 30, 10, 10, 5,
        40, 30, 30, 30, 5,
        5, 20, 40, 20, 40,
        5, 10, 10, 20, 20)

data = matrix(data, nrow = 5, ncol = 5, byrow = TRUE, dimnames(names))

colnames(data) = c("0-1", "1-2", "2-3", "3-4", "4-5")
row.names(data) = c("Biking", "Rideshare", "Scoot", "Transit", "Walking")

print(data)

#Add an id variable for the filled regions
data = melt(data)

ggplot(data, aes(x = Var2, y = value,fill = Var1)) + 
  geom_bar(position = "fill",stat = "identity") + 
  scale_y_continuous(labels = percent_format())


