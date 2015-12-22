import pickle
import re
import json
import xml.etree.ElementTree as ET

src = '/Users/kevin/Downloads/wikiteam-master/splatoonwikiorg_w-20151212-wikidump/splatoonwikiorg_w-20151212-current.xml'
prp = '{http://www.mediawiki.org/xml/export-0.10/}'

# with open('gearNames.dat', 'rb') as f:
# 	gearNames = pickle.load(f)

root = ET.parse(src).getroot()
data = []

for child in root:
	title = child.find(prp + 'title')
	if title is not None:
		print title.text 

		
# 		if title.text in gearNames:
# 			gear = {}
# 			gear['category'] = 'Missing'
# 			gear['brand'] = 'Missing'
# 			gear['ability'] = 'Missing'
# 			gear['rarity'] = 'Missing'
# 			gear['cost'] = 'Missing'

# 			curGear = title.text
# 			gearFull = child.find(prp + 'revision').find(prp + 'text').text
# 			reg = re.search('\{\{Infobox gear([a]|[^a])*?\}\}', gearFull)

# 			gear['name'] = curGear

# 			if reg is not None:
# 				gearReg = reg.group()
			
# 				for line in gearReg.splitlines():
# 					if line[:9] == '|category':
# 						gear['category'] = line.split("= ", 1)[1]
# 					if line[:6] == '|brand':
# 						gear['brand'] = line.split("= ", 1)[1]
# 					if line[:8] == '|ability':
# 						gear['ability'] = line.split("= ", 1)[1]
# 					if line[:7] == '|rarity':
# 						gear['rarity'] = line.split("= ", 1)[1]
# 					if line[:5] == '|cost':
# 						gear['cost'] = line.split("= ", 1)[1]
# 			else:
# 				print 'Failed to parse data for ' + curGear

# 			data.append(gear)

# allGearData = {}
# allGearData["gear"] = data

# with open('gearData.json', 'w') as f:
#     json.dump(allGearData, f)
