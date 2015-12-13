from shutil import copy
from os import listdir

src = "/Users/kevin/Downloads/wikiteam-master/splatoonwikiorg_w-20151212-wikidump/images"
dest = "/Users/kevin/Documents/github/SplatPal/SplatPal/Images/gear/"
images = [f for f in listdir(src)]

for f in images:
	if f[-3:] == "png" and not "Beta" in f:
		if "Geart Shoes" in f:
			copy(src + "/" + f, dest + f[12:])
		if "Geart Clothing" in f or "Geart Headgear" in f:
			copy(src + "/" + f, dest + f[15:])