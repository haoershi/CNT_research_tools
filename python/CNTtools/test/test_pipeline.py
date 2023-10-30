
#%%
# Imports
import pandas as pd
import numpy as np
import pytest
import os, sys

# test_dir = os.path.dirname(os.path.abspath(__file__))
# current_dir = os.path.dirname(test_dir)
# sys.path.append(current_dir)
from CNTtools.iEEGPreprocess import iEEGPreprocess
#%%
# unit test for get_iEEG_data function
# write in a csv file all tests, col 0 filename, col 1 start in sec, col 2 stop in sec, col 4 electrodes
# metadata should contain all correct info for reference, maybe fetch later
# do not test electrodes temporarily

iEEG_filename = "HUP172_phaseII"#@param {type:"string"}
start_time = 402580 #@param {type:"number"}
stop_time = 402600 #@param {type:"number"}
electrodes = "LE10, LE11, LH01, LH02, LH03, LH04" #@param {type:"string"}
electrodes = electrodes.split(', ')
# param = {'filename':iEEG_filename,
#          'start':start_time,
#          'stop':stop_time,
#          'electrodes':electrodes}
#%%
# @pytest.mark.parametrize("filename,start,stop,electrodes", params)
# def test_pipeline(filename, start, stop, electrodes):
session = iEEGPreprocess()
data = session.download_data(iEEG_filename,start_time,stop_time,select_elecs=electrodes)
assert session.num_data == 1
assert data.index == 0
session.save('session1')
session.load_data('session1.pkl')
assert session.num_data == 2
#%%
data.clean_labels()
data.find_nonieeg()
data.find_bad_chs()
data.reject_nonieeg()
data.reject_artifact()
#%%
data.bandpass_filter()
data.notch_filter()
data.filter()
#%%
data.car()
assert hasattr(data,'ref_chnames')
#%%
data.bipolar()
data.reverse()
#%%
assert data.data.shape[1] == 6
assert len(data.ref_chnames) == 6
#%%
data.laplacian('CNTtools/test/elec_locs.csv')
assert hasattr(data,'locs')
#%%
f = data.plot()
data.pre_whiten()
#%%
data.line_length()
assert not any(np.isnan(data.ll))
#%%
data.bandpower([[1,20],[25,50]])
assert not any(np.isnan(data.power['power'][0]))
#%%
data.pearson()
data.squared_pearson()
data.cross_corr()
#%%
data.coherence()
#%%
data.plv()
data.relative_entropy()
#%%
assert set(data.conn.keys()) == {'pearson','plv','rela_entropy','squared_pearson','coh','cross_corr'}
#%%
fig = data.conn_heatmap('coh','delta')
#%%
data.save()
session.load_data('')
# %%
session.list_data()
session.remove_data([1,2,3])
assert session.num_data == 1