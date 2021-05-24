%params:
%   points - Nx3xB dlarray containing x,y,z points          %TODO also pass in point center weights
%   m - scalar, number of center points to sample
%   numVoxels - 1x3
%   k - scalar, number of neighborhood points for each center point
%   nhood - scalar, must be odd, defines nhoodxnhoodxnhood neighborhood
%   with nhood at center
%return:
%   centers - Mx3xB dlarray, group centers
%   pointIndices - MxkxB array of group's points' indices into given point
%               cloud. need indices b/c we'll also need to index into the
%               features for those points
%   %%TODO: add center weight to be returned
function [centers, pointIndices] = coverageAwareGridQuery(points, m, k, voxelsSize, nhood)
    numBatches = size(points,3);
    centers = dlarray(zeros([m,3,numBatches]),'SCB');
    pointIndices = zeros([m,k,numBatches]);
    for b = 1:numBatches
    
        ptCloud = pointCloud(extractdata(points(:,:,b)));
        voxels = pcbin(ptCloud, voxelsSize); %in voxelizing, in the paper they only add up to a certain number of points for each voxel, here we add all points in the voxel to the voxel
        %get occupied voxels   TODO: edit pcbin.m to return indices of occupied bins
        occupiedIndices = [];
        for i = 1:length(voxels(:))
            if ~isempty(voxels{i})
                occupiedIndices = [occupiedIndices i];
            end
        end

        %sample center voxels using random sampling TODO: implement coverage aware sampling
        %centerVoxelIndices = occupiedIndices(randperm(length(occupiedIndices), m)); %gets linear indices into voxels
        centerVoxelIndices = occupiedIndices(randi(length(occupiedIndices), [1 m])); % changed to allow repetitions

        for i = 1:length(centerVoxelIndices)
            [centerX, centerY, centerZ] = ind2sub(voxelsSize, centerVoxelIndices(i));
            nhoodPtIndices = getAllNhoodPointIndices([centerX, centerY, centerZ], voxels, nhood);

            % randomly choose k pts from nhood
            numGroupPoints = min(k, length(nhoodPtIndices));
%             groupPtIndices = nhoodPtIndices(randperm(length(nhoodPtIndices), numGroupPoints)); %NOW IM NOT SURE IF THIS SHOULD BE RANDOM WITH REPETITIONS ALLOWed?
            groupPtIndices = nhoodPtIndices(randi(length(nhoodPtIndices), [k,1]));
            % compute center point
            groupPoints = points(groupPtIndices, :);
            groupCenter = pointCentroid(groupPoints);

            centers(i,:,b) = groupCenter;
            pointIndices(i,:,b) = groupPtIndices;
        end

    end
    
    %center must be in voxels, nhood must be odd
    function [nhoodPtIndices] = getAllNhoodPointIndices(center, voxels, nhoodSize)
        %use meshgrid?
        Xcenter = center(1);
        Ycenter = center(2);
        Zcenter = center(3);
        
        halfNhood = floor(nhoodSize / 2);
        Xmin = max(1, Xcenter - halfNhood);
        Xmax = min(size(voxels,1), Xcenter + halfNhood);
        Ymin = max(1, Ycenter - halfNhood);
        Ymax = min(size(voxels,2), Ycenter + halfNhood);
        Zmin = max(1, Zcenter - halfNhood);
        Zmax = min(size(voxels,3), Zcenter + halfNhood);
        
        nhoodPtIndices = []; %ENFORCE max num of points per voxel here???? PROBABLY YES
        %TODO: probably can just index nhood and aggregate indices
        for x = Xmin:Xmax %ONLY LOOK IN OCCUPIED VOXELS HERE? OR JUST LOOK AT ALL IN NHOOD? probs just all
            for y = Ymin:Ymax
                for z = Zmin:Zmax
                    indices = voxels{x, y, z};
                    nhoodPtIndices = [nhoodPtIndices indices'];
                end
            end
        end
    end

    function [centroid] = pointCentroid(points) %Could be one line
       XMean = mean(points(:,1)); 
       YMean = mean(points(:,2)); 
       ZMean = mean(points(:,3)); 
       centroid = [XMean, YMean, ZMean];
    end
end