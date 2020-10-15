# Setup

library(tidyverse)
library(tm)
library(parallel)
library(slam)

source("helper_functions_objects.R")

memory.limit(size = 10000)

## parallel computing setup for cleaning
numCores <- detectCores()
cl <- makeCluster(numCores)
clusterExport(cl, c(
  "tm_map", "removeWords",
  "remove_special", "removeNumbers",
  "removePunctuation", "stripWhitespace",
  "stemDocument", "stri_trans_tolower"
))
tm_parLapply_engine(cl)

## cleaning

jstor_corpus <- readRDS("./corpus_files/jstor_corpus.rds")

jstor_corpus <- tm_map(jstor_corpus, content_transformer(stri_trans_tolower))
jstor_corpus <- tm_map(jstor_corpus, removeWords, stopwords_new)
jstor_corpus <- tm_map(jstor_corpus, content_transformer(latex_html_remove))
jstor_corpus <- tm_map(jstor_corpus, removePunctuation)
jstor_corpus <- tm_map(jstor_corpus, removeNumbers)
jstor_corpus <- tm_map(jstor_corpus, remove_special, "[^a-zA-Z0-9]")
jstor_corpus <- tm_map(jstor_corpus, remove_special, "\\b\\w{1,1}\\s")
jstor_corpus <- tm_map(jstor_corpus, remove_special, "[^[:alnum:]]")
jstor_corpus <- tm_map(jstor_corpus, remove_special, "[\r\n]")
jstor_corpus <- tm_map(jstor_corpus, stripWhitespace)

stopCluster(cl)

jstor_corpus %>%
  saveRDS(., "./corpus_files/jstor_corpus_cleaned.rds")

# Remove unfrequent and meaningless terms before stemming
## Creating DocumentTermMatrix with parallel

cl <- makeCluster(numCores)
clusterExport(cl, c("DocumentTermMatrix", "findFreqTerms"))
tm_parLapply_engine(cl)

dtm <- DocumentTermMatrix(jstor_corpus)
unfreqterms <- findFreqTerms(dtm, 0, 5)
stopCluster(cl)

unfreqterms <- unfreqterms[which(unfreqterms %notin% vocab)]


cl <- makeCluster(numCores)
clusterExport(cl, c(
  "tm_map", "word_tokenizer",
  "stri_replace_all_fixed",
  "%notin%", "vocab",
  "unfreq_term_remover", "unfreqterms",
  "stripWhitespace", "stemDocument"
))
tm_parLapply_engine(cl)

jstor_corpus <- tm_map(jstor_corpus, content_transformer(unfreq_term_remover), unfreqterms)
jstor_corpus <- tm_map(jstor_corpus, stripWhitespace)
jstor_corpus <- tm_map(jstor_corpus, stemDocument)

stopCluster(cl)

jstor_corpus %>%
  saveRDS(., "./corpus_files/jstor_corpus_stem.rds") # stemmed Vcorpus

writeLines(as.character(jstor_corpus), con = "./corpus_files/jstor_corpus_stem.txt") # for GloVe
