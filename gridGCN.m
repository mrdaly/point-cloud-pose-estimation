% params:
%   dlx - nx3, input points  %TODO n must be defined, 1024?
%   params - learnable parameters, must have GridConv1, GridConv2,
%           GridConv3, FC1, FC2
% return:
%   dlY - 15x3, points for pose
%NOTE: fullly connected layers may not be accurate to paper, tried to
%figure it out from paper and other point cloud dl papers
function [dlY] = gridGCN(dlX, params)
    %these are all parameters used by paper for classification on
    %modelnet40
    M = [1024, 128, 1];
    voxelsSizes = [[40 40 40];[8 8 8];[1 1 1]]; %SHOULD I SKIP GRID QUERY WHEN THERE IS ONE VOXEL?
    K = [64 64 128];
    nhoodSizes = [7 3 1];
    
    [newPoints, dlY] = gridConv(dlX, dlX, M(1), K(1), voxelsSizes(1,:), nhoodSizes(1), params.GridConv1);
    
    [newPoints, dlY] = gridConv(newPoints, dlY, M(2), K(2), voxelsSizes(2,:), nhoodSizes(2), params.GridConv2);
    
    [~, dlY] = gridConv(newPoints, dlY, M(3), K(3), voxelsSizes(3,:), nhoodSizes(3), params.GridConv3);
    
    dlY = fullyconnect(dlY, params.FC1.Weights, params.FC1.Bias); %DATA FORMAT??
    
    dlY = fullyconnect(dlY, params.FC2.Weights, params.FC2.Bias);
    
    dlY = reshape(dlY, [15, 3]);
end