#!/usr/bin/python
# -*- coding: utf-8 -*-
import sys
import gzip
import os
reload(sys)
sys.setdefaultencoding('utf-8')

def writefile(filename,objfile):
    obj = open(objfile,'a+')
    for line in gzip.open(filename):
        if '\n' == line:
            obj.write('\n')
            continue
        lis = line.strip().split('\t')
        if len(lis) <= 1:
            continue
        string = lis[1] + '\t' + lis[3] + '\n'
        obj.write(string)
    obj.close()
def deletefile(startdir) :
    os.chdir(startdir)
    for obj in os.listdir(os.curdir) :
        if os.path.isdir(obj) :
            if 'treex' in obj:
                continue
            deletefile(obj)
            os.chdir(os.pardir) #!!!
        if os.path.isfile(obj):
            if '.txt' in obj:
                os.system("rm " + obj)

def scandir(startdir) :
    os.chdir(startdir)
    for obj in os.listdir(os.curdir) :
        if os.path.isdir(obj) :
            if 'treex' in obj:
                continue
            scandir(obj)
            os.chdir(os.pardir) #!!!
        if os.path.isfile(obj):
            if '.gz' not in obj:
                continue
            objfile = os.getcwd() + '/' + os.getcwd().split('/')[-1] + '.txt'
            writefile(os.getcwd() + '/' + obj, objfile)

if __name__=='__main__':
    startdir = os.getcwd() + '../../hamledt3.0/'
    for obj in os.listdir(startdir):
        if os.path.isdir(startdir + obj):
            #deletefile(startdir + obj)
            #scandir(startdir + obj)
