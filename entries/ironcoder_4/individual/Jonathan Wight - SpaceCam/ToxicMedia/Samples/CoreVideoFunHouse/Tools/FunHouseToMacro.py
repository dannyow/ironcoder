#!/usr/local/bin/python

import sys
import plistlib

def process(inPath):
	theFunhouse = plistlib.readPlist(inPath + '/file.xml')
	theLayers = theFunhouse['layers']
	theLayers = [theLayer for theLayer in theLayers if theLayer['type'] == 'filter']
	theOutput = file(inPath + '.cimacro', 'w')

	
	theOutput.write('<macro>\n')
	theOutput.write('\t<inputs>\n')
	theOutput.write('\t\t<image key="inputImage"/>\n')
	theOutput.write('\t</inputs>\n')
	theOutput.write('\t<outputs>\n')
	theOutput.write('\t\t<image key="outputImage" ref="FILTER_%d.outputImage"/>\n' % len(theLayers))
	theOutput.write('\t</outputs>\n')
	theOutput.write('\t<filters>\n')
	
	N = 1
	for theLayer in theLayers:
		theOutput.write('\t\t<filter key="FILTER_%d" cifiltername="%s">\n' % (N, theLayer['classname']))
		theOutput.write('\t\t\t<inputs>\n')
		if N == 1:
			theOutput.write('\t\t\t\t<image key="inputImage" ref="inputImage"/>\n')
		else:
			theOutput.write('\t\t\t\t<image key="inputImage" ref="FILTER_%d.outputImage"/>\n' % (N - 1))
	
		for theKey in theLayer['values']:
			theValue = theLayer['values'][theKey]
			theComponents = theKey.split('_')
			theKey = theComponents[0]
			theType = 'float'
			if len(theComponents) > 1:
				theType = theComponents[1]
			if theType == 'CIVectorValue':
				theValues = theValue[1:-1].split(' ')
				theOutput.write('\t\t\t\t<vector key="%s">\n' % theKey)
				for theValue in theValues:
					theOutput.write('\t\t\t\t\t<float>%s</float>\n' % theValue)
				theOutput.write('\t\t\t\t</vector>\n')
			elif theType == 'CIColorValue':
				theValues = theValue.split(' ')
				theOutput.write('\t\t\t\t<color key="%s">\n' % theKey)
				theOutput.write('\t\t\t\t\t<float key="red">%s</float>\n' % theValues[0])
				theOutput.write('\t\t\t\t\t<float key="green">%s</float>\n' % theValues[1])
				theOutput.write('\t\t\t\t\t<float key="blue">%s</float>\n' % theValues[2])
				theOutput.write('\t\t\t\t\t<float key="alpha">%s</float>\n' % theValues[3])
				theOutput.write('\t\t\t\t</color>\n')
			else:
				theOutput.write('\t\t\t\t<%s key="%s">%s</%s>\n' % (theType, theKey, theValue, theType))
			
	
		theOutput.write('\t\t\t</inputs>\n')
		theOutput.write('\t\t</filter>\n')
		N += 1
	theOutput.write('\t</filters>\n')
	theOutput.write('</macro>\n')

for theArg in sys.argv[1:]:
	process(theArg)