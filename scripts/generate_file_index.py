#!/usr/bin/python3
import json
from os import listdir
from os.path import isfile,join
import re

def strip_file(file_path):
    print(file_path)
    f = open(file_path,"r")
    content = f.read()
    # print(content)
    f.close()

    # print(re.sub('\n[\t]*<','<',re.sub('>\n[\t]*<','><',content)))

    f = open(file_path,"w")
    f.write(re.sub('\n[\t]*<','<',re.sub('>\n[\t]*<','><',content)))
    f.close()
    pass

if __name__ == "__main__":
    onlyfiles = [f for f in listdir("../xmls/3.0") if isfile(join("../xmls/3.0/",f))]
    for ver in listdir("../xmls"):
        if not isfile(join("../xmls",ver)) :
            print('parsing '+ver+' ...')
            files = [f for f in listdir(join("../xmls",ver)) if isfile(join("../xmls",ver,f))]
            files.sort()
            for json_file in files:
            	strip_file(join("../xmls",ver,json_file))
            files_json = json.dumps(files)
            f = open(join("../xmls","files_"+ver+".json"),"w")
            f.write(files_json)
            f.close()
