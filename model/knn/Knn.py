#!/usr/bin/python
# -*- coding: utf-8 -*-
import sys
import os
import json
import numpy as np
from sklearn import preprocessing
from sklearn.neighbors import KNeighborsClassifier
reload(sys)
import re
import regex
sys.setdefaultencoding('utf-8')

__W2cTrainCorpusDic = {'bg':'bul', 'ca':'cat', 'cs':'ces','de':'deu', \
        'el':'ell', 'en':'eng' ,'hu':'hun','it':'ita' ,'pt':'por',\
        'ru':'rus' ,'sv':'swe', 'tr':'tur','hi':'hin'}
__W2cTestCorpusDic = {'bg':'bul', 'bn':'ben', 'ca':'cat', 'cs':'ces', \
        'da':'dan', 'de':'deu', 'el':'ell', 'es':'spa', \
        'en':'eng', 'et':'est','eu':'eus', 'fa':'fas', 'fi':'fin',\
        'hi':'hin','hu':'hun', 'it':'ita', 'la':'lat', 'nl':'nld',\
        'pt':'por', 'ro':'ron' ,'ru':'rus','sk':'slk', 'sl':'slv',\
        'sv':'swe', 'te':'tel','tr':'tur'}
__digitPatt = regex.compile(r'[0-9]*',re.UNICODE)
'''
return {'c7':{10000:{'sv-ud11':0.8},...},....}
'''

def test():
    traintokenCnt = [20000000]
    testtokenCnt = [500000,1000000,5000000,10000000,20000000]
    trainFeatDic = dict()
    c7 = set(['bg','ca','de','el','hu','tr','hi'])
    for totaltoken  in traintokenCnt:
        c7Feature = []
        c7Label = []
        c7Word = []
        trainFeatDic[totaltoken] = dict()
        for trainlangKey in __W2cTrainCorpusDic:
            trainfilepath = '../feature/train/' + trainlangKey + '/' + str(totaltoken) + '.txt'
            trainFeatDic[totaltoken][trainlangKey] = dict()
            trainFeatDic[totaltoken][trainlangKey]['feature'] = []
            trainFeatDic[totaltoken][trainlangKey]['wordform'] = []
            trainFeatDic[totaltoken][trainlangKey]['label'] = []
            for line in open(trainfilepath):
                feat = json.loads(line.strip())
                trainFeatDic[totaltoken][trainlangKey]['feature'].append(feat['feature'])
                trainFeatDic[totaltoken][trainlangKey]['wordform'].append(feat['wordform'])
                trainFeatDic[totaltoken][trainlangKey]['label'].append(feat['label'])
                if trainlangKey in c7:
                    c7Feature.append(feat['feature'])
                    c7Label.append(feat['label'])
                    c7Word.append(feat['wordform'])
        trainFeatDic[totaltoken]['c7'] = dict()
        trainFeatDic[totaltoken]['c7']['feature'] = c7Feature
        trainFeatDic[totaltoken]['c7']['wordform'] = c7Word
        trainFeatDic[totaltoken]['c7']['label'] = c7Label

    testFeatDic = dict()
    for totaltoken in testtokenCnt:
        testFeatDic[totaltoken] = dict()
        for testlangKey in __W2cTestCorpusDic:
            testfilepath = '../feature/test/' + testlangKey + '/' + str(totaltoken) + '.txt'
            testFeatDic[totaltoken][testlangKey] = dict()
            testFeatDic[totaltoken][testlangKey]['feature'] = []
            testFeatDic[totaltoken][testlangKey]['wordform'] = []
            testFeatDic[totaltoken][testlangKey]['label'] = []
            for line in open(testfilepath):
                feat = json.loads(line.strip())
                testFeatDic[totaltoken][testlangKey]['feature'].append(feat['feature'])
                testFeatDic[totaltoken][testlangKey]['wordform'].append(feat['wordform'])
                testFeatDic[totaltoken][testlangKey]['label'].append(feat['label'])

    for traintotaltoken in trainFeatDic:
        fb = open(str(traintotaltoken) + 'result','w')
        for trainlangKey in trainFeatDic[traintotaltoken]:
            correctDic = dict()
            correctDic[trainlangKey] = dict()
            trainX = np.array(trainFeatDic[traintotaltoken][trainlangKey]['feature'])[:,:9]
            #trainX[:,5] *= 5
            #trainX[:,6] *= 5
            #trainX[:,9] *= 50
            #trainX[:,10] *= 50
            #trainX[:,11] *= 10
            trainY = trainFeatDic[traintotaltoken][trainlangKey]['label']
            scaler = preprocessing.StandardScaler().fit(trainX)
            trainX_scaled = scaler.transform(np.array(trainX))
            neigh = KNeighborsClassifier(n_neighbors=100)
            neigh.fit(trainX_scaled, trainY) 
            for testtotaltoken in testFeatDic:
                predictYDic = dict()
                for testlangKey in testFeatDic[testtotaltoken]:
                    testX = np.array(testFeatDic[testtotaltoken][testlangKey]['feature'])[:,:9]
                    #testX[:,5] *= 5
                    #testX[:,6] *= 5
                    #testX[:,9] *= 50
                    #testX[:,10] *= 50
                    #testX[:,11] *= 10
                    testY = testFeatDic[testtotaltoken][testlangKey]['label']
                    testX_scaled = scaler.transform(testX)
                    predictY = neigh.predict(testX_scaled)
                    correctCnt = 0
                    for index,labelY in enumerate(predictY):
                        if testY[index] == labelY:
                            correctCnt += 1

                    predictfilename = './predictlabel/' + trainlangKey + '_' + testlangKey + '_'\
                            + str(traintotaltoken) + '_' + str(testtotaltoken) +'.txt'
                    tmpfb = open(predictfilename,'w')
                    for index,labelY in enumerate(predictY):
                        tmpfb.write(testFeatDic[testtotaltoken][testlangKey]['wordform'][index]\
                                + '\t' + testY[index] + '\t' + '\t' + labelY + '\n')
                        tmpfb.flush()
                    tmpfb.write('\n\nout of vocabulary word prediction\n')

                    oovfile = '../feature/test/' + testlangKey + '/' + str(testtotaltoken) +'_oov.txt'
                    oovcorrectcnt = 0
                    oovtotalcnt = 0
                    for line in open(oovfile):
                        oovtotalcnt += 1
                        word,pos = line.strip().split('\t')[0],line.strip().split('\t')[1]
                        if __digitPatt.match(word) and pos == 'NUM':
                            oovcorrectcnt += 1
                            tmpfb.write(word + '\t' + pos + '\t' + 'NUM' + '\n')
                            tmpfb.flush()
                            continue
                        elif pos == 'NOUN':
                            oovcorrectcnt += 1
                        tmpfb.write(word + '\t' + pos + '\t' + 'NOUN' + '\n')
                    tmpfb.close()
                    predictYDic[testlangKey] = (correctCnt + oovcorrectcnt) / ((len(testY) + oovtotalcnt) * 1.0)

                correctDic[trainlangKey][testtotaltoken] = predictYDic
            fb.write(json.dumps(correctDic,ensure_ascii=False)+'\n')
            fb.flush()
        fb.close()



if __name__ == '__main__':
    test()

