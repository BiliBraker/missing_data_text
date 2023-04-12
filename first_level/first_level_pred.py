import pandas as pd
import numpy as np
import fasttext

# load the first model
model = fasttext.load_model("./jstor_model.bin")

# load the preprocessed data
df = pd.read_csv("/media/bilibraker/Maxtor/Krisz/Krisztian/Research/missing_data_paper/corpus_files/jstor_df_snipped_TO_USE.csv") 

# predict the data
df["predicted"] = df["text_tokens"].apply(lambda x: model.predict(x)[0][0])
df["predicted"] = np.where(df["predicted"] == "__label__about_missing_data", 1, 0)
df = df[["id", "text_tokens", "predicted"]]

df.to_csv("./jstor_first_output.csv", index=False)
