#%%
'''
This function provides a test case of pulling iEEG data
'''
# pylint: disable-msg=C0103
# pylint: disable-msg=C0301
#%%
# Imports
import pandas as pd
import numpy as np
import pytest
import os
import sys
work_path = os.getcwd() # get current path
test_path = os.path.join(work_path,"python/test")
file_path = os.path.join(work_path,"python")
#print(os.getcwd())
#os.chdir(work_path)
#par_folder = os.path.dirname(work_path)
sys.path.append(file_path)

import tools

# %%
# unit test for get_iEEG_data function
# write in a csv file all tests, col 0 filename, col 1 start in sec, col 2 stop in sec, col 4 electrodes
# metadata should contain all correct info for reference, maybe fetch later
# do not test electrodes temporarily
def test_getdata():
    with open(os.path.join("python/config.json"), 'rb') as f:
        config = pd.read_json(f, typ='series')

    meta_data = pd.read_csv(os.path.join(test_path,'metadata.csv'))
    test_input = pd.read_csv(os.path.join(test_path,'testinput.csv'))
    for _i in test_input.shape[0]:
        assert test_input.iloc[_i,0] in list(meta_data['filename'])
        assert test_input.iloc[_i,1] < test_input.iloc[_i,2]
        data,fs = tools.get_iEEG_data(config.usr,config.pwd,test_input.iloc[0,0],test_input.iloc[0,1]*1e6,test_input.iloc[0,2]*1e6)
        assert data.shape[0] == fs*(test_input.iloc[0,2]-test_input.iloc[0,1])

# %%
