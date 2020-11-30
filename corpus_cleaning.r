# Setup

library(tidyverse)
library(tm)
library(parallel)
library(stringi)
library(text2vec)
library(jprep)

jstor_corpus <- readRDS("/media/bilibraker/Maxtor/Krisz/Krisztian/Research/missing_data_paper/jstor_corpus.rds")
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
jstor_corpus <- tm_map(jstor_corpus, removeWords, stopwords_new)
jstor_corpus <- tm_map(jstor_corpus, latex_html_remove)
jstor_corpus <- tm_map(jstor_corpus, removePunctuation)
jstor_corpus <- tm_map(jstor_corpus, removeNumbers)
jstor_corpus <- tm_map(jstor_corpus, remove_special, "[^a-zA-Z0-9]")
jstor_corpus <- tm_map(jstor_corpus, remove_special, "\\b\\w{1,1}\\s")
jstor_corpus <- tm_map(jstor_corpus, remove_special, "[^[:alnum:]]")
jstor_corpus <- tm_map(jstor_corpus, remove_special, "[\r\n]")
jstor_corpus <- tm_map(jstor_corpus, stripWhitespace)

#jstor_corpus %>% saveRDS(., "/media/bilibraker/Maxtor/Krisz/Krisztian/Research/missing_data_paper/corpus_files/jstor_corpus_cleaned_23_11.rds")
#jstor_corpus <- readRDS("/media/bilibraker/Maxtor/Krisz/Krisztian/Research/missing_data_paper/corpus_files/jstor_corpus_cleaned_23_11.rds")

# Remove unfrequent and meaningless terms before stemming
## Creating DocumentTermMatrix with parallel

dtm <- DocumentTermMatrix(jstor_corpus)
unfreqterms <- findFreqTerms(dtm, 0, 5)

unfreqterms <- unfreqterms[which(unfreqterms %notin% vocab)]

jstor_corpus <- tm_map(jstor_corpus, content_transformer(unfreq_term_remove), unfreqterms)
jstor_corpus <- tm_map(jstor_corpus, stripWhitespace)
jstor_corpus <- tm_map(jstor_corpus, stemDocument)

stopCluster(cl)

jstor_corpus %>% saveRDS(., "/media/bilibraker/Maxtor/Krisz/Krisztian/Research/missing_data_paper/corpus_files/jstor_corpus_stem_23_11.rds") # stemmed Vcorpus
jstor_corpus <- readRDS("/media/bilibraker/Maxtor/Krisz/Krisztian/Research/missing_data_paper/corpus_files/jstor_corpus_stem_23_11.rds")
#### modification starts here


tokencunt <- function (text){

  text <- as.numeric(
    quanteda::ntoken(
      as.character(
        text
      )
    )
  )

  return(text)

}


tokens <- pbapply::pbsapply(jstor_corpus, tokencunt, cl = cl)
tokens <- as.numeric(tokens[1,])

stopCluster(cl)


jstor_df <- tidy(jstor_corpus) %>%
  relocate(id) %>%
  select(id, text)


# experimental plots
cut <- 2e04

jstor_df %>%
  filter(tokens < cut) %>%
  ggplot(aes(x = tokens)) +
    geom_histogram(bins = 30, color = "black", fill = "blue", alpha = .5) +
    ggtitle(paste0(length(which(tokens < cut)),
                         " cases included",
                         "; ",
                         length(tokens) - length(which(tokens < cut)),
                         " cases excluded; ",
                         "cut value: ",
                         cut,
                         " tokens")
          )+
    theme_bw()


jstor_df %>%
  ggplot(aes(x = tokens)) +
    geom_histogram(bins = 30, color = "black", fill = "blue", alpha = .5) +
    geom_vline(xintercept = cut,  color = "red") +
    theme_bw()



jstor_df <- cbind(jstor_df, tokens) %>%
  filter(tokens < cut)


jstor_df %>% saveRDS(., "/media/bilibraker/Maxtor/Krisz/Krisztian/Research/missing_data_paper/corpus_files/jstor_df_stem_trim_30_11.rds")
#### modification ends here

#writeLines(as.character(jstor_corpus), con = "./corpus_files/jstor_corpus_stem.txt") # for GloVe