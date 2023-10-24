from scipy.signal import welch
from scipy.integrate import simpson
import numpy as np
from beartype import beartype
from typing import Union
from numbers import Number

@beartype
def bandpower(data: np.ndarray, fs: Number, band: list, win_size:Union[None,Number]=None, relative:bool=False) -> np.ndarray:
    """Adapted from https://raphaelvallat.com/bandpower.html
    Compute the average power of the signal x in a specific frequency band.

    Parameters
    ----------
    data : 1d-array or 2d-array
        Input signal in the time-domain. (time by channels)
    fs : float
        Sampling frequency of the data.
    band : list
        Lower and upper frequencies of the band of interest. Each row represents one frequency range.
    win_size : float
        Length of each window in seconds.
        If None, win_size = (1 / min(band)) * 2
    relative : boolean
        If True, return the relative power (= divided by the total power of the signal).
        If False (default), return the absolute power.

    Return
    ------
    bp : np.ndarray
        Absolute or relative band power. channels by bands
    """
    band = np.asarray(band)
    nband = band.shape[0]
    nchan = data.shape[1]
    bp_all = np.nan*np.zeros([nchan,nband])
    for i in range(nband):
        low, high = band[i,:]

        # Define window length
        if win_size is not None:
            nperseg = int(win_size * fs)
        else:
            nperseg = int((2 / low) * fs)

        # Compute the modified periodogram (Welch)
        freqs, psd = welch(data.T, fs, nperseg=nperseg)

        # Frequency resolution
        freq_res = freqs[1] - freqs[0]

        # Find closest indices of band in frequency vector
        idx_band = np.logical_and(freqs >= low, freqs <= high)

        # Integral approximation of the spectrum using Simpson's rule.
        if psd.ndim == 2:
            bp = simpson(psd[:, idx_band], dx=freq_res)
        elif psd.ndim == 1:
            bp = simpson(psd[idx_band], dx=freq_res)

        if relative:
            bp /= simpson(psd, dx=freq_res)

        bp_all[:,i] = bp
        
    return bp_all
