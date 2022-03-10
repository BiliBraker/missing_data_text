from sklearn.metrics import confusion_matrix, classification_report
import pandas as pd
import numpy as np
import fasttext

model = fasttext.load_model("./jstor_model.bin")

df = pd.read_csv("./jstor_class_first_200.csv") 
df = df.iloc[140:200, :]
# print(df)
# predict the data
df["predicted"] = df["text_tokens"].apply(lambda x: model.predict(x)[0][0])
df["predicted"] = np.where(df["predicted"] == "__label__about_missing_data", 1, 0)
# print(df["predicted"])
# Create the confusion matrix
print(confusion_matrix(df["about_missing_data"], df["predicted"]))
print(classification_report(df["about_missing_data"], df["predicted"]))
