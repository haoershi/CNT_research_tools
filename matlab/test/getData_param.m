function output = getData_param(fname)
    addpath(genpath('./..')); % always add to ensure loading of other files/func

    inputData = readtable(fname,'Delimiter',',','Format','auto'); % read test cases
    % format into 3 structs
    output = struct();
    for i = 1:size(inputData,1)
        eval(strcat('output.',string(inputData.notes(i)),'={inputData.filename{',num2str(i), ...
            '},inputData.start{',num2str(i),'},inputData.stop{',num2str(i),'},inputData.out{',num2str(i),'}};'))
    end
end