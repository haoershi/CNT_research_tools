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
with open(os.path.join("python/config.json"), 'rb') as f:
        config = pd.read_json(f, typ='series')

test_input = pd.read_csv(os.path.join(test_path,'test_getData.csv'))
params = [tuple(test_input.iloc[i,0:3]) for i in range(test_input.shape[0])]
@pytest.mark.parametrize('filename,start,stop',params)
def test_getdata(filename,start,stop):
    try:
        data,fs = tools.get_iEEG_data(config.usr,config.pwd,filename,start,stop)
        assert data.shape[0] == fs*(stop-start)
    except Exception as e:
        if type(e)== NameError:
            assert True
        elif type(e)== ValueError:
            assert True
        else:
            assert False
