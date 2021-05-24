%% Get datastores
trainLabelsFile = fullfile('//mathworks','devel','sbs','50','mattdaly.Bmain.j1669705','ITOP_side_train_labels.h5');
trainPtCloudFile = fullfile('//mathworks','devel','sbs','50','mattdaly.Bmain.j1669705','ITOP_side_train_point_cloud.h5');
dsInfo = h5info(trainPtCloudFile);
dsSize = dsInfo.Datasets(2).Dataspace.Size;
trainBeginIdx = 1;
trainEndIdx = floor(0.8*dsSize);
valBeginIdx = trainEndIdx + 1;
valEndIdx = dsSize;
%dsTrain
dsTrain = ITOPPointCloudDatastore(trainPtCloudFile,trainLabelsFile, trainBeginIdx, trainEndIdx);
dsVal = ITOPPointCloudDatastore(trainPtCloudFile,trainLabelsFile, valBeginIdx, valEndIdx);

trainMbq = minibatchqueue(dsTrain,'MiniBatchSize', 16, ...
    'OutputAsDlarray', [true true false false], ...
    'MiniBatchFormat', {'SCB', 'CB', '', ''}, ...
    'OutputEnvironment', {'gpu','gpu','cpu','cpu'});
valMbq = minibatchqueue(dsVal,'MiniBatchSize', 16, ...
    'OutputAsDlarray', [true true false false], ...
    'MiniBatchFormat', {'SCB', 'CB', '', ''}, ...
    'OutputEnvironment', {'gpu','gpu','cpu','cpu'});

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
printFrequency = 1;

%% training loop
%used for adam
% avgGradients = [];
% avgSquaredGradients = [];
% 
% %initializeVerboseOutput or progress plot?
% 
% iteration = 0;
start = tic;
% for epoch = 1:numEpochs
%     %reset train and val datastores, shuffle?
%     shuffle(trainMbq);
    while hasdata(trainMbq)
        iteration = iteration + 1;
        
        %read data, XTrain - 1024x3xB, YTrain - 45xB
        [XTrain,YTrain] = next(trainMbq);
        
        [gradients, loss] = dlfeval(@modelGradients, XTrain, YTrain, modelParameters);
        
        %update with adam
        [modelParameters, avgGradients, avgSquaredGradients] = adamupdate(modelParameters, gradients, ...
            avgGradients, avgSquaredGradients, iteration);
        
%         if mod(iteration, validationFrequency) == 0          
%             %validate
%             validationLosses = [];
%             count_within_10_cm = zeros(1,15);
%             countEvaluated = 0;
%             while hasdata(valMbq)
%                 %get validation data, XValidation and YValidation
%                 [XValidation,YValidation, maxes, mins] = next(valMbq);
%                 dlYPredValidation = gridGCN(XValidation, modelParameters);
%                 lossValidation = mse(dlYPredValidation, YValidation);
%                 validationLosses = [validationLosses lossValidation];
%                 
%                 %count for accuracy
% 
% %                 for kp = 1:15
% %                     trueKeypoint = YValidation(kp,:);
% %                     predictedKeypoint = dlYPredValidation(kp,:);
% %                     predictedKeypoint = deNormalizePoint(predictedKeypoint, maxes,mins);
% %                     dist = norm(predictedKeypoint - trueKeypoint);
% %                     if dist < 0.1
% %                         count_within_10_cm(kp) = count_within_10_cm(kp) + 1;
% %                     end
% %                 end
% %                 countEvaluated = countEvaluated + 1;
%             end
%             avgValidationLoss = mean(validationLosses);
% %             validation_mAP = mean(count_within_10_cm ./ countEvaluated);
%             
%             %show progress
%             time = duration(0,0,toc(start), 'Format', 'hh:mm:ss');
%             %print time,epoch,iteration,loss, avgValidationLoss,
%             avgValidationLoss = gather(extractdata(avgValidationLoss));
%             avgValidationLoss = compose('%.4f',avgValidationLoss);
% %             validation_mAP = compose('%.4f', validation_mAP);
%             trainLoss = gather(extractdata(loss));
%             trainLoss = compose('%.4f', trainLoss);
%             disp('time: ' + string(time) + ' | ' + ...
%                 'epoch: ' + string(epoch) + ' | ' + ...
%                 'iteration: ' + string(iteration) + ' | ' + ...
%                 'trainLoss: ' + string(trainLoss) + ' | ' + ...
%                 'avgValidationLoss: ' + string(avgValidationLoss) + ' | ');
% %                 'avgValidationLoss: ' + string(avgValidationLoss) + ' | ' + ...
% %                 'validation_mAP: ' + string(validation_mAP));
% 
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
    
% end