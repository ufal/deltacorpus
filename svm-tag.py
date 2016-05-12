#!/usr/bin/python
# -*- coding: utf-8 -*-
# Usage: ./svm-tag.py <trained model file name> <testing features file name> <predicted>

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
    modelfilepath = sys.argv[1]
    clf = pickle.load(open(modelfilepath, 'rb'))
    testfilepath = sys.argv[2] #'../feature/test/1000000/' + testlangKey + '/' + str(totaltoken) + '.txt'
    testFeatDic = dict()
    testFeatDic['feature'] = []
    testFeatDic['wordform'] = []
    testFeatDic['label'] = []
    for line in open(testfilepath):
        feat = json.loads(line.strip())
        testFeatDic['feature'].append(feat['feature'])
        testFeatDic['wordform'].append(feat['wordform'])
        testFeatDic['label'].append(feat['label'])

    predictYDic = dict()
    testX = np.array(testFeatDic['feature'])[:,:17]
    testY = testFeatDic['label']
    scaler = preprocessing.StandardScaler().fit(testX)
    testX_scaled = scaler.transform(np.array(testX))
    predictY = clf.predict(testX_scaled)
    correctCnt = 0
    for index,labelY in enumerate(predictY):
        if testY[index] == labelY:
            correctCnt += 1

    predictfilename = sys.argv[3]
    tmpfb = open(predictfilename,'w')
    for index,labelY in enumerate(predictY):
        tmpfb.write(testFeatDic['wordform'][index] + '\t' + testY[index] + '\t' + '\t' + labelY + '\n')
        tmpfb.flush()
    ###!!!???
    #oovfile = sys.argv[1] + '.oov'
    #oovcorrectcnt = 0
    #oovtotalcnt = 0
    #for line in open(oovfile):
    #    oovtotalcnt += 1
    #    word,pos = line.strip().split('\t')[0],line.strip().split('\t')[1]
    #    if __digitPatt.match(word) and pos == 'NUM':
    #        oovcorrectcnt += 1
    #        tmpfb.write(word + '\t' + pos + '\t' + 'NUM' + '\n')
    #        tmpfb.flush()
    #        continue
    #    elif pos == 'NOUN':
    #        oovcorrectcnt += 1
    #    tmpfb.write(word + '\t' + pos + '\t' + 'NOUN' + '\n')
    tmpfb.close()


if __name__ == '__main__':
    test()
