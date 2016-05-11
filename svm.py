#!/usr/bin/python
# -*- coding: utf-8 -*-
# Usage: ./svm.py <training features> <testing features> <predicted> 
import sys
import os
import re
import regex
import json
import math
from sklearn import svm
import numpy as np
from sklearn import preprocessing
reload(sys)
sys.setdefaultencoding('utf-8')

#__W2cTrainCorpusDic = {'bg':'bul', 'ca':'cat', 'cs':'ces','de':'deu', \
#        'el':'ell', 'en':'eng' ,'hu':'hun','it':'ita' ,'pt':'por',\
#        'ru':'rus' ,'sv':'swe', 'tr':'tur','hi':'hin'}
#__W2cTrainCorpusDic = {'bg':'bul', 'ca':'cat', 'de':'deu', 'el':'ell', 'hu':'hun', 'tr':'tur', 'hi':'hin'}
#__W2cTestCorpusDic = {'bg':'bul', 'bn':'ben', 'ca':'cat', 'cs':'ces', \
#        'da':'dan', 'de':'deu', 'el':'ell', 'es':'spa', \
#        'en':'eng', 'et':'est','eu':'eus', 'fa':'fas', 'fi':'fin',\
#        'hi':'hin','hu':'hun', 'it':'ita', 'la':'lat', 'nl':'nld',\
#        'pt':'por', 'ro':'ron' ,'ru':'rus','sk':'slk', 'sl':'slv',\
#        'sv':'swe', 'te':'tel','tr':'tur'}
#__W2cTestCorpusDic = { \
#        'afr':'afr', 'als':'als', 'amh':'amh', 'ara':'ara', 'arg':'arg', 'arz':'arz', 'ast':'ast', 'aze':'aze', 'bcl':'bcl', \
#        'bel':'bel', 'ben':'ben', 'bos':'bos', 'bpy':'bpy', 'bre':'bre', 'bug':'bug', 'bul':'bul', 'cat':'cat', 'ceb':'ceb', \
#        'ces':'ces', 'chv':'chv', 'cos':'cos', 'cym':'cym', 'dan':'dan', 'deu':'deu', 'diq':'diq', 'ell':'ell', 'eng':'eng', \
#        'epo':'epo', 'est':'est', 'eus':'eus', 'fao':'fao', 'fas':'fas', 'fin':'fin', 'fra':'fra', 'fry':'fry', 'gan':'gan', \
#        'gla':'gla', 'gle':'gle', 'glg':'glg', 'glk':'glk', 'guj':'guj', 'hat':'hat', 'hbs':'hbs', 'heb':'heb', 'hif':'hif', \
#        'hin':'hin', 'hrv':'hrv', 'hsb':'hsb', 'hun':'hun', 'hye':'hye', 'ido':'ido', 'ina':'ina', 'ind':'ind', 'isl':'isl', \
#        'ita':'ita', 'jav':'jav', 'jpn':'jpn', 'kan':'kan', 'kat':'kat', 'kaz':'kaz', 'kor':'kor', 'kur':'kur', 'lat':'lat', \
#        'lav':'lav', 'lim':'lim', 'lit':'lit', 'lmo':'lmo', 'ltz':'ltz', 'mal':'mal', 'mar':'mar', 'mkd':'mkd', 'mlg':'mlg', \
#        'mon':'mon', 'mri':'mri', 'msa':'msa', 'mya':'mya', 'nap':'nap', 'nds':'nds', 'nep':'nep', 'new':'new', 'nld':'nld', \
#        'nno':'nno', 'nor':'nor', 'oci':'oci', 'oss':'oss', 'pam':'pam', 'pms':'pms', 'pnb':'pnb', 'pol':'pol', 'por':'por', \
#        'que':'que', 'ron':'ron', 'rus':'rus', 'sah':'sah', 'scn':'scn', 'sco':'sco', 'slk':'slk', 'slv':'slv', 'spa':'spa', \
#        'sqi':'sqi', 'srp':'srp', 'sun':'sun', 'swa':'swa', 'swe':'swe', 'tam':'tam', 'tat':'tat', 'tel':'tel', 'tgk':'tgk', \
#        'tgl':'tgl', 'tha':'tha', 'tur':'tur', 'ukr':'ukr', 'urd':'urd', 'uzb':'uzb', 'vec':'vec', 'vie':'vie', 'vol':'vol', \
#        'war':'war', 'wln':'wln', 'yid':'yid', 'yor':'yor', 'zho':'zho'}
#__W2cTestCorpusDic = {'hrv':'hrv'}
__digitPatt = regex.compile(r'[0-9]*',re.UNICODE)
'''
return {'c7':{10000:{'sv-ud11':0.8},...},....}
'''
def test():
    #traintokenCnt = [20000000]
    #testtokenCnt = [500000,1000000,5000000,10000000,20000000]
    #testtokenCnt = [5000000]
    trainFeatDic = dict()
    #c7 = set(['bg','ca','de','el','hu','tr','hi'])
    #for totaltoken  in traintokenCnt:
    #c7Feature = []
    #c7Label = []
    #c7Word = []
    #trainFeatDic[totaltoken] = dict()
    #for trainlangKey in __W2cTrainCorpusDic:
    trainfilepath = sys.argv[1]
    #'../feature/train/' + trainlangKey + '/' + str(totaltoken) + '.txt'
    trainFeatDic = dict()
    trainFeatDic['feature'] = []
    trainFeatDic['wordform'] = []
    trainFeatDic['label'] = []
    for line in open(trainfilepath):
        feat = json.loads(line.strip())
        trainFeatDic['feature'].append(feat['feature'])
        trainFeatDic['wordform'].append(feat['wordform'])
        trainFeatDic['label'].append(feat['label'])
        #    if trainlangKey in c7:
        #        c7Feature.append(feat['feature'])
        #        c7Label.append(feat['label'])
        #        c7Word.append(feat['wordform'])
    #trainFeatDic[totaltoken]['c7'] = dict()
    #trainFeatDic[totaltoken]['c7']['feature'] = c7Feature
    #trainFeatDic[totaltoken]['c7']['wordform'] = c7Word
    #trainFeatDic[totaltoken]['c7']['label'] = c7Label

    #testFeatDic = dict()
    #for totaltoken in testtokenCnt:
    #    testFeatDic[totaltoken] = dict()
    #    for testlangKey in __W2cTestCorpusDic:
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
    #for traintotaltoken in trainFeatDic:
    #fb = open(sys.argv[3],'w')
    #for trainlangKey in trainFeatDic[traintotaltoken]:
    print 'Training SVM model'
    correctDic = dict()
    #correctDic[trainlangKey] = dict()
    trainX = np.array(trainFeatDic['feature'])[:,:17]
    trainY = trainFeatDic['label']
    scaler = preprocessing.StandardScaler().fit(trainX)
    trainX_scaled = scaler.transform(np.array(trainX))
    clf = svm.SVC()
    clf.fit(trainX_scaled,trainY)
    print 'SVM model trained succesfully'
    #for testtotaltoken in testFeatDic:
    predictYDic = dict()
    #for testlangKey in testFeatDic[testtotaltoken]:
    testX = np.array(testFeatDic['feature'])[:,:17]
    testY = testFeatDic['label']
    testX_scaled = scaler.transform(testX)
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
    oovfile = sys.argv[1] + '.oov'
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
    #predictYDic[testlangKey] = (correctCnt + oovcorrectcnt) / ((len(testY) + oovtotalcnt) * 1.0)
#correctDic = predictYDic
        #fb.write(json.dumps(correctDic,ensure_ascii=False)+'\n')
        #fb.flush()
    #fb.close()


if __name__ == '__main__':
    test()


