# Setup

library(tidyverse)
library(tidytext)
library(text2vec)
library(quanteda)
library(data.table)

quanteda_options(threads = 4)

jstor_df <- readRDS("/media/bilibraker/Maxtor/Krisz/Krisztian/Research/missing_data_paper/corpus_files/jstor_df_trim_22_02.rds")


## creating tokens with quanteda ##
jstor_corpus <- corpus(jstor_df)

text_tokens <- tokens(jstor_corpus)

text_tokens <- as.tokens(text_tokens)

## define dictionary for snipping contexts ##
dict <- dictionary(list(
  missing = c("miss", "missing"),
  imputation = c("imput", "impute", "imputation", "imputed", "imputing")
))

text_tokens <- tokens_select(text_tokens, pattern = dict, selection = "keep", window = 5)
text_tokens <- text_tokens %>% as.list()

jstor_df <- jstor_df %>% add_column(., text_tokens = NA)

for (i in seq_along(text_tokens)) {
  jstor_df$text_tokens[i] <- text_tokens[i] %>% as.character()
}

jstor_df$text_tokens <- jstor_df$text_tokens %>% unlist()

jstor_df$text_tokens <- jstor_df$text_tokens %>% stringi::stri_replace_all_fixed(., pattern = "c(", replacement = "")
jstor_df$text_tokens <- jstor_df$text_tokens %>% gsub(pattern = "[^A-Za-z0-9]", replacement = " ", x = .)
jstor_df$text_tokens <- jstor_df$text_tokens %>% stringi::stri_replace_all_fixed(., pattern = '"', replacement = "")

saveRDS(jstor_df, "/media/bilibraker/Maxtor/Krisz/Krisztian/Research/missing_data_paper/corpus_files/jstor_df_snipped_22_02.rds")
# saveRDS(jstor_df, "/media/bilibraker/Maxtor/Krisz/Krisztian/Research/missing_data_paper/corpus_files/jstor_df_snipped.rds")
