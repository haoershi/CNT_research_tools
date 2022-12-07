'''
    clean labels function
'''
import re
import numpy as np
from beartype import beartype
from typing import Union

@beartype
def clean_labels(channel_li:Union[list[str],str]):
    '''
    This function cleans a list of channels and returns the new channels
    '''
    if not isinstance(channel_li,list):
        channel_li = [channel_li]
    new_channels = []
    for i in range(len(channel_li)):
        # standardizes channel names
        label_num_search = re.search(r'\d', channel_li[i])
        if label_num_search is not None:
            label_num_idx = label_num_search.start()
            label_non_num = channel_li[i][:label_num_idx]
            label_num = channel_li[i][label_num_idx:]
            label_num = label_num.strip('0')
            label = label_non_num+label_num
        else:
            label = channel_li[i]
        label = label.replace('EEG','')
        label = label.replace('Ref','')
        label = label.replace(' ','')
        label = label.replace('-','')
        label = label.replace('CAR','')
        label = label.replace('HIPP','DH')
        label = label.replace('AMY','DA')
        label = label.replace('FP1','Fp1')
        label = label.replace('FP2','Fp2')
        new_channels.append(label)
    return new_channels