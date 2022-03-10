library(tidyverse)

jstor_second <- read_csv("./jstor_second_output3.csv")

jstor_second <- jstor_second %>%
        filter(predicted == 1) %>%
        select(id, text_tokens) %>%
        add_column(advanced_or_not = 0)

set.seed(12)
jstor_train_advanced <- jstor_second[sample(seq_len(nrow(jstor_second)), 200), ]

write_csv(jstor_train_advanced, "./jstor_train_advanced.csv")
#k_id <- sample(seq_len(nrow(jstor_train_advanced)), 100)
#k <- jstor_train_advanced[k_id, ]
#z <- jstor_train_advanced[-k_id, ]

#write_csv(k, "./jstor_advanced_k.csv")
#write_csv(z, "./jstor_advanced_z.csv")
