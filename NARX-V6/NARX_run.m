clear all;clc;close all

%% 1. Importing Dates & Target Data (Daily New Cases)
opts = spreadsheetImportOptions("NumVariables", 2);

% Specify sheet and range
opts.Sheet = "Hawaii";
opts.DataRange = "A1:B327";

% Specify column names and types
opts.VariableNames = ["Date","Actual DNC"];
opts.VariableTypes = ["datetime","double"];

% Import the data
Target_Table = readtable("/Users/marinoconnell/Desktop/NARX-V6/RawData_county.xlsx", opts, "UseExcel", false);

%% 2. Importing Input Data (Socio-Economic Time-Series Data)
opts = spreadsheetImportOptions("NumVariables", 11);

% Specify sheet and range
opts.Sheet = "Hawaii";
opts.DataRange = "C1:M327";

% Specify column names and types
opts.VariableNames = ["Spending", "RetailRec", "GroceryPharm", "Parks", "TransitStation", "Workplaces", "Residential", "Driving",...
    "Walking", "SBrevenue", "SBopen"];
    %"Transit",
    
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];
    %, "double"];

% Import the data
Input_Table = readtable("/Users/marinoconnell/Desktop/NARX-V6/RawData_county.xlsx", opts, "UseExcel", false);
VariableNames = opts.VariableNames;
clear opts

%% 3. Specify file which results will be uploaded to
outputExcelFile = 'NARX-haw-V2.xlsx';
inputExcelFile = outputExcelFile;

%% 4. Network Architecture

% Choose a Training Function
%training_function = 'trainlm';
training_function = 'trainrp';
%training_function = 'trainscg';

Feedback_Delays = 7;
Hidden_Layer_Size = 5;
train_ratio = 50;
validation_ratio = 50;

%% 5. Loop to make predictions and calculate errors for each input
for irun = 1:11
    Input_name = VariableNames(irun);
    input = irun;
    
    Input_set_all_array = table2array (Input_Table(1:end,input));
    Size = numel(Input_set_all_array)-sum(isnan(Input_set_all_array))+1;

    AnnualPrediction = NARXsinglestep_function(Target_Table,Input_Table,input,...
        Size,training_function,Feedback_Delays,Hidden_Layer_Size,train_ratio,validation_ratio);
   
    msg = printAnnualPrediction(Target_Table,Size,input,Input_name,...
        AnnualPrediction,outputExcelFile);
    
    msg2 = NARXerror_function(inputExcelFile, input);
end

