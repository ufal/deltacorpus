#!/usr/bin/python
# -*- coding: utf-8 -*-
import sys
import gzip
import os
import regex
import re
import json
import math
import extract_token as ext
reload(sys)
sys.setdefaultencoding('utf-8')


__W2cTrainCorpus = {'bg':'bul', 'ca':'cat', 'cs':'ces','de':'deu', \
        'el':'ell', 'en':'eng' ,'hu':'hun','it':'ita' ,'pt':'por',\
        'ru':'rus' ,'sv':'swe', 'tr':'tur','hi':'hin'}
__W2cTestCorpus = {'bg':'bul', 'bn':'ben', 'ca':'cat', 'cs':'ces', \
        'da':'dan', 'de':'deu', 'el':'ell', 'es':'spa', \
        'en':'eng', 'et':'est','eu':'eus', 'fa':'fas', 'fi':'fin',\
        'hi':'hin','hu':'hun', 'it':'ita', 'la':'lat', 'nl':'nld',\
        'pt':'por', 'ro':'ron' ,'ru':'rus','sk':'slk', 'sl':'slv',\
        'sv':'swe', 'te':'tel','tr':'tur'}
__PunctuationPattern = re.compile(r"[^\s\w]+",re.UNICODE)#punctuation regex
__base = math.pow(10,-1)

def __getWordInfomationFromCorpus(corpusFile, wordPosLis, wordSet, TotalToken):
    # data struct for word\tpos
    CurWordCount = dict()
    PrevWordCount = dict()
    NextWordCount = dict()
    PreNextCount = dict()

    #data struct for corpus
    MiddleWordCount = dict()
    MiddleWordTotalCount = dict()
    WordCountInCorpus = dict()
    rootSuffixCount = dict()
    rootCount = dict()
    suffixCount = dict()

    totalToken = 0 
    for line in gzip.open(corpusFile):
        lis = regex.findall(r'[^\s\w]+|\w+',line.decode('utf-8'), re.UNICODE)# tokenize one line/
        totalToken += len(lis)
        if totalToken > TotalToken:
            break
        lastindexoflis = len(lis) - 1
        for curindex,word in enumerate(lis):#type(word)==unicode
            preword = None
            nextword = None
            prenext = None
            if 0 != curindex :
                preword = lis[curindex - 1]
            if lastindexoflis != curindex:
                nextword = lis[curindex + 1]
            if None != preword and None != nextword:
                prenext = preword + nextword
                if prenext not in MiddleWordCount:
                    MiddleWordCount[prenext] = dict()
                    MiddleWordCount[prenext][word] = 1
                else:
                    MiddleWordCount[prenext][word] = MiddleWordCount[prenext].get(word, 0) + 1
                MiddleWordTotalCount[prenext] = MiddleWordTotalCount.get(prenext, 0) + 1
            WordCountInCorpus[word] = WordCountInCorpus.get(word,0) + 1
            for suffixLen in range(1,4):
                root = word[:-1*suffixLen]
                suffix = word[-1*suffixLen:]
                if len(root) > 3:
                    if root not in rootSuffixCount:
                        rootSuffixCount[root] = dict()
                        rootSuffixCount[root][suffix] = 1
                    else:
                        rootSuffixCount[root][suffix] = rootSuffixCount[root].get(suffix,0) + 1
                    rootCount[root] = rootCount.get(root,0) + 1
                    suffixCount[suffix] = suffixCount.get(suffix,0) + 1

            if word in wordSet:
                CurWordCount[word] = CurWordCount.get(word,0) + 1
                if word not in PrevWordCount:
                    PrevWordCount[word] = dict()
                if word not in NextWordCount:
                    NextWordCount[word] = dict()
                if word not in PreNextCount:
                    PreNextCount[word] = dict()
                
                if None != preword:                   
                    PrevWordCount[word][preword] = PrevWordCount[word].get(preword, 0) + 1
                if None != nextword:
                    NextWordCount[word][nextword] = NextWordCount[word].get(nextword, 0) + 1
                if None != prenext:
                    PreNextCount[word][prenext] = PreNextCount[word].get(prenext, 0) + 1

    return CurWordCount,PrevWordCount,NextWordCount,PreNextCount,MiddleWordCount,\
            MiddleWordTotalCount,WordCountInCorpus,rootSuffixCount,rootCount,suffixCount,totalToken


def __CalculateWordFrequencyAfterNumberAndPunctuation(PrevWordCount,totalCount):
    wordAfNum = 0
    wordAfPunc = 0
    for wordkey in PrevWordCount:
        if __PunctuationPattern.match(wordkey):
            wordAfPunc += PrevWordCount[wordkey]
        if wordkey.isdigit():
            wordAfNum += PrevWordCount[wordkey]

    return math.log(((wordAfNum) + __base) / (totalCount * 1.0) ,2),\
            math.log(((wordAfPunc) + __base)  / (totalCount * 1.0),2)


def __CalculateEntropy(wordInfo,totalCount):
    Ent = 0
    for wordkey in wordInfo:
        partialEnt = wordInfo[wordkey] / (totalCount * 1.0)
        Ent += partialEnt * math.log(partialEnt, 2)
    return (Ent * -1.0)


def __CalculateSameContextWord(PreNextCount,MiddleWordCount,MiddleWordTotalCount,CurWordCount):
    sameContextWord = dict()
    diffSet = set()
    totalcount = 0
    for prenext in PreNextCount:
        for word in MiddleWordCount[prenext]:
            sameContextWord[word] =  sameContextWord.get(word,0) + MiddleWordCount[prenext][word]
            diffSet.add(word)
        totalcount += MiddleWordTotalCount[prenext]
    if 1 >= len(diffSet):
        return 0,0
    return __CalculateEntropy(sameContextWord,totalcount),math.log(len(diffSet) /(CurWordCount * 1.0), 2)


def __CalculateMutualInfomation(PreOrNextDic,CurWordCount,WordCountInCorpus,totalToken):
    MI = 0
    maxPointWiseCount = 0
    maxPointWiseWord = None
    for preOrNexrWord in PreOrNextDic:
        MI += PreOrNextDic[preOrNexrWord] * (math.log(totalToken * PreOrNextDic[preOrNexrWord],2)\
                - math.log(CurWordCount * WordCountInCorpus[preOrNexrWord],2))
        if maxPointWiseCount < PreOrNextDic[preOrNexrWord]:
            maxPointWiseCount = PreOrNextDic[preOrNexrWord]
            maxPointWiseWord = preOrNexrWord
    if None == maxPointWiseWord:
        return 0,0
    return MI / (totalToken * 1.0),math.log((totalToken * maxPointWiseCount) / \
            (CurWordCount * WordCountInCorpus[maxPointWiseWord] * 1.0), 2)

def __CalculateSuffixEntropy(curWord,rootSuffixCount,rootCount,suffixCount):
    bestScore = 0
    bestSuffixLen = 0
    bestRoot = None
    for suffixLen in range(1,4):
        root = curWord[:-1*suffixLen]
        suffix = curWord[-1*suffixLen:]
        if root not in rootCount or suffix not in suffixCount:
            continue
        tmpscore = rootCount[root] * suffixCount[suffix]
        if tmpscore > bestScore and len(root) > 3:
            bestScore = tmpscore
            bestSuffixLen = suffixLen
            bestRoot = root
    if None == bestRoot:
        return 0
    return __CalculateEntropy(rootSuffixCount[bestRoot],rootCount[bestRoot])

def __generateFeatureVectorFromW2C(CurWordCount,PrevWordCount,NextWordCount,PreNextCount,\
        MiddleWordCount,MiddleWordTotalCount,wordPosLis,WordCountInCorpus,rootSuffixCount,\
        rootCount,suffixCount,totalToken,targetFeatFile):

    fb = open(targetFeatFile,'w')
    FeatureDic = dict()
    OutOfVocal = []
    for wordindex , wordpos in enumerate(wordPosLis):
        splitWordPos = wordpos.strip().split('\t')
        word, pos = splitWordPos[0].decode('utf-8'), splitWordPos[1]
        if word not in CurWordCount:#word not appear in the w2c,just pass
	    OutOfVocal.append(wordpos + '\t' + str(wordindex))
            continue
        if word in FeatureDic:
            FeatureDic[word]['label'] = pos # one word could have multiple label
            FeatureDic[word]['index'] = wordindex
            fb.write(json.dumps(FeatureDic[word],ensure_ascii=False)+'\n')
            fb.flush()
            
            continue
        # feature used by david
        wordlen = len(word)
        wordfreq = math.log(CurWordCount[word] / (totalToken * 1.0),2)
        predwordEnt = __CalculateEntropy(PrevWordCount[word],CurWordCount[word])
        nextwordEnt = __CalculateEntropy(NextWordCount[word],CurWordCount[word]) 
        subWordEnt,log_sameContextWordCount = __CalculateSameContextWord(\
                PreNextCount[word],MiddleWordCount,MiddleWordTotalCount,CurWordCount[word])
        isnum = int(word.isdigit())
        ispunc = int(None != __PunctuationPattern.match(word))
        wordfreqafternum,wordfreqafterpunc = __CalculateWordFrequencyAfterNumberAndPunctuation(\
                PrevWordCount[word],CurWordCount[word])
        #new feature by me
        MIWithPreviousWord,maxPrePointWiseMI = __CalculateMutualInfomation(PrevWordCount[word],\
                WordCountInCorpus[word],WordCountInCorpus,totalToken)

        MIWithNextWord,maxNextPointWiseMI = __CalculateMutualInfomation(NextWordCount[word],\
                WordCountInCorpus[word],WordCountInCorpus,totalToken)
        suffixEntropy = __CalculateSuffixEntropy(word,rootSuffixCount,rootCount,suffixCount)
        log_prewordcount = math.log((len(PrevWordCount[word]) + __base) / (WordCountInCorpus[word] * 1.0), 2)
        log_nextwordcount = math.log((len(NextWordCount[word]) + __base) / (WordCountInCorpus[word] * 1.0), 2)

        tmpX = [wordlen,wordfreq,predwordEnt,nextwordEnt,subWordEnt,isnum,ispunc,wordfreqafternum,wordfreqafterpunc,\
                MIWithPreviousWord,MIWithNextWord,suffixEntropy,log_prewordcount,log_nextwordcount,log_sameContextWordCount,
                maxPrePointWiseMI,maxNextPointWiseMI,wordfreq + log_prewordcount,wordfreq + log_nextwordcount,\
                wordfreq + log_sameContextWordCount]
        tmpfeatdic = dict()
        tmpfeatdic['wordform'] = word
        tmpfeatdic['feature'] = tmpX
        tmpfeatdic['label'] = pos
        tmpfeatdic['index'] = wordindex
        FeatureDic[word] = tmpfeatdic
        fb.write(json.dumps(tmpfeatdic,ensure_ascii=False)+'\n')
        fb.flush()
        del tmpfeatdic
    fb.close()
    return OutOfVocal


def __getTrainFeatureVector(trainCorpusFile,targetFeatFile,language,TotalLine):
    trainWordSet, trainLangLis = ext.extractTrainToken(language)
    CurWordCount,PrevWordCount,NextWordCount,PreNextCount,MiddleWordCount,\
            MiddleWordTotalCount,WordCountInCorpus,rootSuffixCount,rootCount,suffixCount,\
            trainTotalToken = __getWordInfomationFromCorpus(trainCorpusFile,\
            trainLangLis,trainWordSet, TotalLine)
    print 'total token from w2c to calculate feature',trainTotalToken
    __generateFeatureVectorFromW2C(CurWordCount,PrevWordCount,NextWordCount,\
            PreNextCount,MiddleWordCount,MiddleWordTotalCount,trainLangLis,WordCountInCorpus,\
            rootSuffixCount,rootCount,suffixCount,trainTotalToken,targetFeatFile)


def __getTestFeatureVector(testCorpusFile,targetFeatFile,language,TotalLine,targetFeatDir):
    testWordSet, testLangLis = ext.extractTestToken(language)
    CurWordCount,PrevWordCount,NextWordCount,PreNextCount,MiddleWordCount,\
            MiddleWordTotalCount,WordCountInCorpus,rootSuffixCount,rootCount,suffixCount,\
            testTotalToken = __getWordInfomationFromCorpus(testCorpusFile,\
            testLangLis,testWordSet, TotalLine)
    print 'total token from w2c to calculate feature', testTotalToken
    OutOfVocal = __generateFeatureVectorFromW2C(CurWordCount,PrevWordCount,NextWordCount,\
            PreNextCount,MiddleWordCount,MiddleWordTotalCount,testLangLis,WordCountInCorpus,\
            rootSuffixCount,rootCount,suffixCount,testTotalToken,targetFeatFile)
    OutOfVocalFile = targetFeatDir + '/' + str(TotalLine) +'_oov.txt'
    fb = open(OutOfVocalFile,'w')
    for wordpos in OutOfVocal:
        fb.write(wordpos+'\n')
        fb.flush()
    fb.close()




def writeTestfeatToFile():# write the test feature to a local file
    testTotalToken = [500000,1000000,5000000,10000000,20000000]
    for token in testTotalToken:
        for languageKey in __W2cTestCorpus:
            testCorpusFile = '../../w2c/' + __W2cTestCorpus[languageKey] + '.gz'
            targetFeatDir = '../feature/test/' + languageKey#target test feature file
            if os.path.exists(targetFeatDir) :
                targetFeatFile = targetFeatDir +  '/' + str(token) + '.txt'
                #if os.path.exists(targetFeatFile):
                #    print 'exists'
                #    continue
                __getTestFeatureVector(testCorpusFile,targetFeatFile,languageKey,token,targetFeatDir)
            else:
                os.makedirs(targetFeatDir)
                targetFeatFile  = targetFeatDir + '/' + str(token) + '.txt'
                __getTestFeatureVector(testCorpusFile, targetFeatFile,languageKey,token,targetFeatDir)

def writeTrainfeatToFile():#write the training feature to a local file
    trainTotalToken = [20000000]
    for token in trainTotalToken:
        for languageKey in __W2cTrainCorpus:
            trainCorpusFile = '../../w2c/' + __W2cTrainCorpus[languageKey] + '.gz'
            targetFeatDir = '../feature/train/' + languageKey#target train feature dir
            if os.path.exists(targetFeatDir):
                targetFeatFile = targetFeatDir +  '/' + str(token) + '.txt'
                #if os.path.exists(targetFeatFile):
                #    continue
                #__getTrainFeatureVector(trainCorpusFile,targetFeatFile,languageKey,token)
            else:
                os.makedirs(targetFeatDir)
                targetFeatFile  = targetFeatDir + '/' + str(token) + '.txt'
                __getTrainFeatureVector(trainCorpusFile, targetFeatFile,languageKey,token)
if __name__=='__main__':
    writeTestfeatToFile()#calculate test feature
    #print 'test  done'
    writeTrainfeatToFile()#calculate train feature
    #print 'train done'
