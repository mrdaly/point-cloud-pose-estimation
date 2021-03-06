% params: 
%   points - nx3xB
%   pointsFeatures - nxnumInputChannelsxB
%   m - scalar, num points to choose
%   k - scalar, num points in each group
%   voxelsSize - 1x3, voxel grid size
%   nhood - scalar, neighborhood cube size to look around center voxel when
%           finding k group nodes. must be odd and >1
%   params - learnable weights for mlps, must have PointMLP and EdgeMLP
% return:
%   newPoints - mx3xB, 
%   newPointsFeatures - mxnumOutputChannelsxB
function [newPoints, newPointsFeatures] = gridConv(points, pointsFeatures, m, k, voxelsSize, nhoodSize, params)
    [centers,pointIndices] = coverageAwareGridQuery(points, m, k, voxelsSize, nhoodSize);
    
    numBatches = size(points,3);
    newPoints = dlarray(zeros([m 3 numBatches]), 'SCB');
    %numOutputChannels = 0; %TODO get from func params or params MLP output size?
    numOutputChannels = size(params.PointMLP.Perceptron2.learnables{2}, 1);
    newPointsFeatures = dlarray(zeros([m, numOutputChannels numBatches]), 'SCB');%SHOULD I DO THIS OR CREATE CELL ARRAY AND CONCAT ALL FEATURES AT THE END?... ALSO DATAFORMAT HERE?
    for i = 1:m
        centerPoint = centers(i,:,:);
        groupPointsIndices = squeeze(pointIndices(i,:,:)); %kxB
        
        numInputFeatures = size(pointsFeatures,2);
        nodePoints = dlarray(zeros([k,3,numBatches]), 'SCB');
        nodeFeatures = dlarray(zeros([k,numInputFeatures,numBatches]), 'SCB');
        for b = 1:numBatches
            nodePoints(:,:,b) = points(groupPointsIndices(:,b),:,b);%is this right??
            nodeFeatures(:,:,b) = pointsFeatures(groupPointsIndices(:,b),:,b);
        end 
        
        accfun = dlaccelerate(@gridContextAggregation);
        pointFeatures = accfun(centerPoint, ...
                                               nodePoints, ...
                                               nodeFeatures, ...
                                               params);
        newPoints(i,:,:) = centerPoint;
        newPointsFeatures(i,:,:) = pointFeatures;
    end
end