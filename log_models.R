library(tidyverse)
library(stargazer)
library(stringi)
library(margins)
library(ggeffects)

data <- read_csv("~/research-sync/missing_data_paper/fasttext/4_all_levels/jstor_all_filtered.csv") |> filter(discipline != "Criminology & Law" & discipline != "Humanities & Arts")

data$discipline <- stri_replace_all_regex(data$discipline, pattern = " & ", replacement = " and ")
data$pub_year_cat <- relevel(as_factor(data$pub_year_cat), "[1999,2005]")
# pub_year as continous
model <- glm(advanced ~ pub_year + discipline + pub_year * discipline, data = data, family = "binomial")
summary(model)
margins(model)
ggpredict(model)
ggpredict(model, "pub_year")
ggpredict(model, "discipline")

model1 <- glm(imputation ~ pub_year + discipline + pub_year * discipline, data = data, family = "binomial")
summary(model1)
margins(model1)
ggpredict(model1)
ggpredict(model1, "pub_year")
ggpredict(model1, "discipline")

model2 <- glm(deletion ~ pub_year + discipline + pub_year * discipline, data = data, family = "binomial")
summary(model2)

# save the results
stargazer(model, model1,
  type = "html",
  out = "~/research/missing_data_paper/paper/log_models.html",
  title = "Logistic models",
  dep.var.labels = c(
    "Advanced Imputation",
    "Imputation",
    "Deletion"
  )
)

# pub_year as categorical
model3 <- glm(advanced ~ pub_year_cat + discipline + pub_year_cat * discipline, data = data, family = "binomial")
summary(model3)

model4 <- glm(imputation ~ pub_year_cat + discipline + pub_year_cat * discipline, data = data, family = "binomial")
summary(model4)

model5 <- glm(deletion ~ pub_year_cat + discipline + pub_year_cat * discipline, data = data, family = "binomial")
summary(model5)

# save the results
stargazer(model3, model4,
  type = "html",
  out = "~/research/missing_data_paper/paper/log_models2.html",
  title = "Logistic models",
  dep.var.labels = c(
    "Advanced Imputation",
    "Imputation",
    "Deletion"
  )
)
