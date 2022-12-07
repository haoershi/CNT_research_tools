"""
A simple test script to check if config file works properly
"""

import os
import pandas as pd
from ieeg.auth import Session
work_path = os.getcwd() # get current path
test_path = os.path.join(work_path,"python/test")
file_path = os.path.join(work_path,"python")

assert os.path.exists(os.path.join(file_path,'config.json'))

with open("python/config.json", 'rb') as f:
    config = pd.read_json(f, typ='series')

assert os.path.exists(os.path.join(work_path,config.pwd))

pwd = open(config.pwd, 'r').read()

s = Session(config.usr, pwd)
