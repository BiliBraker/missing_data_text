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
text_tokens <- text_tokens %>% as.list()

jstor_df <- jstor_df %>% add_column(., text_tokens = NA)

for (i in seq_along(text_tokens)){

  jstor_df$text_tokens[i] <- text_tokens[i] %>% as.character()

}

jstor_df$text_tokens <- jstor_df$text_tokens %>% unlist()

jstor_df$text_tokens <- jstor_df$text_tokens %>% stringi::stri_replace_all_fixed(., pattern = "c(" , replacement = "")
jstor_df$text_tokens <- jstor_df$text_tokens %>% gsub(pattern = "[^A-Za-z0-9]", replacement = " ",x = .)
jstor_df$text_tokens <- jstor_df$text_tokens %>% stringi::stri_replace_all_fixed(., pattern = '"' , replacement = "")

#saveRDS(jstor_df, "/media/bilibraker/Maxtor/Krisz/Krisztian/Research/missing_data_paper/corpus_files/jstor_df_snipped.rds")

### data.table + text2vec
setDT(jstor_df)
setkey(jstor_df, id)

it <- itoken(jstor_df$text_tokens,
                   tokenizer = word_tokenizer,
                   ids = jstor_df$id,
                   progressbar = FALSE)

vocabulary <- create_vocabulary(it)

vocabulary  <- prune_vocabulary(vocabulary , term_count_min = 5L)