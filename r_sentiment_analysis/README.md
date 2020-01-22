# Ford Review Sentiment Analysis Project

## Conclusion
Given only the text of several hundred actual reviews, we were able to predict with **~69% accuracy** if they were **positive or negative reviews**.

## Introduction
The ability to quickly categorize thousands of reviews is important to every review site. It is a surprisingly difficult challenge, especially due to things like sarcasm, euphemisms, slang, and figures of speech.

**Humans are around 70% accurate**, but labor is expensive and takes a long time. Our model was just as good as humans, and only uses a fraction of the time.

We cleaned the text data, visualized it (in a word cloud, image file above), classified each word in every review (using a dictionary in the syuzhet package) and created 4 different models, explained below.

### Model 1: Simple Difference
This model takes the **difference** (quite simply) between the share of positive and negative words. If the resulting number meets a threshold (determined by a decision tree that we generated), it is classified as either positive or negative.

An image of the decision tree is attached above as well.

The resulting confusion matrix (for test data) was as such:

`````````````````````````
          Reference
Prediction   0   1
         0 126  36
         1 220 310
                                          
    Accuracy : 0.6301          
    95% CI : (0.5929, 0.6661)
    No Information Rate : 0.5             
    P-Value [Acc > NIR] : 3.888e-12
``````````````````````````
    
## Model 2: Logistic Regression w/ Share of Neg/Pos Words as Predictors
This model takes the ratio of negative to positive words (share negative, share positive) as independent variables, and if the predicted ratio passes a threshold (0.5, in our case), then it is positive.

Here is the confusion matrix:   
``````````````````````````
          Reference
Prediction   0   1
         0 239 110
         1 107 236
                
    Accuracy : 0.6864          
    95% CI : (0.6504, 0.7208)
    No Information Rate : 0.5             
    P-Value [Acc > NIR] : <2e-16 
``````````````````````````      
Not bad at all. Better than the simple difference model, but we also tried other approaches.

## Model 3: Logistic Regression w/ Specific Words as Predictors
This model takes the count of certain words and uses them as predictors for polarity. This is where the word cloud comes in handy; we chose common and meaningful words for our list. After running the regression, we removed insignificant words from the list.

You can find our list of words in the code.
``````````````````````````  
          Reference
Prediction   0   1
         0 204 102
         1 142 244
                                         
    Accuracy : 0.6474         
    95% CI : (0.6105, 0.683)
    No Information Rate : 0.5            
    P-Value [Acc > NIR] : 3.83e-15    
``````````````````````````      
A bit worse than our previous model, but that's to be expected. The model is riskier, as the English language is huge. The word cloud helps pin down good candidates for words, but we can't expect it to be perfect. Still, it performs better than random chance (0.5 success rate)

## Model 4: Logistic Regression w/ Emotions Behind Words as Predictors
We used a package to classify words into a various, and used the frequency of the emotion occurring as predictors.

The emotions include anger, anticipation, disgust, fear, joy, sadness, surprise, and trust.

Confusion matrix:
``````````````````````````  
          Reference
Prediction   0   1
         0 211  91
         1 135 255
                                          
    Accuracy : 0.6734          
    95% CI : (0.6371, 0.7083)
    No Information Rate : 0.5             
    P-Value [Acc > NIR] : < 2.2e-16       
``````````````````````````                                            
## Conclusion
Our second model was the best. If words are generally more negative in a review, the review is more likely to be negative. The other models are either too simple or take too many risks.

[Research](http://www.mecs-press.org/ijeme/ijeme-v7-n1/v7n1-3.html) has shown that humans are around 70% accurate in classifying online reviews, so these models are around as good as a human, in a fraction of the time.
