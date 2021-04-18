clear all;clc;close all

%% 1. Importing data (Target - Daily New Cases)
opts = spreadsheetImportOptions("NumVariables", 2);

% Specify sheet and range
opts.Sheet = "Raw-data";
opts.DataRange = "A1:B325";

% Specify column names and types
opts.VariableNames = ["Date","Actual DNC"];
opts.VariableTypes = ["datetime","double"];


% Import the data
Target_Table = readtable("/Users/marinoconnell/Desktop/NARX-V3-optimization/optimization-haw-V1.xlsx", opts, "UseExcel", false);

%% Setup the Import Options and import the data
opts = spreadsheetImportOptions("NumVariables", 5);

% Specify sheet and range
opts.Sheet = "Raw-data";
opts.DataRange = "C1:G323";

% Specify column names and types
opts.VariableNames = ["Spending", "SBrevenue", "SBopen", "Residential", "Workplaces"];
opts.VariableTypes = ["double", "double", "double", "double", "double"];

% Import the data
Input_Table = readtable("/Users/marinoconnell/Desktop/NARX-V3-optimization/optimization-haw-V1.xlsx", opts, "UseExcel", false);

%% Clear temporary variables
clear opts

%% 3. Specify file which results will be uploaded to
outputExcelFile = 'optimization-haw-V1.xlsx';
inputExcelFile = outputExcelFile;

%% 4. Network Architecture

% Choose a Training Function
training_function_list = ["trainlm";"trainlm";"trainlm";"trainlm";"trainlm";"trainlm";...
    "trainrp";"trainrp";"trainrp";"trainscg";"trainscg";"trainscg"];
Feedback_Delays_list = [7,7,7,3,7,7,7,7,7,7,7,7];
Hidden_Layer_Size_list = [5,7,4,5,5,5,5,5,5,5,5,5];
train_ratio_list = [80,80,80,80,50,20,80,50,20,80,50,20,80];
validation_ratio_list = [20,20,20,20,50,80,20,50,80,20,50,80];

for trial = 1:12
    training_function = training_function_list(trial);
    Feedback_Delays = Feedback_Delays_list(1,trial);
    Hidden_Layer_Size = Hidden_Layer_Size_list(1,trial);
    train_ratio = train_ratio_list(1,trial);
    validation_ratio = validation_ratio_list(1,trial);

    %% 5. Loop to make predictions and calculate errors for each input
    for irun = 1:5
        input = irun;

        Input_set_all_array = table2array (Input_Table(1:end,input));
        Size = numel(Input_set_all_array)-sum(isnan(Input_set_all_array))+1;

        AnnualPrediction = NARXsinglestep_function_optimize(Target_Table,Input_Table,input,...
            Size,training_function,Feedback_Delays,Hidden_Layer_Size,train_ratio,validation_ratio);

        msg = printAnnualPrediction_optimize(Target_Table,Size,input,trial,...
            AnnualPrediction,outputExcelFile);

    end
end
