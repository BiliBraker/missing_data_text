library(tidyverse)

jstor <- readRDS("/media/bilibraker/Maxtor/Krisz/Krisztian/Research/missing_data_paper/corpus_files/jstor_df_snipped_22_02.rds")

jstor_train <- read_csv("/media/bilibraker/Maxtor/Krisz/Krisztian/Research/missing_data_paper/train_files/jstor_class_first.csv")


jstor_train <- cbind(jstor[which(jstor$id %in% jstor_train$id),], jstor_train$about_missing_data[which(jstor_train$id %in% jstor$id)])

jstor_train <- jstor_train %>% rename(., about_missing_data = `jstor_train$about_missing_data[which(jstor_train$id %in% jstor$id)]`)


jstor_train$fasttext <- ifelse(jstor_train$about_missing_data == 1,
                               paste("__label__about_missing_data", 
                                     jstor_train$text_tokens), 
                               paste("__label__not_about_missing_data", 
                                     jstor_train$text_tokens))

write_csv(select(jstor_train, c(text_tokens, about_missing_data)), 
          "./jstor_class_first_200.csv")

write.table(jstor_train$fasttext,
            "/media/bilibraker/Maxtor/Krisz/Krisztian/Research/missing_data_paper/fasttext/about_missing_or_not/jstor_fasttext.txt" ,
            row.names = FALSE,
            col.names = FALSE,
            quote = FALSE,
            sep="\t")
