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
function [newPoints, newPointsFeatures] = gridConv(points, pointsFeatures, m, k, voxelsSize, nhood, params)
    groups = coverageAwareGridQuery(points, m, k, voxelsSize, nhood);
    
    newPoints = zeros([m 3]);
    numOutputChannels = 0; %TODO get from func params or params MLP output size?
    newPointsFeatures = zeros([m, numOutputChannels]);
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