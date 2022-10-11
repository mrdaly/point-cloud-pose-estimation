classdef DepthMapDatastore < matlab.io.Datastore & ...
                            matlab.io.datastore.MiniBatchable & ...
                            matlab.io.datastore.Shuffleable

properties
    MiniBatchSize
end
properties(SetAccess = protected)
    NumObservations
end
properties(Access = private)
    % This property is inherited from Datastore
    CurrentFileIndex
    DataFile
    LabelsFile
    PtCloudFile
    Indices
    NetworkInputSize
end

methods
    function ds = DepthMapDatastore(dataFile, ...
                                    labelsFile, ...
                                    ptCloudFile, ...
                                    batchSize, ...
                                    netInputSize, ...
                                    startIndex, ...
                                    endIndex)
       ds.MiniBatchSize = batchSize;
       ds.DataFile = dataFile;
       ds.LabelsFile = labelsFile;
       ds.PtCloudFile = ptCloudFile;
       ds.NetworkInputSize = netInputSize;
       %info = h5info(dataFile);
       ds.Indices = startIndex:endIndex;
       ds.NumObservations = length(ds.Indices);
       ds.CurrentFileIndex = 1;
       
    end
    
    function tf = hasdata(ds)
        tf = ds.CurrentFileIndex + ds.MiniBatchSize - 1 ...
                <= ds.NumObservations;
    end
    
    function [data, info] = read(ds)
        info = struct;
        
        X = cell([ds.MiniBatchSize, 1]);
        Y = cell([ds.MiniBatchSize, 1]);
        
        for i = 1:ds.MiniBatchSize
            data_idx = ds.Indices(ds.CurrentFileIndex);
            depth_image = h5read(ds.DataFile, '/data', [1 1 data_idx], [320, 240, 1]);
            depth_image = depth_image';
            depth_image = imresize(depth_image, ds.NetworkInputSize);
            depth_image = normalizeDepthImage(depth_image);
            depth_image = repmat(depth_image, 1, 1, 3);
            X{i,1} = depth_image;
            coords = h5read(ds.LabelsFile, '/real_world_coordinates', [1 1 data_idx], [3 15 1]);
            
            % read point cloud
            ptCloud = h5read(ds.PtCloudFile, '/data', [1 1 data_idx], [3, 76800, 1]);
            ptCloud = squeeze(ptCloud);%?
            % find x,y,z maxes and x,y,z mins
            xMax = max(ptCloud(1,:));
            xMin = min(ptCloud(1,:));
            yMax = max(ptCloud(2,:));
            yMin = min(ptCloud(2,:));
            zMax = max(ptCloud(3,:));
            zMin = min(ptCloud(3,:));
            maxes = [xMax yMax zMax];
            mins = [xMin yMin zMin];
            
            %squeeze?
            coords = normalizeLabelsPoints(squeeze(coords), maxes, mins);
            
            coords = coords(:);
            coords = reshape(coords, [1 1 45]);
            Y{i,1} = coords;
            
            ds.CurrentFileIndex = ds.CurrentFileIndex + 1;
        end
        data = table(X,Y);
    end
    
    function reset(ds)
       ds.CurrentFileIndex = 1; 
    end
    
    function dsNew = shuffle(ds)
        ds.Indices = randperm(ds.NumObservations);
        dsNew = copy(ds);
    end
end
methods (Hidden = true)
    function frac = progress(ds)
        % Determine percentage of data read from datastore
        frac = (ds.CurrentFileIndex - 1) / ds.NumObservations;
    end
end
end