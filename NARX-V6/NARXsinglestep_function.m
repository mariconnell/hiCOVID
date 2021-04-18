function [AnnualPrediction] = NARXsinglestep_function...
    (Target_Table,Input_Table,input,Size,training_function,Feedback_Delays,...
    Hidden_Layer_Size,train_ratio,validation_ratio)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

for days=1:30 
    
    Input_Set=Input_Table(1:Size-(1*days),input);
    Target_Set=Target_Table(1:Size-(1*days),2); %specific training set

    %1.1. Format Time-series Data Set
    Input_Array = table2array (Input_Set(1:end,1:end)); 
    Target_Array = table2array (Target_Set(1:end,1));
    Input=Input_Array'; % Convert to row % For converting to NARX
    Target=Target_Array'; % Convert to row
    X = con2seq(Input); % Convert to cell % For converting to NARX
    T= con2seq(Target); % Convert to cell


    %% 3. Network Architecture
    trainFcn = training_function;

    % Create a Nonlinear Autoregressive Network with External Input
    inputDelays = 1:7;
    feedbackDelays = 1:Feedback_Delays;
    hiddenLayerSize = Hidden_Layer_Size;
    net = narxnet(inputDelays,feedbackDelays,hiddenLayerSize,'open',trainFcn);

    % Choose Input and Feedback Pre/Post-Processing Functions
    % Settings for feedback input are automatically applied to feedback output
    % For a list of all processing functions type: help nnprocess
    % Customize input parameters at: net.inputs{i}.processParam
    % Customize output parameters at: net.outputs{i}.processParam
    net.inputs{1}.processFcns = {'mapminmax'};
    net.inputs{2}.processFcns = {'mapminmax'};

    %% 4. Training the Open Loop Network
    % Prepare the Data for Training and Simulation
    % The function PREPARETS prepares timeseries data for a particular network,
    % shifting time by the minimum amount to fill input states and layer
    % states. Using PREPARETS allows you to keep your original time series data
    % unchanged, while easily customizing it for networks with differing
    % numbers of delays, with open loop or closed loop feedback modes.
    [x,xi,ai,t] = preparets(net,X,{},T);

    % Setup Division of Data for Training, Validation, Testing
    % For a list of all data division functions type: help nndivision
    net.divideFcn = 'dividerand';  % Divide data randomly
    net.divideMode = 'time';  % Divide up every sample
    net.divideParam.trainRatio = train_ratio/100;
    net.divideParam.valRatio = validation_ratio/100;
    net.divideParam.testRatio = 0/100;

    % Choose a Performance Function
    % For a list of all performance functions type: help nnperformance
    net.performFcn = 'mse';  % Mean Squared Error

    % Choose Plot Functions
    % For a list of all plot functions type: help nnplot
    net.plotFcns = {'plotperform','plottrainstate', 'ploterrhist', ...
        'plotregression', 'plotresponse', 'ploterrcorr', 'plotinerrcorr'};

    % Train the Network
    [net,tr] = train(net,x,t,xi,ai);

    % Test the Network
    y = net(x,xi,ai);
    e = gsubtract(t,y);
    performance = perform(net,t,y)

    % Recalculate Training, Validation and Test Performance
    trainTargets = gmultiply(t,tr.trainMask);
    valTargets = gmultiply(t,tr.valMask);
    testTargets = gmultiply(t,tr.testMask);
    trainPerformance = perform(net,trainTargets,y)
    valPerformance = perform(net,valTargets,y)
    testPerformance = perform(net,testTargets,y)


    %% 7. Single-Step-Ahead Prediction Network
    % For some applications it helps to get the prediction a timestep early.
    % The original network returns predicted y(t+1) at the same time it is
    % given y(t+1). For some applications such as decision making, it would
    % help to have predicted y(t+1) once y(t) is available, but before the
    % actual y(t+1) occurs. The network can be made to return its output a
    % timestep early by removing one delay so that its minimal tap delay is now
    % 0 instead of 1. The new network returns the same outputs as the original
    % network, but outputs are shifted left one timestep.
    nets = removedelay(net);
    nets.name = [net.name ' - Predict One Step Ahead'];
    %view(nets)
    [xs,xis,ais,ts] = preparets(nets,X,{},T);
    ys = nets(xs,xis,ais);
    stepAheadPerformance = perform(nets,ts,ys);
    OneStepPrediction(days)= ys(end);
end
OneStepPrediction_Transposed=OneStepPrediction';
AnnualPrediction= flip(OneStepPrediction_Transposed);
% Deployment
% Change the (false) values to (true) to enable the following code blocks.
% See the help for each generation function for more information.
if (false)
    % Generate MATLAB function for neural network for application
    % deployment in MATLAB scripts or with MATLAB Compiler and Builder
    % tools, or simply to examine the calculations your trained neural
    % network performs.
    genFunction(net,'myNeuralNetworkFunction');
    y = myNeuralNetworkFunction(x,xi,ai);
end
if (false)
    % Generate a matrix-only MATLAB function for neural network code
    % generation with MATLAB Coder tools.
    genFunction(net,'myNeuralNetworkFunction','MatrixOnly','yes');
    x1 = cell2mat(x(1,:));
    x2 = cell2mat(x(2,:));
    xi1 = cell2mat(xi(1,:));
    xi2 = cell2mat(xi(2,:));
    y = myNeuralNetworkFunction(x1,x2,xi1,xi2);
end
if (false)
    % Generate a Simulink diagram for simulation or deployment with.
    % Simulink Coder tools.
    gensim(net);
end

end


