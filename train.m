%% Get datastores
trainLabelsFile = fullfile('ITOP_side_train_labels.h5','ITOP_side_train_labels.h5');
trainPtCloudFile = fullfile('ITOP_side_train_point_cloud.h5','ITOP_side_train_point_cloud.h5');
dsInfo = h5info(trainPtCloudFile);
dsSize = dsInfo.Datasets(2).Dataspace.Size;
trainBeginIdx = 1;
trainEndIdx = floor(0.8*dsSize);
valBeginIdx = trainEndIdx + 1;
valEndIdx = dsSize;
%dsTrain
dsTrain = ITOPPointCloudDatastore(trainPtCloudFile,trainLabelsFile, trainBeginIdx, trainEndIdx);
dsVal = ITOPPointCloudDatastore(trainPtCloudFile,trainLabelsFile, valBeginIdx, valEndIdx);
%dsVal

%% initialize model parameters
modelParameters = initializeGridGCN();

%% specify training options
numEpochs = 1;
learnRate = 0.001;
learnRateDropPeriod = 60;
learnRateDropFactor = 0.7;
%gradientDecayFactor = 0.9;%beta1 these seem to be defaults in matlab
%squaredGradientDecayFactor = 0.999;%beta2

validationAndPrintFrequency = 100;

%% training loop
%used for adam
avgGradients = [];
avgSquaredGradients = [];

%initializeVerboseOutput or progress plot?

iteration = 0;
start = tic;
for epoch = 1:numEpochs
    %reset train and val datastores, shuffle?
    
    while hasdata(dsTrain)
        iteration = iteration + 1;
        
        %read data, XTrain - 1024x3, YTrain - 15x3
        data = read(dsTrain);
        XTrain = data{1};
        YTrain = data{2};
        
        [gradients, loss] = dlfeval(@modelGradients, XTrain, YTrain, modelParameters);
        
        %update with adam
        [modelParameters, avgGradients, avgSquaredGradients] = adamupdate(modelParameters, gradients, ...
            avgGradients, avgSquaredGradients, iteration);
        
        if iteration == 1 || mod(iteration, validationAndPrintFrequency) == 0          
            %validate
            validationLosses = [];
            while hasdata(dsVal)
                %get validation data, XValidation and YValidation
                data = read(dsVal);
                XValidation = data{1};
                YValidation = data{2};
                dlYPredValidation = gridGCN(XValidation, modelParameters);
                lossValidation = mse(dlYPredValidation, YValidation, 'DataFormat', 'SC');
                validationLosses = [validationLosses lossValidation];
            end
            avgValidationLoss = mean(validationLosses);
            
            %show progress
            time = duration(0,0,toc(start), 'Format', 'hh:mm:ss');
            %print time,epoch,iteration,loss, avgValidationLoss,
            
        end
    end
    
end