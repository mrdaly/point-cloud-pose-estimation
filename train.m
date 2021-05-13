%% Get datastores
trainLabelsFile = fullfile('Z:\50\mattdaly.Bmain.j1669705','ITOP_side_train_labels.h5');
trainPtCloudFile = fullfile('Z:\50\mattdaly.Bmain.j1669705','ITOP_side_train_point_cloud.h5');
dsInfo = h5info(trainPtCloudFile);
dsSize = dsInfo.Datasets(2).Dataspace.Size;
trainBeginIdx = 1;
trainEndIdx = floor(0.8*dsSize);
valBeginIdx = trainEndIdx + 1;
valEndIdx = dsSize;
%dsTrain
dsTrain = ITOPPointCloudDatastore(trainPtCloudFile,trainLabelsFile, trainBeginIdx, trainEndIdx);
dsVal = ITOPPointCloudDatastore(trainPtCloudFile,trainLabelsFile, valBeginIdx, valEndIdx);

trainMbq = minibatchqueue(dsTrain,'MiniBatchSize', 2);

%% initialize model parameters
modelParameters = initializeGridGCN();

%% specify training options
numEpochs = 1;
learnRate = 0.001;
learnRateDropPeriod = 60;
learnRateDropFactor = 0.7;
%gradientDecayFactor = 0.9;%beta1 these seem to be defaults in matlab
%squaredGradientDecayFactor = 0.999;%beta2

validationFrequency = 1000;
printFrequency = 100;

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
        
        %read data, XTrain - 1024x3, YTrain - 
        data = read(dsTrain);
        XTrain = data{1};
        YTrain = data{2};
        
        [gradients, loss] = dlfeval(@modelGradients, XTrain, YTrain, modelParameters);
        
        %update with adam
        [modelParameters, avgGradients, avgSquaredGradients] = adamupdate(modelParameters, gradients, ...
            avgGradients, avgSquaredGradients, iteration);
        
%         if mod(iteration, validationFrequency) == 0          
%             %validate
%             validationLosses = [];
%             count_within_10_cm = zeros(1,15);
%             countEvaluated = 0;
%             while hasdata(dsVal)
%                 %get validation data, XValidation and YValidation
%                 data = read(dsVal);
%                 XValidation = data{1};
%                 YValidation = data{2};
%                 dlYPredValidation = gridGCN(XValidation, modelParameters);
%                 lossValidation = mse(dlYPredValidation, YValidation, 'DataFormat', 'SC');
%                 validationLosses = [validationLosses lossValidation];
%                 
%                 %count for accuracy
%                 maxes = data{3};
%                 mins = data{4};
%                 for kp = 1:15
%                     trueKeypoint = YValidation(kp,:);
%                     predictedKeypoint = dlYPredValidation(kp,:);
%                     predictedKeypoint = deNormalizePoint(predictedKeypoint, maxes,mins);
%                     dist = norm(predictedKeypoint - trueKeypoint);
%                     if dist < 0.1
%                         count_within_10_cm(kp) = count_within_10_cm(kp) + 1;
%                     end
%                 end
%                 countEvaluated = countEvaluated + 1;
%             end
%             avgValidationLoss = mean(validationLosses);
%             validation_mAP = mean(count_within_10_cm ./ countEvaluated);
%             
%             %show progress
%             time = duration(0,0,toc(start), 'Format', 'hh:mm:ss');
%             %print time,epoch,iteration,loss, avgValidationLoss,
%             avgValidationLoss = gather(extractdata(avgValidationLoss));
%             avgValidationLoss = compose('%.4f',avgValidationLoss);
%             validation_mAP = compose('%.4f', validation_mAP);
%             trainLoss = gather(extractdata(loss));
%             trainLoss = compose('%.4f', trainLoss);
%             disp('time: ' + string(time) + ' | ' + ...
%                 'epoch: ' + string(epoch) + ' | ' + ...
%                 'iteration: ' + string(iteration) + ' | ' + ...
%                 'trainLoss: ' + string(trainLoss) + ' | ' + ...
%                 'avgValidationLoss: ' + string(avgValidationLoss) + ' | ' + ...
%                 'validation_mAP: ' + string(validation_mAP));
%             
%         end
        if iteration == 1 || mod(iteration, printFrequency) == 0 %print on first iteration
            time = duration(0,0,toc(start), 'Format', 'hh:mm:ss');
            %print time,epoch,iteration,loss
            trainLoss = gather(extractdata(loss));
            trainLoss = compose('%.4f', trainLoss);
            disp('time: ' + string(time) + ' | ' + ...
                'epoch: ' + string(epoch) + ' | ' + ...
                'iteration: ' + string(iteration) + ' | ' + ...
                'trainLoss: ' + string(trainLoss) + ' | ' );
        end
    end
    
end