function msg = printAnnualPrediction_optimize...
(Target_Table,Size,input,trial,AnnualPrediction,outputExcelFile)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
msg = 1;

first = Size-28;
last = Size+1;
True_DNC_Array = table2array (Target_Table(first:last,2));

True_CCC_Array = cumsum(True_DNC_Array);
Predicted_DNC_Array = cell2mat(AnnualPrediction);
Predicted_CCC_Array = Predicted_DNC_Array(1);

for k = 1:29
    Predicted_CCC_Array(end+1,1) = Predicted_DNC_Array(k+1)+True_CCC_Array(k); 
end

%DNCtitle_range = ["C1:C1";"E1:E1";"G1:G1";"I1:I1";"K1:K1";"M1:M1";"O1:O1";"Q1:Q1";"S1:S1";"U1:U1";"W1:W1";"Y1:Y1"];
DNCtitle_range = ["C1";"E1";"G1";"I1";"K1";"M1";"O1";"Q1";"S1";"U1";"W1";"Y1"];

DNC_range = ["C2:C31";"E2:E31";"G2:G31";"I2:I31";"K2:K31";"M2:M31";"O2:O31";"Q2:Q31";"S2:S31";"U2:U31";"W2:W31";"Y2:Y31"];
%CCCtitle_range = ["D1:D1";"F1:F1";"H1:H1";"J1:J1";"L1:L1";"N1:N1";"P1:P1";"R1:R1";"T1:T1";"V1:V1";"X1:X1";"Z1:Z1"];
CCCtitle_range = ["D1";"F1";"H1";"J1";"L1";"N1";"P1";"R1";"T1";"V1";"X1";"Z1"];

CCC_range = ["D2:D31";"F2:F31";"H2:H31";"J2:J31";"L2:L31";"N2:N31";"P2:P31";"R2:R31";"T2:T31";"V2:V31";"X2:X31";"Z2:Z31"];

writematrix("Actual DNC",outputExcelFile,'Sheet',input,'Range','A1') 
writematrix(True_DNC_Array,outputExcelFile,'Sheet',input,'Range','A2:A31') 

writematrix("Actual CCC",outputExcelFile,'Sheet',input,'Range','B1') 
writematrix(True_CCC_Array,outputExcelFile,'Sheet',input,'Range','B2:B31')

writematrix(trial+"DNC",outputExcelFile,'Sheet',input,'Range',DNCtitle_range(trial))
writecell(AnnualPrediction,outputExcelFile,'Sheet',input,'Range',DNC_range(trial))

writematrix(trial+"CCC",outputExcelFile,'Sheet',input,'Range',CCCtitle_range(trial)) 
writematrix(Predicted_CCC_Array,outputExcelFile,'Sheet',input,'Range',CCC_range(trial))
end

