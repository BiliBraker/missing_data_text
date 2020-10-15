library(stringi)
library(qdapDictionaries)

# Functions
## for cleaning latex and html markup
latex_html_remove <- function(x) {
  clean_x <- x %>%
    gsub("<tex-math.*?</tex-math>", "", .) %>%
    gsub("<.*?>", "", .) %>%
    stri_replace_all_regex(., "\n", " ")
  return(clean_x)
}

## for removing unfrequent/meaningless terms
unfreq_term_remover <- function(content, freq_terms) {
  word.freq <- table(unlist(word_tokenizer(content)))
  word.list <- names(word.freq)
  to_remove <- which(word.list %in% freq_terms)
  word.remove <- paste(" ", word.list[to_remove], " ", sep = "")
  content.clean <- stri_replace_all_fixed(content, pattern = word.remove, replacement = " ", vectorize_all = F)
  
  return(content.clean)
}

# for trimming disciplines
disc_sub = function(x){
  d = x %>% 
    str_split_fixed(.,' ;',n=2)
  d = d[1,1]
  return(d)
}

`%notin%` <- Negate(`%in%`)

remove_special <- content_transformer(function(x, pattern) {
  return(gsub(pattern, " ", x))
})

## keywords
stopwords_new <- stopwords()[c(-42, -121, -167)] # stopwords excluding 'were', 'at', and 'not'

keywords <- read.delim("./keywords.txt")
keywords <- keywords[, 1] %>%
  as.vector() %>%
  gsub(" ", "", .)

## building vocabulary to remove meaningless words
vocab <- c(GradyAugmented, keywords[which(keywords %notin% GradyAugmented)])

