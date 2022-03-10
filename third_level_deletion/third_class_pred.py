import pandas as pd
import numpy as np
import fasttext

# load the second model
model = fasttext.load_model("./jstor_model.bin")

# load the preprocessed data
df = pd.read_csv("./jstor_second_output3.csv")

# subset for imputation_or_not == 1
df = df[df["predicted"] == 0]

# predict the data
df["predicted"] = df["text_tokens"].apply(lambda x: model.predict(x)[0][0])
df["predicted"] = np.where(df["predicted"] == "__label__deletion", 1, 0)
df = df[["id", "text_tokens", "predicted"]]

df.to_csv("./jstor_third_deletion_output.csv", index=False)
