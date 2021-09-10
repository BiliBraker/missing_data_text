library(tidyverse)
library(stringi)

`%notin%` <- Negate(`%in%`)

data <- read_csv("./jstor_first_output2.csv")

jstor_meta <- readRDS("/media/bilibraker/Maxtor/Krisz/Krisztian/Research/missing_data_paper/corpus_files/jstor_meta_01_03.rds")

law <- jstor_meta %>% filter(discipline == "Criminology & Law") %>%
  mutate_at(.vars = "origin", tolower) %>%
  filter(!stri_detect_regex(origin, "crimi*|jurimetrics"))

# subset of second level and extract LAW discipline
data <- data %>% filter(id %notin% law$id & predicted == 0)

set.seed(54)
train_ids <- sample(seq_along(data$id), 200)

train <- data[train_ids, ]

write_csv(train, "./train_200_2.csv")
