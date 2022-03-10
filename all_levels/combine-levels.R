library(tidyverse)

meta <- readRDS("jstor_meta_01_03.rds")
jstor <- read_csv("jstor_df_snipped_TO_USE.csv")
jstor1 <- read_csv("jstor_first_output2.csv")
jstor2 <- read_csv("jstor_second_output3.csv")
jstor3_adv <- read_csv("jstor_third_advanced_output.csv")
jstor3_del <- read_csv("jstor_third_deletion_output.csv")

meta <- meta |> select(id, origin, pub_year, discipline)
jstor <- jstor |> select(id)

jstor1 <- jstor1 |>
        select(id, predicted) |>
        rename(about_missing = predicted)

jstor2 <- jstor2 |>
        select(id, predicted) |>
        rename(imputation = predicted)

jstor3_adv <- jstor3_adv |>
        select(id, predicted) |>
        rename(advanced = predicted)

jstor3_del <- jstor3_del |>
        select(id, predicted) |>
        rename(deletion = predicted)


jstor_all <- jstor |>
        left_join(meta) |>
        left_join(jstor1) |>
        left_join(jstor2) |>
        left_join(jstor3_adv) |>
        left_join(jstor3_del)

write_csv(jstor_all, "jstor_all.csv")
