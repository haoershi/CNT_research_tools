# CNT Pre-processing Toolkit
Toolkit for pre-processing of intracranial EEG data, and an interactive pipeline for pre-processing method evaluation.
Toolkit available in Matlab and Python
Toolkit compatible with iEEG.org

## Installation

### Get Started 

Download or clone the toolbox into a local folder via git, and switch to folder:
```
git clone git@github.com:haoershi/CNT_research_tools.git
cd CNT_research_tools
```

### Python

**Installation via Conda**

Dependencies: 
* [anaconda](https://www.anaconda.com)


Create a conda environment and activate:
```
cd python
conda env create -n ieegpy -f ieegpy.yml
conda activate ieegpy
```

**Login Configuration**

The toolkit currently depends on ieeg.org.
To access data, please register first on https://www.ieeg.org.
Generate bin password file *_ieeglogin.bin through create_pwd_file function.
In the _python_ folder, run in Python:
```\python
from tools import create_pwd_file
create_pwd_file(username, password)
```
A password file named usr_ieeglogin.bin would be automatically created in the _python_ folder.
Update config.json file to specify username and password file name.

**Test**

Run pytest to ensure no running issues.
(Getting data may not be tested currently)
