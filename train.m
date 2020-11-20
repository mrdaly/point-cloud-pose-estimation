%% Get datastores
%dsTrain
%dsVal

%% initialize model parameters
modelParameters = initializeGridGCN();

%% specify training options
numEpochs = 40;
learnRate = 0.001;
learnRateDropPeriod = 60;
learnRateDropFactor = 0.7;
%gradientDecayFactor = 0.9;%beta1 these seem to be defaults in matlab
%squaredGradientDecayFactor = 0.999;%beta2

validationAndPrintFrequency = 1000;

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
        
        %read data, XTrain - 1024x3xbatchSize, YTrain - 15x3xbatchSize
        
        [gradients, loss] = dlfeval(@modelGradients, XTrain, YTrain, modelParameters);
        
        %update with adam
        [modelParameters, avgGradients, avgSquaredGradients] = adamupdate(modelParameters, ...
            avgGradients, avgSquaredGradients, iteration);
        
        if iteration == 1 || mod(iteration, validationAndPrintFrequency) == 0
            %show progress
            time = duration(0,0,toc(start), 'Format', 'hh:mm:ss');
            %...
            
            %validate
            validationLosses = [];
            while hasdata(dsVal)
                %get validation data, XValidation and YValidation
                dlYPredValidation = gridGCN(XValidation, modelParameters);
                lossValidation = mse(dlYPredValidation, YValidation, 'DataFormat', 'SC');
                validationLosses = [validationLosses lossValidation];
            end
            avgValidationLoss = mean(validationLosses);
            
            %print time,epoch,iteration,loss, avgValidationLoss,
        end
    end
    
end