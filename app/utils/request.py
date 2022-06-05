import requests
import json
import utils

def getdata():
    url = utils.get_env()['waterheater_url'] + "/cm?cmnd="
    url = url + "goeStatus"
    r = requests.get(url)
    return r

def setdata(data):
    # print(data)
    url = utils.get_env()['waterheater_url'] + "/cm?cmnd="
    headers = {'Content-Type': 'application/json'}
    url = url + "goeWrite?"
    for i in data:
        url = url + i + "=" + data[i] 
    print(url)
    r = requests.get(url, headers=headers)
    return r

        