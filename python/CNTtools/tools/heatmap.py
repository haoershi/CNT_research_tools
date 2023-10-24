import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt
from beartype import beartype

@beartype
def heatmap(data:np.ndarray, ch_names: np.ndarray):
    # Create a heatmap using Seaborn
    fig = sns.heatmap(data, cmap="Blues", annot=False, fmt=".2f", cbar=True, 
                xticklabels=ch_names, yticklabels=ch_names)
    # Display the plot
    plt.show()
    return fig
