"""
A simple test script to check if all dependencies are installed
"""
import traceback

print('---- Running Dependencies Test ----')

dep = ['pandas', 'numpy', 'beartype', 'typing',
        'seaborn', 'ieeg']

print('\n~ Requires: '+str(dep)[1:-1]+'\n')

passed = True


def test_case(case):
    global passed
    try:
        print('~ Checking dependency:', dep[case])
        if case is 0:
            import pandas as pd
        elif case is 1:
            import numpy as np
        elif case is 2:
            from beartype import beartype
        elif case is 3:
            from typing import Union
        elif case is 4:
            import seaborn as sns
        elif case is 6:
            from ieeg.auth import Session
        print('~ Import successful.')
    except:
        print(traceback.format_exc())
        print('~ Import failed!')
        passed = False

for i in range(len(dep)):
    test_case(i)

if passed:
    print('\nDependencies Test PASSED! :)\n')
else:
    print('\n~ Dependencies Test failed :(\n')