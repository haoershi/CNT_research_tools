%% Test Class Definition
classdef test_class < matlab.unittest.TestCase
    % https://www.mathworks.com/help/matlab/matlab_prog/use-external-parameters-in-parameterized-test.html
    % from this website learn how to incorporate outside data
    properties (TestParameter)
        Data = struct("clean",[5 3 9;1 42 5;32 5 2], ...
            "needsCleaning",[1 13;NaN 0;Inf 42]);
    end
    %% Test Method Block
    methods (Test)
        % includes unit test functions
        %% Test Function
        function testASolution(testCase)      
            %% Exercise function under test
            % act = the value from the function under test

            %% Verify using test qualification
            % exp = your expected value
            % testCase.<qualification method>(act,exp);
            % see https://www.mathworks.com/help/matlab/matlab_prog/types-of-qualifications.html
            % for qualification method
            testCase.verifyEqual(plus(2,3),5)
        end

        function testBSolution(testCase)      
            %% Exercise function under test
            % act = the value from the function under test

            %% Verify using test qualification
            % exp = your expected value
            % testCase.<qualification method>(act,exp);
            % see https://www.mathworks.com/help/matlab/matlab_prog/types-of-qualifications.html
            % for qualification method
            testCase.verifyEqual(plus(3,3),6)
        end
    end
end