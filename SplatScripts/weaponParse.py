import pickle
import re
import json
import xml.etree.ElementTree as ET

src = '/Users/kevin/Downloads/wikiteam-master/splatoonwikiorg_w-20151212-wikidump/splatoonwikiorg_w-20151212-current.xml'
prp = '{http://www.mediawiki.org/xml/export-0.10/}'

with open('weaponNames.dat', 'rb') as f:
	weaponNames = pickle.load(f)

root = ET.parse(src).getroot()
data = []

for child in root:
	title = child.find(prp + 'title')
	if title is not None:
		if title.text in weaponNames:
			curWeapon = title.text
			weapon = {}
			weapon['name'] = curWeapon

			gearFull = child.find(prp + 'revision').find(prp + 'text').text
			reg = re.search('\{\{Infobox weapon([a]|[^a])*?(\n\}\}|\}\}\}\})', gearFull)

			if reg is not None:
				gearReg = reg.group()
			
				for line in gearReg.splitlines():
					if 'cost' in line:
						weapon['cost'] = line.split("= ", 1)[1]
						if 'explain' in weapon['cost']:
							weapon['cost'] = weapon['cost'].replace('{', '').replace('}', '').split("|", 2)[2]
					if 'base' in line:
						weapon['baseDmg'] = line.split("= ", 1)[1]
						if 'explain' in weapon['baseDmg']:
							weapon['baseDmg'] = weapon['baseDmg'].replace('{', '').replace('}', '').split("|", 2)[2]
					if 'level' in line:
						weapon['level'] = line.split("= ", 1)[1].split(" ", 1)[0]
					if 'range' in line:
						weapon['range'] = line.split("= ", 1)[1].split("|", 2)[1]
					if 'attack' in line:
						weapon['attack'] = line.split("= ", 1)[1].split("|", 2)[1]
					if 'fire' in line:
						weapon['fire'] = line.split("= ", 1)[1].split("|", 2)[1]
					if 'sub' in line:
						weapon['sub'] = line.split("= ", 1)[1].replace('[', '').replace(']', '')
					if 'nocharge' in line:
						weapon['nocharge'] = line.split("= ", 1)[1]
					if 'fullcharge' in line:
						weapon['fullcharge'] = line.split("= ", 1)[1]
					if 'special' in line:
						weapon['special'] = line.split("= ", 1)[1].replace('[', '').replace(']', '')
			else:
				print 'Failed to parse data for ' + curWeapon

			data.append(weapon)

allWeaponData = {}
allWeaponData["weapons"] = data

with open('weaponData.json', 'w') as f:
    json.dump(allWeaponData, f)
