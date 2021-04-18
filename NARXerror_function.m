function msg = NARXerror_function(inputExcelFile,input)
%UNTITLED10 Summary of this function goes here

msg = 1;

%% Setup the Import Options and import the data
opts = spreadsheetImportOptions("NumVariables", 4);

% Specify sheet and range
opts.Sheet = input; 
opts.DataRange = "B2:E31";

% Specify column names and types
opts.VariableNames = ["Actual DNC", "Actual CCC", "Predicted DNC", "Predicted CCC"];
opts.VariableTypes = ["double", "double", "double", "double"];

% Import the data
table = readtable(inputExcelFile, opts, "UseExcel", false);

%% Clear temporary variables
clear opts

actualDNC    = table2array(table(:,1));
actual_mean = mean(actualDNC);
predictedDNC = table2array(table(:,3));

diff= actualDNC-predictedDNC;
diffsquared = diff.^2;

A = sum(abs(diff));
B = sum(diffsquared);

MAE = A/30;
MSE = B/30;
RMSE = sqrt(MSE); 

MAE_xbar = MAE./actual_mean;
RMSE_xbar = RMSE./actual_mean;

actualCCC = table2array(table(:,2));
predictedCCC= table2array(table(:,4));
R = corr(actualCCC,predictedCCC);
RSQ = R^2;

Titles = ["MAE","MAE/xbar","RMSE","RMSE/xbar","R^2","xbar ="];
writematrix(Titles(1),inputExcelFile,'Sheet',input,'Range','A36') 
writematrix(MAE,inputExcelFile,'Sheet',input,'Range','A37')
writematrix(Titles(2),inputExcelFile,'Sheet',input,'Range','B36')
writematrix(MAE_xbar,inputExcelFile,'Sheet',input,'Range','B37')
writematrix(Titles(3),inputExcelFile,'Sheet',input,'Range','C36')
writematrix(RMSE,inputExcelFile, 'Sheet',input,'Range','C37')
writematrix(Titles(4),inputExcelFile,'Sheet',input,'Range','D36')
writematrix(RMSE_xbar,inputExcelFile, 'Sheet',input,'Range','D37')
writematrix(Titles(5),inputExcelFile,'Sheet',input,'Range','E36')
writematrix(RSQ,inputExcelFile, 'Sheet',input,'Range','E37')
writematrix(Titles(6),inputExcelFile,'Sheet',input,'Range','A39')
writematrix(actual_mean,inputExcelFile, 'Sheet',input,'Range','B39')

end

