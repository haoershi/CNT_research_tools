import numpy as np
from scipy.signal import butter, filtfilt

def bandpass_filter(data: np.ndarray, fs: float,low_freq:float = 1, high_freq:float = 120):
    """_summary_

    Args:
        data (_type_): _description_
        fs (_type_): _description_
    """
    
    b, a = butter(4, [max(low_freq,0),min(high_freq,fs//2)], btype='bandpass',fs=fs)

    # Apply filter to input signal
    y = filtfilt(b, a, data, axis = 0)

    return y
