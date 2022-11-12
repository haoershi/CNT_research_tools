% main configuration part, don't change
function tests = test_func
tests = functiontests(localfunctions);
end

% define specific test functions below
function test_channel(testCase)
actSolution = decompose_labels({'LA01','C3', 'LOC'},'HUP022');% can also read from file
expSolution = {'LA1','C3', 'LOC'}';
verifyEqual(testCase,actSolution,expSolution)
end
