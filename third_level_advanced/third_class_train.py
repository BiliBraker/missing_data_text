import fasttext

# model = fasttext.train_supervised(input="jstor.train", epoch=25, lr=1.0, wordNgrams=2)
model = fasttext.train_supervised(input="jstor.train", autotuneValidationFile="jstor.valid")

print(model.test("jstor.valid"))

model.save_model("jstor_model.bin")
