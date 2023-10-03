import setuptools
from distutils.core import setup, Extension

with open("README.md", "r") as fh:
    long_description = fh.read()

setup(name='cnt_tools',
      version='0.1',
      description='Pre-processing toolkit for iEEG data',
      install_requires=['cachetools==5.2.0','pennprov==2.2.4','pyqt5-sip==12.9.0',
                        'install==1.3.5','scipy==1.8.1','matplotlib==3.5.2','matplotlib-inline==0.1.3',
                        'seaborn==0.11.2','pytest','beartype','pytest-html','scikit-learn'],
      packages=setuptools.find_packages(),
      long_description=long_description,
      long_description_content_type="text/markdown",
      url="https://github.com/haoershi/CNT_research_tools",
      )