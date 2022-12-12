'''
    This function finds non-iEEG channel labels
'''
import re
import numpy as np
from beartype import beartype
from typing import Union

non_ieeg = [
    "EKG",
    "O",
    "C",
    "ECG",
    "CZ",
    "RATE",
    'C3',
    'C4',
    'CZ',
    'F8',
    'F7',
    'F4',
    'F3',
    'FP2',
    'FP1',
    'FZ',
    'LOC',
    'T4',
    'T5',
    'T3',
    'C6',
    'ROC',
    'P4',
    'P3',
    'T6' 
    ]

@beartype
def find_non_ieeg(channel_li:Union[list[str],str]):
    '''
    This function finds non-iEEG channel labels
    '''
    if not isinstance(channel_li,list):
        channel_li = [channel_li]
    is_non_ieeg = np.zeros(len(channel_li), dtype=bool)
    for ind, i in enumerate(channel_li):
        # Gets letter part of channel
        label_num_search = re.search(r'\d', i)
        if label_num_search is not None:
            label_num_idx = label_num_search.start()
            label_non_num = i[:label_num_idx]
        else:
            label_non_num = i
        # finds non-iEEG channels, make a separate function
        if label_non_num.upper() in non_ieeg:
            is_non_ieeg[ind] = True
# add O1, O2 judgement later
        #if label_non_num.upper() in ["O1","O2"]:
        #    if 

    return is_non_ieeg
    