% last channel size must be same in pointMLP and edgeMLP
function [parameters] = initializeGridConv(pointMLPChannelSize, edgeMLPChannelSize)
    parameters.PointMLP = initializeSharedMLP(pointMLPChannelSize(1), pointMLPChannelSize(2:end));
    parameters.EdgeMLP = initializeSharedMLP(edgeMLPChannelSize(1), edgeMLPChannelSize(2:end));
end