% params:
%   center - 1x3xB group center point
%   nodePoints - kx3xB points in group
%   nodeFeatures - kxnumInputFeaturesxB, features for each group node from
%                   prev layers
%   params - weights for MLPs. needs PointMLP and EdgeMLP (both need same
%   num output channels)
% return:
%   centerFeatures - 1xnumOutputFeaturesxB
%TODO: add coverage weights(don't understand these)
%       add context pooling / add semantic relationship to edge attention
%       is geometric relation right?
function [centerFeatures] = gridContextAggregation(center, nodePoints, nodeFeatures, params)
    numNodes = size(nodePoints, 1);
    %numOutputChannels = 0; %TODO get from func params or params MLP output size?
    numOutputChannels = size(params.PointMLP.Perceptron2.learnables{2}, 1);
    numBatches = size(center, 3);
    nodeContributions = dlarray(zeros(numNodes, numOutputChannels, numBatches), 'SCB'); %features each node will contribute to center features DATAFORMAT HERE??
    
    for i = 1:numNodes
        newNodeFeatures = sharedMLP(nodeFeatures(i,:,:), params.PointMLP);%TODO
        
        edgeFeat = geoEdgeAttention(center, nodePoints(i,:,:), params.EdgeMLP);
        nodeContribution = newNodeFeatures .* edgeFeat;
        nodeContributions(i,:,:) = nodeContribution;
    end
    centerFeatures = maxpool(nodeContributions, 'global'); %MIGHT NEED DATAFORMAT    
        
        
    
    function [edgeFeature] = geoEdgeAttention(center, nodePoint, params)
        edgeFeature = sharedMLP(center - nodePoint, params);
    end
end