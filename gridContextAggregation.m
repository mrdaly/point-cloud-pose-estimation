% params:
%   center - 1x3 group center point
%   nodePoints - kx3 points in group
%   nodeFeatures - kxnumInputFeatures, features for each group node from
%                   prev layers
%   params - weights for MLPs. needs PointMLP and EdgeMLP (both need same
%   num output channels)
% return:
%   centerFeatures - 1xnumOutputFeatures
%TODO: add coverage weights(don't understand these)
%       add context pooling / add semantic relationship to edge attention
%       is geometric relation right?
function [centerFeatures] = gridContextAggregation(center, nodePoints, nodeFeatures, params)
    numNodes = size(nodePoints, 1);
    %numOutputChannels = 0; %TODO get from func params or params MLP output size?
    numOutputChannels = size(params.PointMLP.Perceptron(end).Conv.Bias, 1);
    nodeContributions = dlarray(zeros(numNodes, numOutputChannels), 'SC'); %features each node will contribute to center features DATAFORMAT HERE??
    
    for i = 1:numNodes
        newNodeFeatures = sharedMLP(nodeFeatures(i,:), params.PointMLP.Perceptron);%TODO
        
        edgeFeat = geoEdgeAttention(center, nodePoints(i,:), params.EdgeMLP);
        nodeContribution = newNodeFeatures .* edgeFeat;
        nodeContributions(i,:) = nodeContribution;
    end
    centerFeatures = maxpool(nodeContributions, 'global'); %MIGHT NEED DATAFORMAT    
        
        
    
    function [edgeFeature] = geoEdgeAttention(center, nodePoint, params)
        edgeFeature = sharedMLP(center - nodePoint, params.Perceptron);
    end
end