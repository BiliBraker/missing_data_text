library(tidyverse)
library(stargazer)
library(stringi)

data <- read_csv("~/research/missing_data_paper/fasttext/4_all_levels/jstor_all_filtered.csv") |> filter(discipline != "Criminology & Law" & discipline != "Humanities & Arts")

data$discipline <- stri_replace_all_regex(data$discipline, pattern=" & ", replacement=" and ")

# pub_year as continous
model <- glm(advanced ~ pub_year+ discipline + pub_year * discipline  , data=data, family="binomial")
summary(model)

model1 <- glm(imputation ~ pub_year+ discipline + pub_year * discipline  , data=data, family="binomial")
summary(model1)

model2 <- glm(deletion ~ pub_year+ discipline + pub_year * discipline  , data=data, family="binomial")
summary(model2)

# save the results
stargazer(model,model1,model2,
          type='html',
          out="~/research/missing_data_paper/paper/log_models.html",
          title = 'Logistic models',
          dep.var.labels = c('Advanced Imputation',
                             'Imputation',
                             'Deletion')
)

# pub_year as categorical
model3 <- glm(advanced ~ as_factor(pub_year)+ discipline + as_factor(pub_year) * discipline  , data=data, family="binomial")
summary(model3)

model4 <- glm(imputation ~ as_factor(pub_year)+ discipline + as_factor(pub_year) * discipline  , data=data, family="binomial")
summary(model4)

model5 <- glm(deletion ~ as_factor(pub_year)+ discipline + as_factor(pub_year) * discipline  , data=data, family="binomial")
summary(model5)

# save the results
stargazer(model3,model4,model5,
          type='html',
          out="~/research/missing_data_paper/paper/log_models2.html",
          title = 'Logistic models',
          dep.var.labels = c('Advanced Imputation',
                             'Imputation',
                             'Deletion')
)
