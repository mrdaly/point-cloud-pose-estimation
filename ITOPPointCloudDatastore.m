classdef ITOPPointCloudDatastore < matlab.io.Datastore

    properties(SetAccess = protected)
        NumObservations
    end
    properties(Access = private)
        % This property is inherited from Datastore
        CurrentFileIndex
        PtCloudFile
        LabelsFile
        Indices
    end

    methods
        function ds = ITOPPointCloudDatastore(ptCloudFile, ...
                labelsFile, ...
                startIndex, ...
                endIndex)
            ds.PtCloudFile = ptCloudFile;
            ds.LabelsFile = labelsFile;
            %info = h5info(dataFile);
            ds.Indices = startIndex:endIndex;
            ds.NumObservations = length(ds.Indices);
            ds.CurrentFileIndex = 1;
        end
        
        function tf = hasdata(ds)
            tf = ds.CurrentFileIndex <= ds.NumObservations;
        end
        
        function reset(ds)
            ds.CurrentFileIndex = 1;
        end
        
        function [data, info] = read(ds)
            if ~hasdata(this)
                error('Reached end of data. Reset datastore.');
            end
            info = struct;
            
            data = cell(1,4); %X(nx3), Y(15x3), Maxes, Mins
            
            data_idx = ds.Indices(ds.CurrentFileIndex);
            
            ptCloud = h5read(ds.PtCloudFile, '/data', [1 1 data_idx], [3, 76800, 1]);
            ptCloud = ptCloud';
            
            %select 1024
            ptCloudObj = pointCloud(ptCloud);
            percentage = 1024/ptCloudObj.Count;
            ptCloudObj = pcdownsample(ptCloudObj, 'random', percentage);
            ptCloud = ptCloudObj.Location;
            
            maxes = [max(ptCloud(:,1)), max(ptCloud(:,2)), max(ptCloud(:,3))];
            mins = [min(ptCloud(:,1)), min(ptCloud(:,2)), min(ptCloud(:,3))];
            %normalize
            ptCloud = normalizePoints(ptCloud, maxes,mins);
            
            %get labels
            labels = h5read(ds.LabelsFile, '/real_world_coordinates', [1 1 data_idx], [3 15 1]);
            labels = labels';
            labels = normalizePoints(labels,maxes,mins);
            
            %create  dlarrays and return
            dlX = dlarray(ptCloud, 'SC');
            dlY = dlarray(labels, 'SC');
            data{1} = dlX;
            data{2} = dlY;
            data{3} = maxes;
            data{4} = mins;           
        end
    end
    methods (Hidden = true)
        function frac = progress(ds)
            % Determine percentage of data read from datastore
            frac = (ds.CurrentFileIndex - 1) / ds.NumObservations;
        end
    end
end
