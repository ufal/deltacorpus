#!/usr/bin/python
# -*- coding: utf-8 -*-
import sys
import gzip
import json
import os
reload(sys)
sys.setdefaultencoding('utf-8')

trainLanguage = ['bg', 'ca', 'cs', 'de', 'el', 'en', 'hi' ,'hu',\
        'it' ,'pt' ,'ru' , 'sv', 'tr']
testLanguage = ['bg', 'bn', 'ca', 'cs', 'da', 'de', 'el', 'es', 'en', 'et',\
        'eu', 'fa', 'fi', 'hi', 'hu', 'it', 'la', 'nl', 'pt', 'ro' ,'ru',\
        'sk', 'sl', 'sv', 'te','tr']
__W2cTrainCorpusDic = {'bg':'bul', 'ca':'cat', 'cs':'ces','de':'deu', \
        'el':'ell', 'en':'eng' ,'hu':'hun','it':'ita' ,'pt':'por',\
        'ru':'rus' ,'sv':'swe', 'tr':'tur','hi':'hin'}
__W2cTestCorpusDic = {'bg':'bul', 'bn':'ben', 'ca':'cat', 'cs':'ces', \
        'da':'dan', 'de':'deu', 'el':'ell', 'es':'spa', \
        'en':'eng', 'et':'est','eu':'eus', 'fa':'fas', 'fi':'fin',\
        'hi':'hin','hu':'hun', 'it':'ita', 'la':'lat', 'nl':'nld',\
        'pt':'por', 'ro':'ron' ,'ru':'rus','sk':'slk', 'sl':'slv',\
        'sv':'swe', 'te':'tel','tr':'tur'}
def genWordDic(langLis):
    wordSet = set()
    for token in langLis:
        wordSet.add(token.split('\t')[0].decode('utf-8'))
    return wordSet


def extractTrainToken(language,tokenCount=50000):#default value
    if not isinstance(tokenCount, int):
        return None
    if tokenCount <= 0:
        return None
    langLis = []
    count = 0
    trainFilePath =  '../../data/train/' + language +'.txt'
    for line in open(trainFilePath):
        if line == '\n':
            continue
        if count >= tokenCount:
            break
        tmplis = line.strip().split('\t')
        if '.'==tmplis[3]:
            tmplis[3] = 'PUNC'
        langLis.append(tmplis[1]+'\t'+tmplis[3])
        count = count + 1
    return genWordDic(langLis),langLis
        
def extractTestToken(language,tokenCount=1000):#1000 == tokenCount
    if not isinstance(tokenCount, int):
        return None
    if tokenCount <= 0:
        return None
    langLis = []
    count = 0
    testFilePath = '../../data/test/' + language + '.txt'
    for line in open(testFilePath):
        if line == '\n':
            continue
        if count >= tokenCount:
            break
        tmplis = line.strip().split('\t')
        if '.'==tmplis[3]:
            tmplis[3] = 'PUNC'
        langLis.append(tmplis[1]+'\t'+tmplis[3])
        count = count + 1
    return genWordDic(langLis),langLis


def calculteTagConfidenceUnderLocalTagContxt(language,tokenCount):
    tagLis = ['#']
    count = 0
    trainFilePath =  '../../data/train/' + language +'.txt'
    for line in open(trainFilePath):
        if line == '\n':
            tagLis.append('#')
            continue
        if count >= tokenCount:
            break
        tmplis = line.strip().split('\t')
        if '.'==tmplis[3]:
            tmplis[3] = 'PUNC'
        tagLis.append(tmplis[3])
        count = count + 1
    tagLis.append('#')
    tagContextDic =dict()
    ContextTagDic = dict()
    for index in range(1,len(tagLis)-1):
        context = tagLis[index-1] + '_' + tagLis[index+1]
        if '#' in tagLis[index] or '#' in context:
            continue
        if context not in ContextTagDic:
            ContextTagDic[context] = dict()
            ContextTagDic[context][tagLis[index]] = 1
        else:
            ContextTagDic[context][tagLis[index]] = ContextTagDic[context].get(tagLis[index],0) + 1

        if tagLis[index] not in tagContextDic:
            tagContextDic[tagLis[index]] = dict()
            tagContextDic[tagLis[index]][context] = 1
            tagContextDic[tagLis[index]]['totalcount'] = 1
        else:
            tagContextDic[tagLis[index]][context] = tagContextDic[tagLis[index]].get(context,0) + 1
            tagContextDic[tagLis[index]]['totalcount'] += 1

    for key in tagContextDic:
        for context in tagContextDic[key]:
            if 'totalcount' in context:
                continue
            precision =  tagContextDic[key][context] / (tagContextDic[key]['totalcount'] * 1.0)
            if precision > 0.1:
                print precision,key,context
            
    return tagContextDic,ContextTagDic
'''
parameter means that how many tokens you want to get from the w2c
for a text like:
I love you.
I'm yzw....
it write  a dict like {'en':[[u'I',u'love',u'you',u'.'],[u'I','\'',u'm',u'yzw',u'....']]} 
to a file  ,each line contains tokenized words for one language
'''
def __getTrainCorpus(lineCount):
    if not isinstance(lineCount, int):
        return None
    for languageKey in __W2cTrainCorpusDic.keys():  
        w2cFilepath = '/net/data/W2C/W2C_WEB/2011-08/' + __W2cTrainCorpusDic[languageKey] + '.txt.gz'
        targetFile = '../../data/train/' + __W2cTrainCorpusDic[languageKey] + '.gz'
        fb = open(targetFile,'wb')
        linecnt = 0
        for line in  gzip.open(w2cFilepath):
            if line == '\n':
                continue
            #lis = regex.findall(r"[^\s\w]+|\w+",line.decode('utf-8'),re.UNICODE)
            linecnt += 1
            if linecnt > lineCount:
                break
            fb.write(line)
            fb.flush()
        fb.close()


'''
parameter means that how many tokens you want to get from the w2c
for a text like:
I love you.
I'm yzw....
it write  a dict like {'en':[[u'I',u'love',u'you',u'.'],[u'I','\'',u'm',u'yzw',u'....']]} 
to a file  ,each line contains tokenized words for one language
'''
def __getTestCorpus(lineCount):
    if not isinstance(lineCount, int):
        return None
    for languageKey in __W2cTestCorpusDic.keys():  
        w2cFilepath = '/net/data/W2C/W2C_WEB/2011-08/' + __W2cTestCorpusDic[languageKey] + '.txt.gz'
        targetFile = '../../data/test/' + __W2cTestCorpusDic[languageKey] + '.gz'
        fb = open(targetFile,'wb')
        linecnt = 0
        for line in  gzip.open(w2cFilepath):
            if line == '\n':
                continue
            linecnt += 1
            if linecnt > lineCount:
                break
            fb.write(line)
            fb.flush()
        fb.close()


if __name__=='__main__':
    #fb = open('regexTestFile','w')
    #for language in  testLanguage:
    #    lis = extractTestToken(language,10)[1]
    #    fb.write(language + '--------\n')
    #    for wordpos in lis:
    #        fb.write(wordpos.split('\t')[0]+'\n')
    #fb.close()
    #dic,wordpos = extractTestToken('en',100)
    #print wordpos
    print calculteTagConfidenceUnderLocalTagContxt('hi',50000)
    #__getTestCorpus(1200000)
    #__getTrainCorpus(1200000)




