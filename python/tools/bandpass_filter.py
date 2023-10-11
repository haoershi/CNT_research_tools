import numpy as np
from scipy.signal import butter, filtfilt

def bandpass_filter(data: np.ndarray, fs: float, low_freq: float = 1, high_freq: float = 120):
    """
    Apply a 4th-order Butterworth bandpass filter to input data. 

    Args:
        data (np.ndarray): The input data to be filtered.
            It should be a 1D or 2D numpy array where rows represent different signals or channels.
        fs (float): The sampling frequency of the input data in Hertz (Hz).
        low_freq (float, optional): The lower cutoff frequency of the bandpass filter.
            Default is 1 Hz.
        high_freq (float, optional): The upper cutoff frequency of the bandpass filter.
            Default is 120 Hz.

    Returns:
        np.ndarray: The filtered data with the same shape as the input data.

    Examples:
        >>> low_freq = 2  # Lower cutoff frequency in Hz
        >>> high_freq = 50  # Upper cutoff frequency in Hz
        >>> filtered_data = tools.bandpass_filter(data,fs,low_freq,high_freq)
        >>> filtered_data = tools.bandpass_filter(data,fs)
    """
    
    b, a = butter(4, [max(low_freq,0),min(high_freq,fs//2)], btype='bandpass',fs=fs)

    # Apply filter to input signal
    y = filtfilt(b, a, data, axis = 0)

    return y
