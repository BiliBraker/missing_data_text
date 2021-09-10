from sklearn.metrics import confusion_matrix, classification_report
import pandas as pd
import numpy as np
import fasttext

model = fasttext.load_model("./jstor_model-60-40-2.bin")

df = pd.read_csv("./jstor_class_second_200_2.csv") 
df = df.iloc[120:200, :]
# print(df)
# predict the data
df["predicted"] = df["text_tokens"].apply(lambda x: model.predict(x)[0][0])
df["predicted"] = np.where(df["predicted"] == "__label__imputation", 1, 0)
# print(df["predicted"])
# Create the confusion matrix
print(confusion_matrix(df["imputation_or_not"], df["predicted"]))
print(classification_report(df["imputation_or_not"], df["predicted"]))
