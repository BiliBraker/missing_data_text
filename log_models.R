library(tidyverse)
library(stargazer)
library(stringi)
library(margins)
library(ggeffects)

#data <- read_csv("jstor_all.csv")
#data <- data |>
        #filter(about_missing == 0) |>
        #select(-c(origin, about_missing))
#data$pub_year_cat <- cut_interval(data$pub_year, 3)
#write_csv(data, "jstor_all_filtered.csv")
data <- read_csv("~/research-sync/missing_data_paper/fasttext/4_all_levels/jstor_all_filtered.csv") |> filter(discipline != "Criminology & Law" & discipline != "Humanities & Arts")

data$discipline <- stri_replace_all_regex(data$discipline, pattern = " & ", replacement = " and ") |> as_factor()
data$pub_year_cat <- relevel(as_factor(data$pub_year_cat), "[1999,2005]")
# pub_year as continous
model <- glm(advanced ~ pub_year + discipline, data = data, family = "binomial")
summary(model)
margins(model)
ggpredict(model)
ggpredict(model, "pub_year")
ggpredict(model, "discipline")

model1 <- glm(imputation ~ pub_year + discipline, data = data, family = "binomial")
summary(model1)
margins(model1)
ggpredict(model1)
ggpredict(model1, "pub_year")
ggpredict(model1, "discipline")

model2 <- glm(advanced ~ pub_year + discipline + pub_year * discipline, data = data, family = "binomial")
summary(model2)

model3 <- glm(imputation ~ pub_year + discipline + pub_year * discipline, data = data, family = "binomial")
summary(model3)

# save the results
#stargazer(model, model1, model2, model3,
  #type = "html",
  #out = "~/research-sync/missing_data_paper/paper/log_models3.html",
  #title = "Logistic models",
  #dep.var.labels = c(
    #"Advanced Imputation",
    #"Imputation",
    #"Advanced Imputation<br>(with interaction)",
    #"Imputation<br>(with interaction)"
  #)
#)
# LaTeX
stargazer(model, model1, model2, model3,
  type = "latex",
  out = "~/research-sync/missing_data_paper/paper/log_models3.tex",
  title = "Logistic models",
  dep.var.labels = c(
    "Advanced Imputation",
    "Imputation",
    "Advanced Imputation<br>(with interaction)",
    "Imputation<br>(with interaction)"
  ),
  column.sep.width = "-15pt"
)

save(model, model1, model2, model3, file = "missing-data-models.RData")
