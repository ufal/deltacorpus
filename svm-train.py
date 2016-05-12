#!/usr/bin/python
# -*- coding: utf-8 -*-
# Usage: ./svm-train.py <training features file name> <trained model file name>

import sys
import os
import re
import regex
import json
import pickle
import math
from sklearn import svm
import numpy as np
from sklearn import preprocessing
reload(sys)
sys.setdefaultencoding('utf-8')

__digitPatt = regex.compile(r'[0-9]*',re.UNICODE)

def test():
    trainFeatDic = dict()
    trainfilepath = sys.argv[1]
    trainFeatDic = dict()
    trainFeatDic['feature'] = []
    trainFeatDic['wordform'] = []
    trainFeatDic['label'] = []
    for line in open(trainfilepath):
        feat = json.loads(line.strip())
        trainFeatDic['feature'].append(feat['feature'])
        trainFeatDic['wordform'].append(feat['wordform'])
        trainFeatDic['label'].append(feat['label'])

    print 'Training SVM model'
    correctDic = dict()
    trainX = np.array(trainFeatDic['feature'])[:,:17]
    trainY = trainFeatDic['label']
    scaler = preprocessing.StandardScaler().fit(trainX)
    trainX_scaled = scaler.transform(np.array(trainX))
    clf = svm.SVC()
    clf.fit(trainX_scaled,trainY)
    # Save the trained model to a pickle file.
    modelFileName = sys.argv[2]
    pickle.dump(clf, open(modelFileName, 'wb'));
    # And this is how we will load the model again:
    # clf = pickle.load(open(modelFileName, 'rb'))
    print 'SVM model trained succesfully'

if __name__ == '__main__':
    test()
