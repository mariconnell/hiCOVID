function msg = printAnnualPrediction...
(Target_Table,Size,input,Input_name,AnnualPrediction,outputExcelFile)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
msg = 1;

Titles = ["Date","Actual DNC","Actual CCC","Predicted CCC"];

first = Size-28;
last = Size+1;
True_DNC_Array = table2array (Target_Table(first:last,2));
Dates = table2array (Target_Table(first:last,1));

True_CCC_Array = cumsum(True_DNC_Array);
Predicted_DNC_Array = cell2mat(AnnualPrediction);
Predicted_CCC_Array = Predicted_DNC_Array(1);

for k = 1:29
    Predicted_CCC_Array(end+1,1) = Predicted_DNC_Array(k+1)+True_CCC_Array(k); 
end

writematrix(Titles(1),outputExcelFile,'Sheet',input,'Range','A1:A1') 
writematrix(Dates,outputExcelFile,'Sheet',input,'Range','A2:A31') 
writematrix(Titles(2),outputExcelFile,'Sheet',input,'Range','B1:B1') 
writematrix(True_DNC_Array,outputExcelFile,'Sheet',input,'Range','B2:B31')
writematrix(Titles(3),outputExcelFile,'Sheet',input,'Range','C1:C1') 
writematrix(True_CCC_Array,outputExcelFile,'Sheet',input,'Range','C2:C31')
writecell(Input_name,outputExcelFile,'Sheet',input,'Range','D1:D1')
writecell(AnnualPrediction,outputExcelFile,'Sheet',input,'Range','D2:D31')
writematrix(Titles(4),outputExcelFile,'Sheet',input,'Range','E1:E1') 
writematrix(Predicted_CCC_Array,outputExcelFile,'Sheet',input,'Range','E2:E31')
end

