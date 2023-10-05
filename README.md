# CNT Pre-processing Toolkit
Toolkit for pre-processing of intracranial EEG data, and an interactive pipeline for pre-processing method evaluation.

Toolkit available in Matlab and Python, compatible with iEEG.org

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

**Testing**

Run pytest to ensure no running issues.
(Getting data may not be tested currently)


### MATLAB
Dependencies: 
* MATLAB >= R2021b
* Signal Processing Toolbox
* Statistics and Machine Learning Toolbox
Toolboxes could be installed via Adds-Ons > Get Adds-Ons.
* IEEG MATLAB Toolbox (Can be downloaded at https://main.ieeg.org/?q=node/29, or we've provided with our toolkit)

Add folder _matlab_ in MATLAB working directory.
```\matlab
addpath(genpath('matlab'));
```

**Login Configuration**

The toolkit currently depends on ieeg.org.

To access data, please register first on https://www.ieeg.org.

Generate bin password file *_ieeglogin.bin through create_pwd_file function.

Run in MATLAB:
```\matlab
IEEGSession.createPwdFile('username', 'password');
```
Save the password file in the _matlab_ folder with name 'usr_ieeglogin.bin'.

Update config.json file to specify username and password file name.

**Testing**

Run unit tests to ensure no running issues:
(Getting data may not be tested currently)
```
runtests('matlab/test','IncludeSubfolders',true);
```

## Functions

The toolbox includes the following functions:
* Download data from ieeg.org
* Standardize channel labels and identify band channels
* Signal filtering
* Data re-referencing 
    * Common Average Re-referencing (CAR)
    * Bipolar Re-referencing (BR)
    * Laplacian Re-referencing (LR)
* Pre-whitening
* Feature extraction
<img src="https://github.com/haoershi/CNT_research_tools/assets/116624350/dfefeb73-4fc0-48db-96ff-5fd823785f2c" width=50% height=50%>

## Usage

This toolkit provides a recommended usage pipeline in the form of interactive notebooks in both MATLAB and Python.

For illustration, this toolkit is also used for an systematic evaluation of pre-processing methods, as shown in the demo folder.  
