% params:
%   points - nx3
%   pointsFeatures - nxnumInputChannels
%   m - scalar, num points to choose
%   k - scalar, num points in each group
%   voxelsSize - 1x3, voxel grid size
%   nhood - scalar, neighborhood cube size to look around center voxel when
%           finding k group nodes. must be odd and >1
%   params - learnable weights for mlps, must have PointMLP and EdgeMLP
% return:
%   newPoints - mx3, 
%   newPointsFeatures - mxnumOutputChannels
function [newPoints, newPointsFeatures] = gridConv(points, pointsFeatures, m, k, voxelsSize, nhoodSize, params)
    groups = coverageAwareGridQuery(points, m, k, voxelsSize, nhoodSize);
    
    newPoints = dlarray(zeros([m 3]), 'SC');
    %numOutputChannels = 0; %TODO get from func params or params MLP output size?
    numOutputChannels = size(params.PointMLP.Perceptron(end).Bias, 1);
    newPointsFeatures = dlarray(zeros([m, numOutputChannels]), 'SC');%SHOULD I DO THIS OR CREATE CELL ARRAY AND CONCAT ALL FEATURES AT THE END?... ALSO DATAFORMAT HERE?
    for i = 1:size(groups,1)
        centerPoint = groups{i,1};
        groupPointsIndices = groups{i,2};
        
        pointFeatures = gridContextAggregation(centerPoint, ...
                                               points(groupPointsIndices,:), ...
                                               pointsFeatures(groupPointsIndices, :), ...
                                               params);
        newPoints(i,:) = centerPoint;
        newPointsFeatures(i,:) = pointFeatures;
    end
end