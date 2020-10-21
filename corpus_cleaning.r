# Setup

library(tidyverse)
library(tm)
library(parallel)
library(stringi)
library(text2vec)
library(jprep)

jstor_corpus <- readRDS("C:/Users/soirk/Krisztian/Research/missing_data_paper/corpus_files/jstor_corpus.rds")
## cleaning

numCores <- detectCores()
cl <- makeCluster(numCores)
clusterExport(cl, c(
  "tm_map", "removeWords",
  "remove_special", "removeNumbers",
  "removePunctuation", "stripWhitespace",
  "stemDocument", "stri_trans_tolower",
  "DocumentTermMatrix", "findFreqTerms",
  "word_tokenizer", "stri_replace_all_fixed",
  "%notin%", "vocab",
  "unfreq_term_remove",
  "stripWhitespace", "stemDocument"
))
tm_parLapply_engine(cl)

jstor_corpus <- tm_map(jstor_corpus, content_transformer(stri_trans_tolower))

### need to delete references

jstor_corpus <- tm_map(jstor_corpus, removeWords, stopwords_new)
jstor_corpus <- tm_map(jstor_corpus, latex_html_remove)
jstor_corpus <- tm_map(jstor_corpus, removePunctuation)
jstor_corpus <- tm_map(jstor_corpus, removeNumbers)
jstor_corpus <- tm_map(jstor_corpus, remove_special, "[^a-zA-Z0-9]")
jstor_corpus <- tm_map(jstor_corpus, remove_special, "\\b\\w{1,1}\\s")
jstor_corpus <- tm_map(jstor_corpus, remove_special, "[^[:alnum:]]")
jstor_corpus <- tm_map(jstor_corpus, remove_special, "[\r\n]")
jstor_corpus <- tm_map(jstor_corpus, stripWhitespace)

#jstor_corpus %>% saveRDS(., "./corpus_files/jstor_corpus_cleaned.rds")

# Remove unfrequent and meaningless terms before stemming
## Creating DocumentTermMatrix with parallel

dtm <- DocumentTermMatrix(jstor_corpus)
unfreqterms <- findFreqTerms(dtm, 0, 5)

unfreqterms <- unfreqterms[which(unfreqterms %notin% vocab)]

jstor_corpus <- tm_map(jstor_corpus, content_transformer(unfreq_term_remove), unfreqterms)
jstor_corpus <- tm_map(jstor_corpus, stripWhitespace)
jstor_corpus <- tm_map(jstor_corpus, stemDocument)

stopCluster(cl)

jstor_corpus %>%
  saveRDS(., "./corpus_files/jstor_corpus_stem.rds") # stemmed Vcorpus

writeLines(as.character(jstor_corpus), con = "./corpus_files/jstor_corpus_stem.txt") # for GloVe