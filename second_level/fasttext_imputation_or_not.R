library(tidyverse)

data <- read_csv("./train_200_2.csv")
data <- data |> rename(imputation_or_not = predicted)

data$fasttext <- ifelse(data$imputation_or_not == 1, paste("__label__imputation", data$text_tokens), paste("__label__not_imputation", data$text_tokens))

write_csv(select(data, c(id, text_tokens, imputation_or_not)), "./jstor_class_second_200_2.csv")

write.table(data$fasttext, "./jstor_class_second_200_2.txt", 
            row.names = FALSE, col.names = FALSE, 
            sep = "\t")
