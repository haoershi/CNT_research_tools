import matplotlib.pyplot as plt
import matplotlib as mpl
import numpy as np
from beartype import beartype

@beartype
def plot_iEEG_data(data:np.ndarray, chs, t):
    """
    Plot iEEG data for multiple channels over time.

    Parameters:
    - data (np.ndarray): 2D array representing iEEG data. Each column corresponds to a channel, and each row corresponds to a time point.
    - chs (list): List of channel names corresponding to the columns in the data array.
    - t (list): List of time range to plot.

    Returns:
    - fig (matplotlib.figure.Figure): The generated matplotlib Figure object.

    Example:
    data = np.random.rand(100, 5)  # Replace with your actual iEEG data
    chs = ['Channel 1', 'Channel 2', 'Channel 3', 'Channel 4', 'Channel 5']  # Replace with actual channel names
    t = [0, 10]  # Replace with your actual time points

    fig = plot_iEEG_data(data, chs, t)
    plt.show()
    """

    offset = 0
    fig, ax = plt.subplots(figsize=(15, 15))
    mpl.rcParams['axes.spines.right'] = False
    mpl.rcParams['axes.spines.top'] = False
    mpl.rcParams['axes.spines.left'] = False

    for ich in range(data.shape[1]):
        eeg = data[:, ich]
        if np.any(~np.isnan(eeg)):
            ax.plot(t, eeg - offset, 'k')
            ax.text(t[-1] + 0.5, -offset + np.nanmedian(eeg), chs[ich], fontsize=10, va='center')
            last_min = np.nanmin(eeg)

        if ich < data.shape[1] - 1:
            next_eeg = data[:, ich + 1]
            if np.any(~np.isnan(next_eeg)) and not np.isnan(last_min):
                offset = offset - (last_min - np.nanmax(next_eeg))

    # pass a plt.xlim that focuses around the center of the spike
    plt.show()

    return fig
