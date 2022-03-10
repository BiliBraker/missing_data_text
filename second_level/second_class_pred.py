import pandas as pd
import numpy as np
import fasttext

# load the second model
model = fasttext.load_model("./jstor_model-60-40-2.bin")

# load the preprocessed data
df = pd.read_csv("./jstor_first_output2.csv")

# subset for about_missing_data == 0
df = df[df["predicted"] == 0]

# predict the data
df["predicted"] = df["text_tokens"].apply(lambda x: model.predict(x)[0][0])
df["predicted"] = np.where(df["predicted"] == "__label__imputation", 1, 0)
df = df[["id", "text_tokens", "predicted"]]

df.to_csv("./jstor_second_output3.csv", index=False)
