library(dplyr)
library(sqldf)
library(rpart)
library(ggplot2)

# --------------------------------------------------------------
# Setup
# --------------------------------------------------------------

setwd("~/Documents/R Projects/Kaggle/Titanic")
train = read.csv("train.csv")
test = read.csv("test.csv")
gender_submission = read.csv("gender_submission.csv")

# --------------------------------------------------------------
# Understanding dataset
# --------------------------------------------------------------
summary(train)
str(train)
head(train)
summary(test)

# Seeing which variables have the most missing values
install.packages("Amelia")
library(Amelia)
missmap(train) # turns out Age has the most missing values
missmap(test)

# --------------------------------------------------------------
# Descriptive insights
# --------------------------------------------------------------

# Overall proportion of survival to death
overallSurvival = sqldf("select Sum(Survived) as 'Survived', Sum(Survived=0) as 'Perished' from train")
overallSurvival$SurvivalRate=overallSurvival$Survived/(overallSurvival$Perished+overallSurvival$Survived)*100
overallSurvival

# Proportion of survivorship based on class
classSurvival = sqldf("select Pclass, Sum(Survived) as 'Survived', Sum(Survived=0) as 'Perished' from train group by Pclass")
classSurvival$WithinGroupSurvival = classSurvival$Survived / (classSurvival$Survived + classSurvival$Perished) * 100
classSurvival$OverallSurvival = classSurvival$Survived / sum(classSurvival$Survived) * 100
classSurvival

# Proportion of survivorship based on gender
sexSurvival = sqldf("select Sex, Sum(Survived) as 'Survived', Sum(Survived=0) as 'Perished' from train group by Sex")
sexSurvival$WithinGroupSurvival = sexSurvival$Survived / (sexSurvival$Survived + sexSurvival$Perished) * 100
sexSurvival$OverallSurvival = sexSurvival$Survived / sum(sexSurvival$Survived) * 100
sexSurvival

# Count by Age Bracket (by 10s, arbitrary decision)
ageBuckets = sqldf("select Age, Survived from train")
ageBuckets$Bucket = cut(train$Age, breaks = seq(0, 80, 10))
ageBucketsRaw = sqldf("select Bucket, sum(Survived) as 'Survived', sum(Survived=0) as 'Perished' from ageBuckets group by Bucket")
ageBucketsRaw

# Proportion of survivorship based on age buckets
ageBucketSurvival = sqldf("select Bucket, Sum(Survived) as 'Survived', sum(Survived=0) as 'Perished' from ageBuckets group by Bucket")
ageBucketSurvival$WithinGroupSurvival = ageBucketSurvival$Survived / (ageBucketSurvival$Survived+ageBucketSurvival$Perished) * 100
ageBucketSurvival$OverallSurvival = ageBucketSurvival$Survived / sum(ageBucketSurvival$Survived) * 100
ageBucketSurvival

# Proportion of survivorship based on siblings/spouses aboard
sibSurvival = sqldf("select SibSp, Sum(Survived) as 'Survived', Sum(Survived=0) as 'Perished' from train group by SibSp")
sibSurvival$WithinGroupSurvival = sibSurvival$Survived / (sibSurvival$Survived + sibSurvival$Perished) * 100
sibSurvival$OverallSurvival = sibSurvival$Survived / sum(sibSurvival$Survived) * 100
sibSurvival

# Proportion of survivorship based on parents/children aboard
ParchSurvival = sqldf("select Parch, Sum(Survived) as 'Survived', Sum(Survived=0) as 'Perished' from train group by Parch")
ParchSurvival$WithinGroupSurvival = ParchSurvival$Survived / (ParchSurvival$Survived + ParchSurvival$Perished) * 100
ParchSurvival$OverallSurvival = ParchSurvival$Survived / sum(ParchSurvival$Survived) * 100
ParchSurvival

# --------------------------------------------------------------
# Logistic Regression (Replacing NAs with averages of each column)
# Final Score: 0.76555
# --------------------------------------------------------------
# For NA entries for Age and Fare, replacing the NA with the average of each, for all rows
tempTrain=train
tempTrain$Age[is.na(train$Age)]=mean(train$Age,na.rm=T)
tempTrain$Fare[is.na(train$Fare)]=mean(train$Fare,na.rm=T)

# Running model, excluding cabin, name, ticket, and passenger id
logit=glm(Survived ~ Pclass + Sex + Age + SibSp + Parch + Fare + Embarked, family=binomial(link="logit"),data=tempTrain)
summary(logit)
anova(logit, test="Chisq")

# Replace the NA age entries in the test set as well
logitTest=test
logitTest$Age[is.na(test$Age)]=mean(test$Age,na.rm=T)
logitTest$Fare[is.na(test$Fare)]=mean(test$Fare,na.rm=T)

# Formatting logitResults to fit required Kaggle standards
logitFinal=data.frame(logitTest$PassengerId)
colnames(logitFinal)[1]="PassengerID"
logitFinal$Survived=predict(logit,newdata=logitTest,type='response')
logitFinal$Survived=ifelse(logitFinal$Survived>0.5,1,0)

# --------------------------------------------------------------
# Decision Tree
# Final Score: 0.78468
# --------------------------------------------------------------
install.packages('rattle')
install.packages('rpart.plot')
install.packages('RColorBrewer')

library(rattle)
library(rpart.plot)
library(RColorBrewer)

tree = rpart(Survived ~ Pclass + Sex + Age + SibSp + Parch + Fare + Embarked, data = train, method = "class")
rpart.plot(tree)

treeFinal=data.frame(tempTest$PassengerId)
colnames(treeFinal)[1]="PassengerID"
treeFinal$Survived=predict(tree,test,type="class")


# --------------------------------------------------------------
# Decision Tree (w/ Feature Engineering)
# Final Score: 0.79425
# --------------------------------------------------------------
# Temporarily combining datasets so actions can be performed
# symmetrically. Will split later.
featureTest=test
featureTest$Survived = NA
trainAndTest = rbind(train,featureTest)

# Pulling titles from name strings
trainAndTest$Name = as.character(trainAndTest$Name)
trainAndTest$Title = sapply(trainAndTest$Name,FUN=function(x) {strsplit(x,split='[,.]')[[1]][2]})
trainAndTest$Title=sub(' ', '', trainAndTest$Title)
trainAndTest$Title[trainAndTest$Title %in% c('Mme', 'Mlle')]='Mlle'
trainAndTest$Title[trainAndTest$Title %in% c('Capt', 'Col', 'Major', 'Sir')]='Sir'
trainAndTest$Title[trainAndTest$Title %in% c('Dona', 'Lady', 'the Countess', 'Jonkheer')] = 'Lady'
trainAndTest$Title=factor(trainAndTest$Title)

# Creating variables for family id, family size, title
trainAndTest$FamilySize = trainAndTest$SibSp + trainAndTest$Parch + 1
trainAndTest$Surname = sapply(trainAndTest$Name, FUN=function(x) {strsplit(x, split='[,.]')[[1]][1]})
trainAndTest$FamilyID = paste(as.character(trainAndTest$FamilySize), trainAndTest$Surname, sep="")
trainAndTest$FamilyID[trainAndTest$FamilySize <= 3]='Small'

table(trainAndTest$FamilyID)
famIDs=data.frame(table(trainAndTest$FamilyID))
famIDs=famIDs[famIDs$Freq <= 3,]
trainAndTest$FamilyID[trainAndTest$FamilyID %in% famIDs$Var1] = 'Small'
trainAndTest$FamilyID = factor(trainAndTest$FamilyID)

# Splitting datasets again
featureTrain=trainAndTest[1:891,]
featureTest=trainAndTest[892:1309,]

# Creating tree and exporting
featureTree=rpart(Survived ~ Pclass + Sex + Age + SibSp + Parch + Fare + Embarked + Title + FamilySize + FamilyID, data=featureTrain,method="class")
rpart.plot(featureTree)

featureFinal=data.frame(featureTest$PassengerId)
colnames(featureFinal)[1]="PassengerID"
featureFinal$Survived=predict(featureTree,featureTest,type="class")

# --------------------------------------------------------------
# Random Forest, then Ensemble Tree
# Final Score: 0.79425 (same as before), 0.79904
# --------------------------------------------------------------
install.packages('randomForest')
install.packages('party')
library(party)
library(randomForest)

# Filling NAs via tree
Agefit=rpart(Age ~ Pclass + Sex + SibSp + Parch + Fare + Embarked + Title + FamilySize, data=trainAndTest[!is.na(trainAndTest$Age),], method="anova")
trainAndTest$Age[is.na(trainAndTest$Age)]=predict(Agefit, trainAndTest[is.na(trainAndTest$Age),])

# Replacing missing values for embarked and fare with medians
trainAndTest$Embarked[c(62,830)] = "S"
trainAndTest$Embarked = factor(trainAndTest$Embarked)
trainAndTest$Fare[1044]=median(trainAndTest$Fare,na.rm = T)

featureTrain=trainAndTest[1:891,]
featureTest=trainAndTest[892:1309,]

# Set seed and run
set.seed(420)
randomTree = randomForest(as.factor(Survived) ~ Pclass + Sex + Age + SibSp + Parch + Fare +Embarked + Title + FamilySize + FamilyID, data=featureTrain,importance=TRUE,ntree=2000)

randomFinal=data.frame(featureTest$PassengerId)
colnames(randomFinal)[1]="PassengerID"
randomFinal$Survived=predict(randomTree,featureTest,type="class")

set.seed(420)
partyTree=cforest(as.factor(Survived)~Pclass + Sex + Age + SibSp + Parch + Fare + Embarked + Title + FamilySize + FamilyID, data=featureTrain,controls=cforest_unbiased(ntree=2000, mtry=3))

partyFinal=data.frame(featureTest$PassengerId)
colnames(partyFinal)[1]="PassengerID"
partyFinal$Survived=predict(partyTree, featureTest, OOB=TRUE, type = "response")

# --------------------------------------------------------------
# Logistic Regression (With Engineered Vars and Decision Tree NAs)
# Final Score: 0.76555
# --------------------------------------------------------------
# Temporarily combining datasets so actions can be performed
# symmetrically. Will split later.
featureTest=test
featureTest$Survived = NA
trainAndTest = rbind(train,featureTest)

# Pulling titles from name strings
trainAndTest$Name = as.character(trainAndTest$Name)
trainAndTest$Title = sapply(trainAndTest$Name,FUN=function(x) {strsplit(x,split='[,.]')[[1]][2]})
trainAndTest$Title=sub(' ', '', trainAndTest$Title)
trainAndTest$Title[trainAndTest$Title %in% c('Mme', 'Mlle')]='Mlle'
trainAndTest$Title[trainAndTest$Title %in% c('Capt', 'Col', 'Major', 'Sir')]='Sir'
trainAndTest$Title[trainAndTest$Title %in% c('Dona', 'Lady', 'the Countess', 'Jonkheer')] = 'Lady'
trainAndTest$Title=factor(trainAndTest$Title)

# Creating variables for family id, family size, title
trainAndTest$FamilySize = trainAndTest$SibSp + trainAndTest$Parch + 1
trainAndTest$Surname=sapply(trainAndTest$Name, FUN=function(x) {strsplit(x, split='[,.]')[[1]][1]})
trainAndTest$FamilyID=paste(as.character(trainAndTest$FamilySize), trainAndTest$Surname, sep="")
trainAndTest$FamilyID[trainAndTest$FamilySize <= 3]='Small'

table(trainAndTest$FamilyID)
famIDs=data.frame(table(trainAndTest$FamilyID))
famIDs=famIDs[famIDs$Freq <= 3,]
trainAndTest$FamilyID[trainAndTest$FamilyID %in% famIDs$Var1]='Small'
trainAndTest$FamilyID = factor(trainAndTest$FamilyID)

# Filling NAs via tree
Agefit=rpart(Age ~ Pclass + Sex + SibSp + Parch + Fare + Embarked + Title + FamilySize, data=trainAndTest[!is.na(trainAndTest$Age),], method="anova")
trainAndTest$Age[is.na(trainAndTest$Age)]=predict(Agefit, trainAndTest[is.na(trainAndTest$Age),])

# Replacing missing values for embarked and fare with medians
trainAndTest$Embarked[c(62,830)] = "S"
trainAndTest$Embarked=factor(trainAndTest$Embarked)
trainAndTest$Fare[1044]=median(trainAndTest$Fare,na.rm = T)

# Splitting datasets again
featureTrain=trainAndTest[1:891,]
featureTest=trainAndTest[892:1309,]

summary(featureTrain)

engineeredLogit=glm(Survived ~ Pclass + Sex + Age + SibSp + Parch + Fare + Embarked + FamilySize, family=binomial(link="logit"),data=featureTrain)
summary(engineeredLogit)
anova(engineeredLogit, test="Chisq")

# Formatting logitResults to fit required Kaggle standards
engineeredLogitFinal=data.frame(featureTest$PassengerId)
colnames(engineeredLogitFinal)[1]="PassengerID"
engineeredLogitFinal$Survived=predict(engineeredLogit,newdata=featureTest,type='response')
engineeredLogitFinal$Survived=ifelse(engineeredLogitFinal$Survived>0.5,1,0)


# --------------------------------------------------------------
# Finishing things up
# --------------------------------------------------------------
submit = engineeredLogitFinal #insert data frame here
write.csv(submit,file="engineeredLogitFinal.csv",row.names=FALSE)
