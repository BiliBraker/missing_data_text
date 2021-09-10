library(tidyverse)

jstor_second <- read_csv("./jstor_second_output3.csv")

jstor_second <- jstor_second %>%
        filter(predicted == 0) %>%
        select(id, text_tokens) %>%
        add_column(deletion_or_not = 0)

set.seed(43)
jstor_train_deletion <- jstor_second[sample(seq_len(nrow(jstor_second)), 200), ]

write_csv(jstor_train_deletion, "./jstor_train_deletion.csv")
