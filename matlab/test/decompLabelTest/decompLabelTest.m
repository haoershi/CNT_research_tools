%% Test Class Definition
classdef decompLabelTest < matlab.unittest.TestCase
    % This is a test class defined for the decompose_labels function
    % Import test cases from decompLabel_testInput.csv file, which include 
    % input, expected output, and notes describes the test scenairo of the
    % case, the notes would be used as test case names and the other three
    % would be used to run the download_ieeg_data function. 

    properties (TestParameter)
        Data = decompLabel_param('decompLabel_testInput.csv');
    end

    %% Test Method Block
    methods (Test)
        % includes unit test functions
        function testdecompLabel(testCase,Data)   
            % This part test for wrong input types
            % see https://www.mathworks.com/help/matlab/matlab_prog/types-of-qualifications.html
            % for qualification method
            addpath(genpath('./../..')); % always add to ensure loading of other files/func
            [out,~,~] = decompose_labels(Data(1));
            testCase.verifyEqual(out,Data(2))
        end
    end
end