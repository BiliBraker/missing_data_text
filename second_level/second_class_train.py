import fasttext

# model = fasttext.train_supervised(input="jstor.train", epoch=25, lr=1.0, wordNgrams=3)
# model = fasttext.train_supervised(input="jstor.train", autotuneValidationFile="jstor.valid")
model = fasttext.train_supervised(input="jstor.train-120-2", autotuneValidationFile="jstor.valid-80-2")

print(model.test("jstor.valid-80-2"))

model.save_model("jstor_model-60-40-2.bin")
