## Setup ##

library(tidyverse)
library(magrittr)
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

####### modification starts from here
jstor_data <- readRDS("/media/bilibraker/Maxtor/Krisz/Krisztian/Research/missing_data_paper/corpus_files/jstor_data.rds")
newcols <- c("doc_id", "journal_pub_id", "origin", "heading", "pub_year", "text")
colnames(jstor_data) <- newcols

jstor_data <- jstor_data %>%
  relocate("doc_id", "text", "heading", "origin", "pub_year", "journal_pub_id")

jstor_data %<>% add_column(textlen = NA)
jstor_data %<>%  add_column(first_ref = NA)

jstor_data$textlen <- mclapply(jstor_data$text, nchar, mc.cores = 4L) %>% unlist()

### extract first reference from .xml files
path <- "/media/bilibraker/Maxtor/Krisz/Krisztian/Research/missing_data_paper/JSTOR/data/metadata/"

get_first_ref <- function (meta_file){
  # using tryCatch because jst_get_references aborts the execution
  # if it can't find any reference
  tryCatch(
  {
    ref <- jst_get_references(meta_file)
    ref %<>%
      slice(., 1L) %>%
      select(., ref_unparsed) %>%
      as.character() %>%
      str_squish(.)

    return(ref)
  },
  error = function (e){
    e <- NA
    return(e)
  }
  )
}

jstor_data$first_ref <- mclapply(paste0(path, jstor_data$doc_id, ".xml"),
                                 get_first_ref,
                                 mc.cores = 4L) %>% unlist()
jstor_data %>%
  filter(.,is.na(first_ref)) %>%
  select(., first_ref) %>%
  nrow()
### modification ends here

jstor_data %>% write_csv(., "/media/bilibraker/Maxtor/Krisz/Krisztian/Research/missing_data_paper/JSTOR/jstor_data_v2.csv")
## Creating VCorpus ##

jstor_corpus <- VCorpus(DataframeSource(jstor_data))

jstor_corpus %>% saveRDS(., "/media/bilibraker/Maxtor/Krisz/Krisztian/Research/missing_data_paper/jstor_corpus.rds")

## Filling up the Vcorpus with metadata. Not a necessary step.

pb <- progress_bar$new(total = length(jstor_corpus))

for (i in seq_along(jstor_corpus)) {
  pb$tick()

  jstor_corpus[[i]]$meta$heading <- meta(jstor_corpus)$heading[i]
  jstor_corpus[[i]]$meta$pub_year <- meta(jstor_corpus)$pub_year[i]
  jstor_corpus[[i]]$meta$origin <- meta(jstor_corpus)$origin[i]
  jstor_corpus[[i]]$meta$journal_pub_id <- meta(jstor_corpus)$journal_pub_id[i]
}

# Metadata
## Assign disciplines to journals

jstor_meta <- meta(jstor_corpus)

journal_info <- jst_get_journal_overview()

jstor_meta %>% add_column(., "discipline" = NA)

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


disc_reduced <- c(
  "Biological Sciences", "Business & Economics", "Health Sciences", "Science & Mathematics",
  "Social Sciences", "Psychology & Education", "Public Policy & Administration", "Political Science", "Humanities & Arts", "Social Sciences",
  "Social Sciences", "Business & Economics", "Other", "Environmental Science", "Social Sciences",
  "Biological Sciences", "Science & Mathematics", "Criminology & Law", "Social Sciences", "Biological Sciences",
  "Other", "Social Sciences", "Environmental Science", "Health Sciences", "Psychology & Education", "Social Sciences",
  "Criminology & Law", "Science & Mathematics", "Public Policy & Administration", "Other",
  "Environmental Science", "Humanities & Arts", "Humanities & Arts", "Social Sciences",
  "Humanities & Arts", "Science & Mathematics", "Humanities & Arts", "Humanities & Arts", "Social Sciences",
  "Social Sciences", "Biological Sciences", "Humanities & Arts", "Environmental Science",
  "Science & Mathematics", "Social Sciences", "Social Sciences", "Social Sciences", "Political Science",
  "Social Sciences", "Social Sciences", "Social Sciences", "Other", "Social Sciences",
  "Humanities & Arts", "Political Science"
)

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
  saveRDS(., "jstor_meta.rds")
