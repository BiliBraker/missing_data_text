# Identifying missing data handling methods with text-minig
__abstract__

## How to replicate the findings

### Preprocessing scripts
- preprocessing.R (output: jstor\_corpus.rds)
- corpus_cleaning.R (output: jstor\_df\_trim\_22\_02.rds)
- snip_window.R (output: jstor\_snipped.csv)

### Modelling
#### Classification
#### __First Level__
annotated file for training: __jstor\_class\_first.csv__

preparing training file
- fasttext\_about_missing.R (output: jstor\_fasttext.txt)
- fasttext_about_missing.sh (output: jstor\_fasttext\_prep.txt)

training classification model
- first\_level\_train.py

evaluating model
- confusion\_matrix.py

predicting first level
- first\_level\_pred.py


#### Logistic models
- log\_models.R
