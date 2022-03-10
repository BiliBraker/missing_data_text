from sklearn.metrics import confusion_matrix, classification_report
import pandas as pd
import numpy as np
import fasttext

model = fasttext.load_model("./jstor_model.bin")

df = pd.read_csv("./jstor_class_third_deletion.csv") 
df = df.iloc[120:200, :]
# print(df)
# predict the data
df["predicted"] = df["text_tokens"].apply(lambda x: model.predict(x)[0][0])
df["predicted"] = np.where(df["predicted"] == "__label__deletion", 1, 0)
# Create the confusion matrix
print(confusion_matrix(df["predicted"], df["deletion_or_not"]))
print(classification_report(df["predicted"], df["deletion_or_not"]))
