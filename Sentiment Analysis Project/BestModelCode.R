rm(list=ls())

# --------------------------------------------------------------
# Loading in the csv files
# --------------------------------------------------------------

setwd("~/Desktop/Work/2016-2017")
A5_Ford_test=read.csv("A5_Ford_test.csv")
A5_Ford_train=read.csv("A5_Ford_train.csv")

# --------------------------------------------------------------
# Install and load all packages we will need for analysis
# --------------------------------------------------------------

#installing packages
install.packages("tm")
install.packages("stringr")
install.packages("wordcloud")
install.packages("syuzhet")
install.packages("caret")
install.packages("rpart")
install.packages("rpart.plot")
install.packages("e1071")
install.packages("quantreg")

#loading packages
library("tm") 
library("stringr") 
library("wordcloud")
library("syuzhet")
library("quantreg")
library("caret")
library("rpart") 
library("rpart.plot")
library("e1071") 

# ----------------------------------------------------------------
# Define here all the user-defined functions we'll need later
# ----------------------------------------------------------------

# function for cleaning a corpus of text (delete uninformative words/whitespace) 
clean.corpus.fun = function(text.corpus){
  
  # Removing white space, converting to upper case, removing numbers, and removing punctuation
  text.corpus = tm_map(text.corpus, stripWhitespace) # strip whitespace from the documents in the collection
  text.corpus = tm_map(text.corpus,
                       content_transformer(function(x) iconv(x, "latin1", "ASCII",sub="")))
  text.corpus = tm_map(text.corpus, content_transformer(tolower)) # convert uppercase to lowercase in the document collection
  text.corpus = tm_map(text.corpus, removeNumbers) # remove numbers from the document collection
  text.corpus = tm_map(text.corpus, removePunctuation) # remove punctuation from the document collection
  
  # Removing stop words
  text.corpus = tm_map(text.corpus, removeWords, stopwords("english")) # using a standard list, remove English stopwords from the document collection
  more.stop.words = c("cant","didnt","doesnt","dont","goes","isnt","hes",
                      "shes","thats","theres","theyre","wont","youll","youre","youve") 
  text.corpus = tm_map(text.corpus, removeWords, more.stop.words)
  
  # Removing proper nouns
  some.proper.nouns.to.remove = c("dick","ginger","hollywood","jack","jill","john","karloff",
                                  "kudrow","orson","peter","tcm","tom","toni","welles","william","wolheim")
  
  text.corpus = tm_map(text.corpus, removeWords, some.proper.nouns.to.remove)
  return(text.corpus)
}

# A user-defined function for counting the number of words from a specified set-define our own words (set_of_words) by document in a text corpus. 
# Clean the corpus before feeding it to the function
scoring.fun = function (set_of_words,clean.text.corpus){
  df.result=as.data.frame(matrix(0,length(clean.text.corpus),length(set_of_words)))
  colnames(df.result) = set_of_words
  rownames(df.result) = names(clean.text.corpus)
  for (r in 1:length(clean.text.corpus)) {
    for (w in set_of_words) {
      df.result[r,w] = sum(termFreq(clean.text.corpus[[r]], 
                                    control = list(dictionary = w)))
    }
  }
  return(df.result)
}

predict.fun = function (value, parameter){
  if (value >= parameter) return (1)
  if (value < parameter) return (0)
}

# -------------------------------------------------------
# Clean the Ford data
# -------------------------------------------------------

Ford.train.corpus = Corpus(DataframeSource(A5_Ford_train["text"]))
Ford.test.corpus = Corpus(DataframeSource(A5_Ford_test["text"]))

# Creating a dataframe with the cleaned data
Ford.test.clean.corpus = clean.corpus.fun(Ford.test.corpus)
Ford.test.clean.df = data.frame(text = sapply(Ford.test.clean.corpus, as.character), stringsAsFactors = FALSE)

Ford.train.clean.corpus = clean.corpus.fun(Ford.train.corpus)
Ford.train.clean.df = data.frame(text = sapply(Ford.train.clean.corpus, as.character), stringsAsFactors = FALSE)

# Creating a wordcloud of the 100 most used words
wordcloud(Ford.train.clean.corpus, max.words = 100)

# Count number of words associated with different emotions and number of positive/negative words (PNE)
# and attach information about how the review was classified (1 = positive/0 = negative) by a human-being, i.e. actual polarity
Ford.test.PNE = get_nrc_sentiment(Ford.test.clean.df$text)
Ford.test.PNE$class = (A5_Ford_test[,1] == "Pos")*1
head(Ford.test.PNE)

Ford.train.PNE = get_nrc_sentiment(Ford.train.clean.df$text)
Ford.train.PNE$class = (A5_Ford_train[,1] == "Pos")*1
head(Ford.train.PNE)

# --------------------------------
# Simple Difference Model
# --------------------------------

# Compute number of words (NW) in each review
Ford.train.PNE$AllWords = str_count(Ford.train.clean.df$text, "\\S+") 
Ford.test.PNE$AllWords = str_count(Ford.test.clean.df$text, "\\S+")

# Compute share of positive and negative words and add them to Ford.....PNE table that holds other results of your analysis
Ford.train.PNE$SharePos = 100*Ford.train.PNE$positive/Ford.train.PNE$AllWords
Ford.test.PNE$SharePos = 100*Ford.test.PNE$positive/Ford.test.PNE$AllWords

Ford.train.PNE$ShareNeg = 100*Ford.train.PNE$negative/Ford.train.PNE$AllWords
Ford.test.PNE$ShareNeg = 100*Ford.test.PNE$negative/Ford.test.PNE$AllWords

# Compute the difference between the share of positive and negative words
Ford.train.PNE$Simple = Ford.train.PNE$SharePos - Ford.train.PNE$ShareNeg
Ford.test.PNE$Simple = Ford.test.PNE$SharePos - Ford.test.PNE$ShareNeg

# Using regression tree to compute the value of Simple for cut-off for you model to classfify a review into a positive or a negative
Polarity.tree = rpart(class ~ Simple, data = Ford.train.PNE)
prp(Polarity.tree)

# Compute predicted polarity and confusion matrix in the TRAINING data, then creating confusion matrix
Ford.train.PNE$SimplePredictedPolarity = rep(NA,nrow(Ford.train.PNE))
for (r in 1:nrow(Ford.train.PNE)){
  Ford.train.PNE$SimplePredictedPolarity[r] = predict.fun(Ford.train.PNE$Simple[r],0.44)
}

confusionMatrix(data = Ford.train.PNE$SimplePredictedPolarity,reference = Ford.train.PNE$class, positive = "1")


# Compute predicted polarity and confusion matrix in the TESTING data, then creating confusion matrix
Ford.test.PNE$SimplePredictedPolarity = rep(NA,nrow(Ford.test.PNE))
for (r in 1:nrow(Ford.test.PNE)){
  Ford.test.PNE$SimplePredictedPolarity[r] = predict.fun(Ford.test.PNE$Simple[r],0.44)
}

confusionMatrix(data = Ford.test.PNE$SimplePredictedPolarity,reference = Ford.test.PNE$class, positive = "1")

# -----------------------------------------------------------------------------------
# Logistic Regression: Share of Positive and Negative Words as Independent Variables
# -----------------------------------------------------------------------------------

# Estimate the logistic model that links %s of positive and negative words to the actual polarity
LR.PosNegWords = glm(Ford.train.PNE$class ~ Ford.train.PNE$SharePos + Ford.train.PNE$ShareNeg,family="binomial")
summary(LR.PosNegWords)

# Computing predicted polarity in the training data 

# First, compute the "utility" values
regressors_LR.PosNegWords_train = as.matrix(cbind(1,Ford.train.PNE$SharePos,Ford.train.PNE$ShareNeg))
utility_LR.PosNegWords_train = regressors_LR.PosNegWords_train %*% as.matrix(LR.PosNegWords$coefficients)

# Second, compute predicted probabilities of a positive polarity using the logit probability formula
p1_LR.PosNegWords_train = (exp(utility_LR.PosNegWords_train)/(exp(utility_LR.PosNegWords_train) + exp(0)))

# Using predicted probabilities for polarity = 1, classify the reviews in the TRAIN data: 
# if predicted probability > 0.5, then predicted polarity = 1

Ford.train.PNE$LR.PosNegWords_PredictedPolarity = rep(NA,nrow(Ford.train.PNE))
for (r in 1:nrow(Ford.train.PNE)){
  Ford.train.PNE$LR.PosNegWords_PredictedPolarity[r] = predict.fun(p1_LR.PosNegWords_train[r],0.5)
}

confusionMatrix(data = Ford.train.PNE$LR.PosNegWords_PredictedPolarity,reference = Ford.train.PNE$class, positive = "1")

# Running logistic model to assess performance of model
LR.PosNegWords = glm(Ford.test.PNE$class ~ Ford.test.PNE$SharePos + Ford.test.PNE$ShareNeg,family="binomial")
summary(LR.PosNegWords)

# Calculating utility
regressors_LR.PosNegWords_test = as.matrix(cbind(1,Ford.test.PNE$SharePos,Ford.test.PNE$ShareNeg))
utility_LR.PosNegWords_test = regressors_LR.PosNegWords_test %*% as.matrix(LR.PosNegWords$coefficients)

# Computing predicted probabilities of a positive polarity using the logit probability formula
p1_LR.PosNegWords_test = (exp(utility_LR.PosNegWords_test)/(exp(utility_LR.PosNegWords_test) + exp(0)))

# Classifying reviews as pos or neg
# If predicted probability > 0.5, then predicted polarity = 1

Ford.test.PNE$LR.PosNegWords_PredictedPolarity = rep(NA,nrow(Ford.test.PNE))
for (r in 1:nrow(Ford.test.PNE)){
  Ford.test.PNE$LR.PosNegWords_PredictedPolarity[r] = predict.fun(p1_LR.PosNegWords_test[r],0.5)
}

confusionMatrix(data = Ford.test.PNE$LR.PosNegWords_PredictedPolarity,reference = Ford.test.PNE$class, positive = "1")

# -------------------------------------------------------
# Logistic Model: Specific Words as Independent Variables
# -------------------------------------------------------

# Creating a set of words to use as independent variables (count) to predict positive/negative
set_of_words = c("amazing","problems","great","love","comfortable","comfy",
                 "decent","reliable","safe","handy","enjoy",'satisfied','versatile','recommend','impressive','smooth',
                 "terrible","horrible","worst","disappointing","dislike","want","never")

# Counting the occurrances of those words
Ford.scores.train = scoring.fun(set_of_words,Ford.train.clean.corpus)
Ford.scores.test = scoring.fun(set_of_words,Ford.test.clean.corpus)

# Creating the model
words.model = {class ~  amazing + problems + great + love + comfortable + comfy + decent + reliable + safe + handy + enjoy + satisfied + versatile + recommend + impressive + smooth + terrible + horrible + worst + disappointing + dislike + want + never}

# Cbinding the words occurrances of the words
train_LR_Specific_Words = cbind(Ford.train.PNE,Ford.scores.train)

# Logistic regression
LR_SpecificWords = glm(words.model, data = train_LR_Specific_Words, family="binomial")
summary(LR_SpecificWords)

## BELOW IS FOR THE TRAINING DATASET

# Binding the two arrays together
regressors_LR_SpecificWords_train = as.matrix(cbind(1,Ford.scores.train))
head(regressors_LR_SpecificWords_train)

# Calculating utility
utility_LR_SpecificWords_train = regressors_LR_SpecificWords_train %*% as.matrix(LR_SpecificWords$coefficients)
head(utility_LR_SpecificWords_train)

# Making a blank column on training data set to populate with for loop
Ford.train.PNE$LR_SpecificWords_PredictedPolarity = rep(NA,nrow(Ford.train.PNE))
for (r in 1:nrow(Ford.train.PNE)){
  # If Utility of word is greater than 0,
  if (utility_LR_SpecificWords_train[r]>0)
  {
    # The predicted polarity of the specific word is 1
    Ford.train.PNE$LR_SpecificWords_PredictedPolarity[r] = 1
  }
  # If less than or equal to 0
  else if (utility_LR_SpecificWords_train[r]<=0)
  {
    # The predicted polarity is 0
    Ford.train.PNE$LR_SpecificWords_PredictedPolarity[r] = 0
  }
}
head(Ford.train.PNE)

# Creating confusion matrix
confusionMatrix(data = Ford.train.PNE$LR_SpecificWords_PredictedPolarity,reference = Ford.train.PNE$class, positive = "1")

## BELOW IS FOR THE TRAINING DATASET

# Binding the two arrays together
regressors_LR_SpecificWords_test = as.matrix(cbind(1,Ford.scores.test))

# Calculating utility
utility_LR_SpecificWords_test = regressors_LR_SpecificWords_test %*% as.matrix(LR_SpecificWords$coefficients)
head(utility_LR_SpecificWords_test)

# Making a blank column on training data set to populate with for loop
Ford.test.PNE$LR_SpecificWords_PredictedPolarity = rep(NA,nrow(Ford.test.PNE))
for (r in 1:nrow(Ford.test.PNE)){
  # if Utility of word is greater than 0,
  if (utility_LR_SpecificWords_test[r]>0)
  {
    # The predicted polarity of the specific word is 1
    Ford.test.PNE$LR_SpecificWords_PredictedPolarity[r] = 1
  }
  # If less than or equal to 0
  else if (utility_LR_SpecificWords_test[r]<=0)
  {
    # The predicted polarity is 0
    Ford.test.PNE$LR_SpecificWords_PredictedPolarity[r] = 0
  }
}
head(Ford.test.PNE)

# Creating the confusion matrix
confusionMatrix(data = Ford.test.PNE$LR_SpecificWords_PredictedPolarity,reference = Ford.test.PNE$class, positive = "1")

# ---------------------------------------------
# Emotions behind words as independent variables
# ---------------------------------------------

# Running Logit model based on emotions of words
LR.BestModel = glm(Ford.train.PNE$class ~ Ford.train.PNE$anger + Ford.train.PNE$anticipation + Ford.train.PNE$disgust
                   + Ford.train.PNE$fear + Ford.train.PNE$joy + Ford.train.PNE$sadness + Ford.train.PNE$surprise +
                     Ford.train.PNE$trust,family="binomial")
summary(LR.BestModel)

## BELOW IS FOR THE TRAINING SET

# Regressors
regressors_BestModel_train = as.matrix(cbind(1,Ford.train.PNE$anger,Ford.train.PNE$anticipation,Ford.train.PNE$disgust
                                             , Ford.train.PNE$fear,Ford.train.PNE$joy,Ford.train.PNE$sadness,Ford.train.PNE$surprise ,
                                             Ford.train.PNE$trust))

# Calculating utility
utility_BestModel_train = regressors_BestModel_train %*% as.matrix(LR.BestModel$coefficients)

# Populating predicted polarity column
Ford.train.PNE$LR.BestModel_PredictedPolarity = rep(NA,nrow(Ford.train.PNE))
for (r in 1:nrow(Ford.train.PNE))
  {
  # if Utility of word is greater than 0,
  if (utility_BestModel_train[r]>0)
  {
    #The predicted polarity of the specific word is 1
    Ford.train.PNE$LR.BestModel_PredictedPolarity[r] = 1
  }
  # If less than or equal to 0
  else if (utility_BestModel_train[r]<=0)
  {
    # The predicted polarity is 0
    Ford.train.PNE$LR.BestModel_PredictedPolarity[r] = 0
  }
}

# Confusion Matrix
confusionMatrix(data = Ford.train.PNE$LR.BestModel_PredictedPolarity,reference = Ford.train.PNE$class, positive = "1")

## BELOW IS FOR THE TEST SET

# Regressors
regressors_BestModel_test = as.matrix(cbind(1,Ford.test.PNE$anger,Ford.test.PNE$anticipation,Ford.test.PNE$disgust
                                             , Ford.test.PNE$fear,Ford.test.PNE$joy,Ford.test.PNE$sadness,Ford.test.PNE$surprise ,
                                             Ford.test.PNE$trust))

# Calculating utility
utility_BestModel_test = regressors_BestModel_test %*% as.matrix(LR.BestModel$coefficients)

# Populating predicted polarity column
Ford.test.PNE$LR.BestModel_PredictedPolarity = rep(NA,nrow(Ford.test.PNE))
for (r in 1:nrow(Ford.test.PNE))
{
  # if Utility of word is greater than 0,
  if (utility_BestModel_test[r]>0)
  {
    # The predicted polarity of the specific word is 1
    Ford.test.PNE$LR.BestModel_PredictedPolarity[r] = 1
  }
  # If less than or equal to 0
  else if (utility_BestModel_test[r]<=0)
  {
    # The predicted polarity is 0
    Ford.test.PNE$LR.BestModel_PredictedPolarity[r] = 0
  }
}

# Confusion Matrix
confusionMatrix(data = Ford.test.PNE$LR.BestModel_PredictedPolarity,reference = Ford.test.PNE$class, positive = "1")