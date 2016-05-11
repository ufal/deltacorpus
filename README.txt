Deltacorpus: corpus of texts in many languages tagged by a delexicalized tagger

David Mareček, Zhiwei Yu, Dan Zeman, Zdeněk Žabokrtský / ÚFAL MFF UK

http://ufal.mff.cuni.cz/deltacorpus
http://hdl.handle.net/11234/1-1662
https://github.com/ufal/deltacorpus
https://wiki.ufal.ms.mff.cuni.cz/user:zeman:deltacorpus


------------------------------------------------------------------------------
Legacy README (Zhiwei):

Here I will introduce how my project work.
1. feature calculation:
    the main feature calculation source file is /zhiwai/pos/model/tools/get_featurefromw2c.py.I write both 
the test fearture calculation and train feature calculation into it.And it only calculates those language that 
are specified by the "__W2cTestCorpus" and "__W2cTrainCorpus".If you want to calculate other languages feature,you may have to put the languages into the "__W2cTestCorpus" dictionary.
    For example,if you want to calculate the feature of the training language.It first go through "__W2cTrainCorpus" dictionay and get a language key,and then use the key(call KEY) to get the training corpus from /zhiwai/pos/w2c/KEY.gz and then  tokenize it(one line each time) and use the words after tokenization to get some infomation,like wordcount and previous word,etc.The function is named "__getWordInformationFromCorpus". 
    After reading all the lines from the corpus,it then use them to  calculate the 17 features for the corresponding training language.The main feature calculation function is call "__generateFeatureVectorFromW2c". I think it is easy to understand. When a word's feature calculation is done,it write it to another local file '/zhiwai/pos/model/feature/'.you can go into the dir to see the details.
    As for the extract_token.py.It just read the training and testing word from 'zhiwai/pos/data/train' or 'zhiwai/pos/data/test'.It is called by the get_featurefromw2c.py.

2. model training and testing:
    There are many models located on 'zhiwai/pos/model'.For example,if you want to use the SVM to calculate the accuracy of testing,it first reads the training feature from 'zhiwai/pos/model/feature'.And for each training language,it use its tfeatures to train a model and them use the model to predict a tag for each testing example.For each testing language we write the predicted tag into a local dir called 'svm/predictlabel/'.Each file in it looks like 'en_hi_20000000_20000000.txt'('en' means training language,'hi' means testing language,'20000000' means how many tokens tokens you take to calculate the feature.Each line in it takes the form of 'word   predictedlabel  truelabel'.
    It worths reminding that I do not save the SVM model into a local file.But it does not matter.It is easy to modify if you want to tag the languages and write them into a local file.


