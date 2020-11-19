%(in this case) GridGcn has GridConv1, GridConv2, GridConv3, FC1, FC2
% CHANNEL SIZES ARE HARDCODED
function [parameters] = initializeGridGCN()
    pointMLP1Channels = [64 64 128];
    edgeMLP1Channels = [64 128 128];
    pointMLP2Channels = [128 128 256];
    edgeMLP2Channels = [128 256 256];
    pointMLP3Channels = [256 256 512];
    edgeMLP3Channels = [256 512 512];
    fc1InputChannelSize = 512;
    fc1OutputChannelSize = 256;
    fc2InputChannelSize = 256;
    fc2OutputChannelSize = 45;
    
    parameters.GridConv1 = initializeGridConv(pointMLP1Channels(1), pointMLP1Channels(2:end), edgeMLP1Channels(2:end));
    
    parameters.GridConv2 = initializeGridConv(pointMLP2Channels(1), pointMLP2Channels(2:end), edgeMLP2Channels(2:end));
    
    parameters.GridConv3 = initializeGridConv(pointMLP3Channels(1), pointMLP3Channels(2:end), edgeMLP3Channels(2:end));
    
    parameters.FC1.Weights = dlarray(initializeWeightsHe([fc1OutputChannelSize, fc1InputChannelSize]));
    parameters.FC1.Bias = dlarray(zeros(fc1OutputChannelSize, 1, "single")); %IS SINGLE NECESSARY??
    
    parameters.FC2.Weights = dlarray(initializeWeightsHe([fc2OutputChannelSize, fc2InputChannelSize]));
    parameters.FC2.Bias = dlarray(zeros(fc2OutputChannelSize, 1, "single"));
end