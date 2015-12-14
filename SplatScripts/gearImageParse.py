import pickle
from shutil import copy
from os import listdir

src = '/Users/kevin/Downloads/wikiteam-master/splatoonwikiorg_w-20151212-wikidump/images'
dest = '/Users/kevin/Documents/github/SplatPal/SplatPal/Images/gear/'
images = [f for f in listdir(src)]
resultText = []

for f in images:
	if f[-3:] == 'png' and not 'Beta' in f:
		if 'Geart Shoes' in f:
			resultText.append(f[12:][:-4])
			copy(src + '/' + f, dest + 'gear' + f[12:].replace(' ', ''))
		if 'Geart Clothing' in f or 'Geart Headgear' in f:
			resultText.append(f[15:][:-4])
			copy(src + '/' + f, dest + 'gear' + f[15:].replace(' ', ''))

with open('gearNames.dat', 'wb') as f:
	pickle.dump(resultText, f)