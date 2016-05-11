from prettytable import PrettyTable
import json
import sys
import numpy as np
col_name = ['bg', 'ca', 'cs','de', \
        'el', 'en','hi','hu','it','pt',\
        'ru','sv', 'tr','avg','avgImpro','c7','c7Improved']
row_name = ['bg', 'bn', 'ca', 'cs', \
        'da', 'de', 'el', 'es', \
        'en', 'et','eu', 'fa', 'fi',\
        'hi','hu', 'it', 'la', 'nl',\
        'pt', 'ro','ru','sk', 'sl',\
        'sv', 'te','tr']
davidAvgAccuracy = ['50','36','49','53','52','53','47','53','51','47','42','44','39','41','43','56','35',\
        '53','51','47','36','49','50','48','39','34']
davidC7Accuracy = ['79','55','83','60','58','84','80','69','56','56','57','58','45','88','76','66','44',\
        '65','67','55','40','54','53','59','53','60']
__c7 = ['bg','ca','de','el','hi','hu','tr']
if len(sys.argv) < 3:
    print ' argv[1] for result file,argv[2] for total token'
    exit()
first_raw =  ['test_lang']
first_raw.extend(col_name)
x = PrettyTable(first_raw)
x.align['test_lang'] = 'l'
x.padding_width = 1 
relDic = dict()
for line in open(sys.argv[1]):
    js = json.loads(line.strip())
    trainlangKey = js.keys()[0]
    relDic[trainlangKey] = js[trainlangKey][sys.argv[2]]
matrix = np.zeros((len(row_name),len(col_name)))
for trainKey in relDic:
    rel = relDic[trainKey]
    for testKey in rel:
        matrix[row_name.index(testKey)][col_name.index(trainKey)] = rel[testKey]*100
totalImproved = 0 
totalImprovedavg = 0
for testLang in row_name:
    tmprow = [testLang]
    if testLang not in col_name:
        matrix[row_name.index(testLang)][col_name.index('avg')] = \
        (sum(matrix[row_name.index(testLang)]) -
        matrix[row_name.index(testLang)][col_name.index('c7')])/(13*1.0)

    else:
        matrix[row_name.index(testLang)][col_name.index('avg')] = \
        (sum(matrix[row_name.index(testLang)]) -
        matrix[row_name.index(testLang)][col_name.index('c7')] -
        matrix[row_name.index(testLang)][col_name.index(testLang)])/(12*1.0)

    matrix[row_name.index(testLang)][col_name.index('avgImpro')] =\
    (matrix[row_name.index(testLang)][col_name.index('avg')] - float(davidAvgAccuracy[row_name.index(testLang)]))
    if testLang not in __c7:
        matrix[row_name.index(testLang)][col_name.index('c7Improved')] =\
        (matrix[row_name.index(testLang)][col_name.index('c7')] - float(davidC7Accuracy[row_name.index(testLang)]))
        totalImproved += matrix[row_name.index(testLang)][col_name.index('c7Improved')]
    else:
        matrix[row_name.index(testLang)][col_name.index('c7Improved')] =\
        (matrix[row_name.index(testLang)][col_name.index('c7')] - float(davidC7Accuracy[row_name.index(testLang)]))
    totalImprovedavg += matrix[row_name.index(testLang)][col_name.index('avgImpro')]
    value = []
    for index,precision in enumerate(matrix[row_name.index(testLang)]):
        if testLang not in __c7:
            value.append('%.1f' % precision)
        else:
            #if index == 16:
            #    value.append(int(precision))
            #else:
            value.append('%.1f' % precision)
    #value = ['%.1f' % float(i) for i in matrix[row_name.index(testLang)]]
    tmprow.extend(value)
    x.add_row(tmprow)
print x
print 'average imrovement  for the each test language ', ('%.1f' % (totalImprovedavg / ( 26 * 1.0)))
print 'average totalImproved for the language not in c7',('%.1f' % (totalImproved / ( 19 * 1.0)))
