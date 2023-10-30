import pandas as pd
import numpy as np
from .clean_labels import clean_labels
from beartype import beartype
from beartype.typing import Iterable, Union

@beartype
def get_elec_locs(chLabels: Union[Iterable[str], str], filename: str) -> np.ndarray:
    """
    Get electrode locations for specified channel labels from a file.

    Parameters:
    - chLabels (iterable or str): Channel labels for which to retrieve electrode locations.
    - filename (str): Path to the file containing electrode locations.

    Returns:
    - output (np.ndarray): Numpy array containing electrode locations corresponding to channel labels
                    Unavailable channel locations filled with nan.

    Example:
    chLabels = ['Fp1', 'Fp2', 'C3', 'C4']
    filename = 'electrode_locations.csv'
    output = get_elec_locs(chLabels, filename)
    """

    # Convert single string to list
    if isinstance(chLabels, str):
        chLabels = [chLabels]

    # Load electrode locations from the specified file
    elec_locs = pd.read_csv(filename,header = None,index_col = 0)
    locs = elec_locs.to_numpy()
    # Clean labels from both sources
    labels = clean_labels(elec_locs.index.to_numpy())
    chLabels = clean_labels(chLabels)

    # Find common labels and their corresponding indices
    common = np.isin(chLabels,labels)
    out_locs = np.nan*np.zeros([len(chLabels),locs.shape[1]])
    for i in range(len(chLabels)):
        if common[i]:
            ind = np.where(labels == chLabels[i])[0]
            out_locs[i,:] = locs[ind,:]

    return out_locs
