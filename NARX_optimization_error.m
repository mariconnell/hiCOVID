clear all;clc;close all

for j = 1:5
    %% Setup the Import Options and import the data
    opts = spreadsheetImportOptions("NumVariables", 26);

    % Specify sheet and range
    opts.Sheet = j;
    opts.DataRange = "A2:Z31";

    % Specify column names and types
    opts.VariableNames = ["ActualDNC", "ActualCCC", "DNC", "CCC", "DNC1", "CCC1", "DNC2", "CCC2", "DNC3", "CCC3", "DNC4", "CCC4", "DNC5", "CCC5", "DNC6", "CCC6", "DNC7", "CCC7", "DNC8", "CCC8", "DNC9", "CCC9", "DNC10", "CCC10", "DNC11", "CCC11"];
    opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];

    % Import the data
    table = readtable("/Users/marinoconnell/Desktop/NARX-V3-optimization/optimization-haw-V1.xlsx", opts, "UseExcel", false);

    %% Clear temporary variables
    clear opts

    MAE = [];
    RMSE = [];
    RSQ = [];
    
    actual    = table2array(table(:,1));
    actual_mean = mean(actual);

    for trial = 1:12
        
        actualCCC = table2array(table(:,2));
        predictedCCC= table2array(table(:,(trial*2)+2));
        R = corr(actualCCC,predictedCCC);
        RSQ(end+1,:) = R^2;
        
        predicted = table2array(table(:,(trial*2)+1));

        diff= actual-predicted
        diffsquared = diff.^2

        A = sum(abs(diff));
        B = sum(diffsquared)

        MAE_trial = A/30
        MSE_trial = B/30
        RMSE_trial = sqrt(MSE_trial) 

        MAE(end+1,:) = MAE_trial;
        RMSE(end+1,:) = RMSE_trial;
        
    end 

    MAE_xbar = MAE./actual_mean;
    RMSE_xbar = RMSE./actual_mean;

    errors = 'optimization-haw-V1.xlsx';

    writematrix("MAE",errors,'Sheet',j,'Range','B35') %adjust columns
    writematrix(MAE,errors,'Sheet',j,'Range','B36:B47') 
    writematrix("MAE_xbar",errors,'Sheet',j,'Range','C35')
    writematrix(MAE_xbar,errors,'Sheet',j,'Range','C36:C47')
    writematrix("RMSE",errors, 'Sheet',j,'Range','D35')
    writematrix(RMSE,errors, 'Sheet',j,'Range','D36:D47')
    writematrix("RMSE_xbar",errors, 'Sheet',j,'Range','E35')
    writematrix(RMSE_xbar,errors, 'Sheet',j,'Range','E36:E47')
    writematrix("R^2",errors, 'Sheet',j,'Range','F35')
    writematrix(RSQ,errors, 'Sheet',j,'Range','F36:F47')
    writematrix("Actual DNC Mean",errors, 'Sheet',j,'Range','A49')
    writematrix(actual_mean,errors, 'Sheet',j,'Range','B49')
end

