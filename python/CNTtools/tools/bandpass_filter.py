import numpy as np
from scipy.signal import butter, filtfilt
from beartype import beartype
from numbers import Number

@beartype
def bandpass_filter(
    data: np.ndarray, fs: Number, low_freq: Number = 1, high_freq: Number = 120, order: int = 4,
) -> np.ndarray:
    """
    Apply a 4th-order Butterworth bandpass filter to input data.

    Args:
        data (np.ndarray): The input data to be filtered with shape (samples, channels).
        fs (float): The sampling frequency of the input data in Hertz (Hz).
        low_freq (float, optional): The lower cutoff frequency of the bandpass filter.
            Default is 1 Hz.
        high_freq (float, optional): The upper cutoff frequency of the bandpass filter.
            Default is 120 Hz.

    Returns:
        np.ndarray: The filtered data with the same shape as the input data.

    Examples:
        >>> # Simulate data
        >>> import numpy as np
        >>> data = np.random.rand(1000) 
        >>>  
        >>> from tools import bandpass_filter
        >>> fs = 1000  # Sampling frequency in Hz
        >>> filtered_data = bandpass_filter(data, fs)
        >>> low_freq = 2  # Lower cutoff frequency in Hz
        >>> high_freq = 50  # Upper cutoff frequency in Hz
        >>> filtered_data = bandpass_filter(data, fs, low_freq, high_freq)
    """

    b, a = butter(
        order, [max(low_freq, 0), min(high_freq, fs // 2)], btype="bandpass", fs=fs
    )

    # Apply filter to input signal
    y = filtfilt(b, a, data, axis=0)

    return y
