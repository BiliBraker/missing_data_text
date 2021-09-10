library(tidyverse)

data <- read_csv("./jstor_train_advanced.csv")

data$fasttext <- ifelse(data$advanced_or_not == 1, paste("__label__advanced", data$text_tokens), paste("__label__not_advanced", data$text_tokens))

write_csv(select(data, c(id, text_tokens, advanced_or_not)), "./jstor_class_third.csv")

write.table(data$fasttext, "./jstor_class_third.txt", 
            row.names = FALSE, col.names = FALSE, 
            sep = "\t")
