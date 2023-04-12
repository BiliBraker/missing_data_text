## Setup ##

library(tidyverse)
library(magrittr)
library(stringi)
library(tm)
library(jstor)
library(jprep)
library(progress)
library(parallel)

## Extract metadata from .xml files ##

files <- list.files("./JSTOR/data/metadata/", pattern = "xml", full.names = T)

metadata <- jst_import(files,
  out_file = "./imported_metadata", .f = jst_get_article,
  files_per_batch = 25000, show_progress = T
)

metadata_1 <- read_csv("./JSTOR/imported_metadata-1.csv")
metadata_2 <- read_csv("./JSTOR/imported_metadata-2.csv")

metadata_1 <- metadata_1 %>%
  select(-c(
    journal_doi, journal_jcode, first_page, last_page, pub_month, pub_day,
    volume, issue, article_type, article_pub_id, article_doi, journal_doi,
    page_range, language, article_jcode
  ))

metadata_2 <- metadata_2 %>%
  select(-c(
    journal_doi, journal_jcode, first_page, last_page, pub_month, pub_day,
    volume, issue, article_type, article_pub_id, article_doi, journal_doi,
    page_range, language, article_jcode
  ))

metadata <- bind_rows(metadata_1, metadata_2)

metadata %>% write_csv(., path = "./metadata.csv")

## Extract content from .txt files ##

path <- paste0(getwd(), "/JSTOR/data/ocr/")

files <- list.files(path, pattern = "txt", full.names = T)

content <- jst_import(files,
  out_file = "./JSTOR/jstor_content", .f = jst_get_full_text,
  files_per_batch = 10000, show_progress = T
)

content_1 <- read_csv(paste0("./JSTOR/", "jstor_content-1.csv"))
content_2 <- read_csv(paste0("./JSTOR/", "jstor_content-2.csv"))
content_3 <- read_csv(paste0("./JSTOR/", "jstor_content-3.csv"))
content_4 <- read_csv(paste0("./JSTOR/", "jstor_content-4.csv"))
content_5 <- read_csv(paste0("./JSTOR/", "jstor_content-5.csv"))

content <- bind_rows(content_1, content_2, content_3, content_4, content_5)

content <- content %>%
  select(-encoding)

## Creating the DataFrameSource for VCorpus

jstor_data <- metadata %>%
  left_join(content, by = "file_name")

# saveRDS(jstor_data,'./JSTOR/jstor_data.rds')
## Renaming and relocating column names for VCorpus ##

jstor_data <- readRDS("/media/bilibraker/Maxtor/Krisz/Krisztian/Research/missing_data_paper/corpus_files/jstor_data.rds")
newcols <- c("doc_id", "journal_pub_id", "origin", "heading", "pub_year", "text")
colnames(jstor_data) <- newcols

jstor_data <- jstor_data %>%
  relocate("doc_id", "text", "heading", "origin", "pub_year", "journal_pub_id")

jstor_data %<>% add_column(textlen = NA)
jstor_data %<>% add_column(first_ref = NA)

jstor_data$textlen <- mclapply(jstor_data$text, nchar, mc.cores = 4L) %>% unlist()

## find the keywords --> start of references ##
jstor_data <- read_csv("/media/bilibraker/Maxtor/Krisz/Krisztian/Research/missing_data_paper/JSTOR/jstor_data_v2.csv")
jstor_data %<>% add_column(ref_pos = NA)

pb <- progress_bar$new(total = length(jstor_data$ref_pos))

for (i in seq_along(jstor_data$ref_pos)) {
  pb$tick()
  # find the start of the references with keywords #

  ref_begin <- stri_locate_all_fixed(str_to_lower(jstor_data$text[i]), " references ")
  ref_begin <- ref_begin[[1]][nrow(ref_begin[[1]]), 1] %>% as.numeric() # last row of the first column == start of the references

  if (is.na(ref_begin) == FALSE) {
    jstor_data$ref_pos[i] <- ref_begin
  }
  if (is.na(ref_begin) == TRUE) {
    ref_begin <- stri_locate_all_fixed(str_to_lower(jstor_data$text[i]), " bibliography ")
    ref_begin <- ref_begin[[1]][nrow(ref_begin[[1]]), 1] %>% as.numeric()
    jstor_data$ref_pos[i] <- ref_begin
  }
  if (is.na(ref_begin) == TRUE) {
    jstor_data$ref_pos[i] <- NA
  }
}

jstor_data$ref_pos %<>% as.numeric()

## plots ##
# first reference / text lenght #
d <- jstor_data %>%
  mutate(text_len_prop = first_ref_pos / textlen)

d %>%
  ggplot(., aes(x = text_len_prop)) +
  geom_histogram(color = "black", fill = "lightblue") +
  theme_bw()

jstor_data %>%
  filter(., !is.na(first_ref_pos) &
    textlen < 5e5) %>%
  select(., first_ref_pos) %>%
  unlist() %>%
  tibble() %>%
  ggplot(., aes(x = .)) +
  geom_histogram(color = "black", fill = "red")

jstor_data %>%
  filter(., textlen < 5e5) %>%
  select(., textlen) %>%
  unlist() %>%
  as.numeric() %>%
  tibble() %>%
  ggplot(., aes(x = .)) +
  geom_histogram(color = "black", fill = "lightgreen")

## reference keywords position and first reference position ##

jstor_data %>%
  filter(., !is.na(first_ref_pos) &
    !is.na(ref_pos) &
    textlen < 2e5) %>%
  select(., first_ref_pos, ref_pos) %>%
  ggplot(.) +
  geom_histogram(aes(x = first_ref_pos), alpha = .5, fill = "yellow", color = "black") +
  geom_histogram(aes(x = ref_pos), alpha = .5, fill = "red", color = "blue") +
  theme_bw()

d <- jstor_data %>%
  mutate(text_len_prop = abs(first_ref_pos - ref_pos))

d %>%
  ggplot(., aes(x = text_len_prop)) +
  geom_histogram(color = "black", fill = "lightblue") +
  theme_bw()

d <- jstor_data %>%
  mutate(cut_len_prop = ref_pos / textlen)

d %>%
  ggplot(., aes(x = cut_len_prop)) +
  geom_histogram(color = "black", fill = "lightblue", bins = 50) +
  theme_bw()

d_f <- d %>%
  filter(cut_len_prop > .75)

## TRESHOLD == .75 ##

jstor_data <- jstor_data %>%
  mutate(cut_len_prop = ref_pos / textlen)

pb <- progress_bar$new(total = length(jstor_data$ref_pos))
for (i in seq_along(jstor_data$text)) {
  pb$tick()
  if (!is.na(jstor_data$cut_len_prop[i]) & (jstor_data$cut_len_prop[i] > .75)) {
    jstor_data$text[i] <- substr(jstor_data$text[i], 1, jstor_data$ref_pos[i])
  } else {
    next
  }
}

jstor_data %>% write_csv(., "/media/bilibraker/Maxtor/Krisz/Krisztian/Research/missing_data_paper/JSTOR/jstor_data_ref_cut.csv")
jstor_data <- read_csv("/media/bilibraker/Maxtor/Krisz/Krisztian/Research/missing_data_paper/JSTOR/jstor_data_ref_cut.csv")
## Creating VCorpus ##

jstor_corpus <- VCorpus(DataframeSource(jstor_data))

## Filling up the Vcorpus with metadata. Not a necessary step.

pb <- progress_bar$new(total = length(jstor_corpus))

for (i in seq_along(jstor_corpus)) {
  pb$tick()

  jstor_corpus[[i]]$meta$heading <- meta(jstor_corpus)$heading[i]
  jstor_corpus[[i]]$meta$pub_year <- meta(jstor_corpus)$pub_year[i]
  jstor_corpus[[i]]$meta$origin <- meta(jstor_corpus)$origin[i]
  jstor_corpus[[i]]$meta$journal_pub_id <- meta(jstor_corpus)$journal_pub_id[i]
}

# jstor_corpus %>% saveRDS(., "/media/bilibraker/Maxtor/Krisz/Krisztian/Research/missing_data_paper/jstor_corpus.rds")
# jstor_corpus <- readRDS("/media/bilibraker/Maxtor/Krisz/Krisztian/Research/missing_data_paper/jstor_corpus.rds")

# Metadata
## Assign disciplines to journals ##
jstor_meta <- meta(jstor_corpus)
jstor_meta <- jstor_meta %>%
  add_column(id = NA) %>%
  relocate(id)

pb <- progress_bar$new(total = length(jstor_corpus))

for (i in seq_along(jstor_corpus)) {
  pb$tick()

  jstor_meta$id[i] <- jstor_corpus[[i]]$meta$id
}


rm(jstor_corpus)

journal_info <- jst_get_journal_overview()

jstor_meta %<>% add_column(., "discipline" = NA)

pb <- progress_bar$new(total = length(jstor_meta$journal_pub_id))

for (i in seq_along(jstor_meta$journal_pub_id)) {
  pb$tick()
  if (jstor_meta$origin[i] %in% journal_info$title) {
    jstor_meta$discipline[i] <- journal_info$discipline[which(journal_info$title == jstor_meta$origin[i])]
  } else {
    jstor_meta$discipline[i] <- "other"
  }
}

## Group disciplines

jstor_meta$discipline <- jstor_meta$discipline %>%
  pbapply::pblapply(., disc_sub) %>%
  as.character()

disc_levels <- jstor_meta %>%
  group_by(discipline) %>%
  count() %>%
  arrange(., desc(n))

# disc_reduced is from jprep

disc_levels %<>%
  add_column(., disc_reduced)


pb <- progress_bar$new(total = length(jstor_meta$journal_pub_id))

for (i in seq_along(jstor_meta$journal_pub_id)) {
  pb$tick()
  if (jstor_meta$discipline[i] %in% disc_levels$discipline) {
    jstor_meta$discipline[i] <- disc_levels$disc_reduced[which(disc_levels$discipline == jstor_meta$discipline[i])]
  }
}

jstor_meta$discipline[which(is.na(jstor_meta$discipline) == TRUE)] <- "Other"

jstor_meta %>%
  saveRDS(., "/media/bilibraker/Maxtor/Krisz/Krisztian/Research/missing_data_paper/corpus_files/jstor_meta_01_03.rds")
