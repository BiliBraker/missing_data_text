# Identifying missing data handling methods with text-minig
Missing data is an inevitable aspect of every empirical research. Researchers developed several techniques to handle missing data to avoid information loss and biases. Over the past 50 years, these methods have become more and more efficient and also more complex. Building on previous review studies, this paper aims to analyze what kind of missing data handling methods are used among various scientific disciplines. For the analysis, we used nearly 50.000 scientific articles that were published between 1999 and 2016. JSTOR provided the data in text format. Furthermore, we utilized a text-mining approach to extract the necessary information from our corpus. Our results show that the usage of advanced missing data handling methods such as Multiple Imputation or Full Information Maximum Likelihood estimation is steadily growing in the examination period. Additionally, simpler methods, like listwise and pairwise deletion, are still in widespread use.

## How to replicate the analysis

### Preprocessing scripts
- preprocessing.R (output: jstor\_corpus.rds)
- corpus_cleaning.R (output: jstor\_df\_trim\_22\_02.rds)
- snip_window.R (output: jstor\_snipped.csv)

### Modelling
#### Classification
- data: jstor\_df\_snipped\_TO\_USE.csv
#### __First Level__
annotated files for training and validation: 
- __jstor\_class\_first.csv__
- __jstor\_class\_first.txt__

preparing training and validation files
- fasttext_about\_missing (outputs: jstor.train, jstor.valid)

training classification model
- first\_level\_train.py (output: jstor_model.bin)

evaluating model
- confusion\_matrix.py

predicting first level
- first\_level\_pred.py (output: jstor_first_output.csv)


#### __Second Level__
annotated files for training and validation: 
- __jstor\_class\_second.csv__
- __jstor\_class\_second.txt__

preparing training and validation files
- fasttext_imputation (outputs: jstor.train, jstor.valid)

training classification model
- second\_level\_train.py (output: jstor_model.bin)

evaluating model
- confusion\_matrix.py

predicting second level
- second\_level\_pred.py (output: jstor_second_output.csv)

#### __Third Level 1 (advanced imputation)__
annotated files for training and validation: 
- __jstor\_class\_third.csv__
- __jstor\_class\_third.txt__

preparing training and validation files
- fasttext_advanced (outputs: jstor.train, jstor.valid)

training classification model
- third\_level\_train.py (output: jstor_model.bin)

evaluating model
- confusion\_matrix.py

predicting third level
- third\_level\_pred.py (output: jstor_third_output.csv)

#### __Third Level 2 (deletion)__
annotated files for training and validation: 
- __jstor\_class\_third\_deletion.csv__
- __jstor\_class\_third\_deletion.txt__

preparing training and validation files
- fasttext_deletion (outputs: jstor.train, jstor.valid)

training classification model
- third\_level\_train.py (output: jstor_model.bin)

evaluating model
- confusion\_matrix.py

predicting third level
- third\_level\_pred.py (output: jstor_third_deletion_output.csv)
#### Logistic models
- log\_models.R
