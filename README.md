# Identifying missing data handling methods with text-minig
## Abstract
Missing data is an inevitable aspect of every empirical research. Researchers developed several techniques to handle missing data to avoid information loss and biases. Over the past 50 years, these methods have become more and more efficient and also more complex. Building on previous review studies, this paper aims to analyze what kind of missing data handling methods are used among various scientific disciplines. For the analysis, we used nearly 50.000 scientific articles that were published between 1999 and 2016. JSTOR provided the data in text format. Furthermore, we utilized a text-mining approach to extract the necessary information from our corpus. Our results show that the usage of advanced missing data handling methods such as Multiple Imputation or Full Information Maximum Likelihood estimation is steadily growing in the examination period. Additionally, simpler methods, like listwise and pairwise deletion, are still in widespread use.

## How to replicate the analysis
There are two ways to replicate our findings:
1. Replicating every step from basic cleaning to modelling
2. Use the cleaned and preprocessed data for modelling (recommended)

### Preprocessing scripts
- `preprocessing.R` 
  - (output: jstor\_corpus.rds)
- `corpus_cleaning.R` 
  - (output: jstor\_df\_trim\_22\_02.rds)
- `snip_window.R` 
  - (output: jstor\_snipped.csv)

### Modelling
#### Classification
- data for classification: jstor\_df\_snipped\_TO\_USE.csv
#### __First Level__ (About missing data or not)
Annotated files for training and validation: 
- __jstor\_class\_first.csv__
- __jstor\_class\_first.txt__

Preparing training and validation files
- `fasttext_about_missing.R`
  - (outputs: jstor.train, jstor.valid)

Training classification model
- `first_level_train.py` 
  - (output: jstor_model.bin)

Evaluating model
- confusion_matrix.py

Predicting first level
- `first_level_pred.py` 
  - (output: jstor_first_output.csv)


#### __Second Level__ (Imputation or not)
Annotated files for training and validation: 
- __jstor\_class\_second.csv__
- __jstor\_class\_second.txt__

Preparing training and validation files
- `fasttext_imputation.R`
  - (outputs: jstor.train, jstor.valid)

Training classification model
- `second_level_train.py` 
  - (output: jstor_model.bin)

Evaluating model
- `confusion_matrix.py`

Predicting second level
- `second_level_pred.py` 
  - (output: jstor_second_output.csv)

#### __Third Level 1__ (Advanced imputation)
Annotated files for training and validation: 
- __jstor\_class\_third.csv__
- __jstor\_class\_third.txt__

Preparing training and validation files
- `fasttext_advanced.R`
  - (outputs: jstor.train, jstor.valid)

Training classification model
- `third_level_train.py` 
  - (output: jstor_model.bin)

Evaluating model
- `confusion_matrix.py`

Predicting third level
- `third_level_pred.py` 
  - (output: jstor_third_output.csv)

#### __Third Level 2__ (Deletion)
Annotated files for training and validation: 
- __jstor\_class\_third\_deletion.csv__
- __jstor\_class\_third\_deletion.txt__

Preparing training and validation files
- `fasttext_deletion.R`
  - (outputs: jstor.train, jstor.valid)

Training classification model
- `third_level_train.py`
  - (output: jstor_model.bin)

Evaluating model
- `confusion_matrix.py`

Predicting third level
- `third_level_pred.py` 
  - (output: jstor_third_deletion_output.csv)
#### Logistic models
- `log_models.R`
