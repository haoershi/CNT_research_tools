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
# unit test for clean_labels function
# write in a csv file, col 0 input, col 1 expected output
# wait to fetch all channel types from ieeg
def test_channel():
    
    test_channel = pd.read_csv(os.path.join(test_path,'testchannel.csv'))
    clean_channel = tools.clean_labels(list(test_channel['input']))
    for _i in test_channel.shape[0]:
        assert clean_channel[_i] == test_channel.iloc[_i,1]
# %%
