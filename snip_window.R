library(tidyverse)
library(tidytext)
library(text2vec)
library(quanteda)
library(data.table)

quanteda_options(threads = 4)

jstor_df <- readRDS("/media/bilibraker/Maxtor/Krisz/Krisztian/Research/missing_data_paper/corpus_files/jstor_df_stem_trim_30_11.rds")


### quanteda
jstor_corpus <- corpus(jstor_df)
#dfm <- dfm(corpus)

text_tokens <- tokens(jstor_corpus)

text_tokens <- as.tokens(text_tokens)

dict <- dictionary(list(missing = c("miss", "missing"),
                      imputation = c("imput", "impute")))


text_tokens <- tokens_select(text_tokens, pattern = dict, selection = "keep", window = 5)

dfm <- dfm(text_tokens)

### data.table + text2vec
setDT(jstor_df)
setkey(jstor_df, id)

it <- itoken(jstor_df$text,
                   tokenizer = word_tokenizer,
                   ids = jstor_df$id,
                   progressbar = FALSE)

vocabulary <- create_vocabulary(it)

vocabulary  <- prune_vocabulary(vocabulary , term_count_min = 5L)


text_tokens <- tokens(jstor_df$text)

text_tokens <- as.tokens(text_tokens)