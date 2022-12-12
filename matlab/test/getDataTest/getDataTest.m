%% Test Class Definition
classdef getDataTest < matlab.unittest.TestCase
    % This is a test class defined for the download_ieeg_data function
    % Import test cases from test_getData.csv file, which include filename,
    % start time, stop time and notes describes the test scenairo of the
    % case, the notes would be used as test case names and the other three
    % would be used to run the download_ieeg_data function. Login usrname
    % and password file would be imported from the config.json file.
    % 
    % From this website to learn how to incorporate outside data
    % https://www.mathworks.com/help/matlab/matlab_prog/use-external-parameters-in-parameterized-test.html 
    % Define parameters below
    properties (TestParameter)
        Data = getData_param('getData_testInput.csv');
    end

    %% Test Method Block
    methods (Test)
        % includes unit test functions
        function testGetData(testCase,Data)   
            % This part test for wrong input types
            % see https://www.mathworks.com/help/matlab/matlab_prog/types-of-qualifications.html
            % for qualification method
            addpath(genpath('./..')); % always add to ensure loading of other files/func
            % read login info
            login_file = 'config.json';
            login = read_json(login_file);
            f = @() download_ieeg_data(Data{1}, login.usr, login.pwd, [Data{2},Data{3}], 1);
            %eval(strcat('f = @() download_ieeg_data(Data{1}, login.usr, login.pwd, [',Data{2},',',Data{3},'], 1);'))
            if strcmp(Data{4},'/')
                testCase.verifyWarningFree(f)
            else
                testCase.verifyError(f,Data{4})
            end
        end
    end
end