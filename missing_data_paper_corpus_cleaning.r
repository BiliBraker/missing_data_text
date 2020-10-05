# Setup

library(tidyverse)
library(stringi)
library(tm)
library(parallel)
library(slam)
library(qdapDictionaries)

memory.limit(size = 10000)

# Functions
## for cleaning latex and html markup
latex_html_remove = function(x){
  clean_x = x %>% 
    gsub("<tex-math.*?</tex-math>", "", .)  %>%
    gsub("<.*?>", "", .)  %>%
    stri_replace_all_regex(., "\n", " ")
  return(clean_x)
}

## for removing unfrequent/meaningless terms
unfreq_term_remover = function(content,freq_terms){
  word.freq = table(unlist(word_tokenizer(content)))
  word.list = names(word.freq)
  to_remove = which(word.list %in% freq_terms)
  word.remove = paste(" ", word.list[to_remove], " ", sep="")
  content.clean = stri_replace_all_fixed(content, pattern = word.remove, replacement=" ", vectorize_all = F)
    
  return(content.clean)
}

`%notin%` = Negate(`%in%`)

remove_special = content_transformer(function(x, pattern) {return (gsub(pattern, " ", x))})

## keywords
stopwords_new = stopwords()[c(-42,-121,-167)] # stopwords excluding 'were', 'at', and 'not'

keywords = read.delim('./keywords.txt')
keywords = keywords[,1] %>% 
  as.vector() %>% 
  gsub(" ","",.)

## building vocabulary to remove meaningless words
vocab = c(GradyAugmented, keywords[which(keywords %notin% GradyAugmented)])


## parallel computing setup for cleaning
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

stopCluster(cl)

jstor_corpus %>% 
  saveRDS(., './corpus_files/jstor_corpus_cleaned.rds')

# Remove unfrequent and meaningless terms before stemming
## Creating DocumentTermMatrix with parallel

cl = makeCluster(numCores)
clusterExport(cl,c('DocumentTermMatrix','findFreqTerms'))
tm_parLapply_engine(cl)

dtm = DocumentTermMatrix(jstor_corpus)
unfreqterms = findFreqTerms(dtm, 0, 5)
stopCluster(cl)

unfreqterms = unfreqterms[which(unfreqterms %notin% vocab)]


cl = makeCluster(numCores)
clusterExport(cl,c('tm_map','word_tokenizer',
                   'stri_replace_all_fixed',
                   '%notin%','vocab',
                   'unfreq_term_remover','unfreqterms',
                   'stripWhitespace','stemDocument'))
tm_parLapply_engine(cl)

jstor_corpus = tm_map(jstor_corpus, content_transformer(unfreq_term_remover), unfreqterms)
jstor_corpus = tm_map(jstor_corpus, stripWhitespace)
jstor_corpus = tm_map(jstor_corpus, stemDocument)

stopCluster(cl)

jstor_corpus %>% 
  saveRDS(., './corpus_files/jstor_corpus_stem.rds') # stemmed Vcorpus

writeLines(as.character(jstor_corpus), con ="./corpus_files/jstor_corpus_stem.txt") # for GloVe

