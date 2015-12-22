import pickle
from shutil import copy
from os import listdir

src = '/Users/kevin/Downloads/wikiteam-master/splatoonwikiorg_w-20151212-wikidump/images'
destA = '/Users/kevin/Documents/github/SplatPal/SplatPal/Images/weapons/'
destB = '/Users/kevin/Documents/github/SplatPal/SplatPal/Images/specials/'
images = [f for f in listdir(src)]
resultTextA = []
resultTextB = []

for f in images:
	if f[-3:] == 'png' and not 'Beta' in f:
		if 'Weapont Main' in f:
			resultTextA.append(f[13:][:-4])
			copy(src + '/' + f, destA + 'weapon' + f[12:].replace(' ', ''))
		if 'Weapon Special' in f:
			resultTextB.append(f[15:][:-4])
			copy(src + '/' + f, destB + 'special' + f[15:].replace(' ', ''))

with open('weaponNames.dat', 'wb') as f:
	pickle.dump(resultTextA, f)
with open('specialNames.dat', 'wb') as f:
	pickle.dump(resultTextB, f)