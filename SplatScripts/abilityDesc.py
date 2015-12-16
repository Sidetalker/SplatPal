import json

src = '/Users/kevin/Downloads/wikiteam-master/splatoonwikiorg_w-20151212-wikidump/splatoonwikiorg_w-20151212-current.xml'
prp = '{http://www.mediawiki.org/xml/export-0.10/}'

data = {}

with open('abilities.txt', 'rb') as f:
	counter = 0
	for line in f:
		if counter % 2 == 0:
			name = line
		else:
			data[name] = line
		counter += 1

abilityData = {}
abilityData["abilities"] = data

with open('abilityData.json', 'w') as f:
    json.dump(abilityData, f)