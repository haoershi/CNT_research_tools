import setuptools
from distutils.core import setup, Extension

with open("README.md", "r") as fh:
    long_description = fh.read()

setup(name='cnt_tools',
      version='0.1',
      description='Pre-processing toolkit for iEEG data',
      install_requires=['pennprov==2.2.4','pyqt5-sip==12.9.0',
                        'install==1.3.5','pytest','beartype','pytest-html'],
      packages=setuptools.find_packages(),
      long_description=long_description,
      long_description_content_type="text/markdown",
      url="https://github.com/haoershi/CNT_research_tools",
      )