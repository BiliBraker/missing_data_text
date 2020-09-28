# Setup

library(tidyverse)
library(stringi)
library(tm)
library(parallel)
library(slam)

setwd('c:/Users/soirk/Krisztian/Research/missing_data_paper/')
memory.limit(size=10000)

stopwords_new = stopwords()[c(-42,-121,-167)] # stoprwords excluding 'were', 'at', and 'not'



# Functions

## for cleaning latex and html markup
latex_html_remove = function(x){
  clean_x = x %>% gsub("<tex-math.*?</tex-math>", "", .)  %>%
    gsub("<.*?>", "", .)  %>%
    stri_replace_all_regex(., "\n", " ")
  return(clean_x)
}

`%notin%` = Negate(`%in%`)

remove_special = content_transformer(function(x, pattern) {return (gsub(pattern, " ", x))})

## parallel computing setup
numCores = detectCores()
cl = makeCluster(numCores)
clusterExport(cl,c('tm_map','removeWords',
                   'remove_special','removeNumbers',
                   'removePunctuation','stripWhitespace',
                   'stemDocument','stri_trans_tolower'))
tm_parLapply_engine(cl)

## cleaning

jstor_corpus = readRDS('./corpus_files/jstor_corpus.rds')

jstor_corpus = tm_map(jstor_corpus, content_transformer(stri_trans_tolower))
jstor_corpus = tm_map(jstor_corpus, removeWords, stopwords_new)
jstor_corpus = tm_map(jstor_corpus, content_transformer(latex_html_remove))
jstor_corpus = tm_map(jstor_corpus, removePunctuation)
jstor_corpus = tm_map(jstor_corpus, removeNumbers)
jstor_corpus = tm_map(jstor_corpus, remove_special, '[^a-zA-Z0-9]')
jstor_corpus = tm_map(jstor_corpus, remove_special, '\\b\\w{1,1}\\s')
jstor_corpus = tm_map(jstor_corpus, remove_special, '[^[:alnum:]]')
jstor_corpus = tm_map(jstor_corpus, remove_special, '[\r\n]')
jstor_corpus = tm_map(jstor_corpus, stripWhitespace)
jstor_corpus = tm_map(jstor_corpus, stemDocument)

stopCluster(cl)

jstor_corpus %>% 
  saveRDS(., './corpus_files/jstor_corpus_cleaned.rds')

## Remove unfrequent terms


