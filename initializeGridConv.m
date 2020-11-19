% last channel size must be same in pointMLP and edgeMLP
function [parameters] = initializeGridConv(inputChannelSize, pointMLPHiddenChannelSize, edgeMLPHiddenChannelSize)
    parameters.pointMLP = initializeSharedMLP(inputChannelSize, pointMLPHiddenChannelSize);
    parameters.edgeMLP = initializeSharedMLP(inputChannelSize, edgeMLPHiddenChannelSize);
end