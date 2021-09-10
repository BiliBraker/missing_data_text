library(tidyverse)

data <- read_csv("./jstor_train_deletion.csv")

data$fasttext <- ifelse(data$deletion_or_not == 1, paste("__label__deletion", data$text_tokens), paste("__label__not_deletion", data$text_tokens))

write_csv(select(data, c(id, text_tokens, deletion_or_not)), "./jstor_class_third_deletion.csv")

write.table(data$fasttext, "./jstor_class_third_deletion.txt", 
            row.names = FALSE, col.names = FALSE, 
            sep = "\t")
