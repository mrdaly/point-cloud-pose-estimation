%(in this case) GridGcn has GridConv1, GridConv2, GridConv3, FC1, FC2
% CHANNEL SIZES ARE HARDCODED
function [parameters] = initializeGridGCN()
    pointMLP1Channels = [3 64 128];
    edgeMLP1Channels = [3 64 128];
    pointMLP2Channels = [128 128 256];
    edgeMLP2Channels = [3 128 256];
    pointMLP3Channels = [256 256 512];
    edgeMLP3Channels = [3 156 512];
    fc1InputChannelSize = 512;
    fc1OutputChannelSize = 256;
    fc2InputChannelSize = 256;
    fc2OutputChannelSize = 45;
    
    parameters.GridConv1 = initializeGridConv(pointMLP1Channels, edgeMLP1Channels);
    
    parameters.GridConv2 = initializeGridConv(pointMLP2Channels, edgeMLP2Channels);
    
    parameters.GridConv3 = initializeGridConv(pointMLP3Channels, edgeMLP3Channels);
    
    parameters.FC1.learnables{1} = dlarray(initializeWeightsHe([fc1OutputChannelSize, fc1InputChannelSize]));
    parameters.FC1.learnables{2} = dlarray(zeros(fc1OutputChannelSize, 1, "single")); %IS SINGLE NECESSARY??
    
    parameters.FC2.learnables{1} = dlarray(initializeWeightsHe([fc2OutputChannelSize, fc2InputChannelSize]));
    parameters.FC2.learnables{2} = dlarray(zeros(fc2OutputChannelSize, 1, "single"));
end