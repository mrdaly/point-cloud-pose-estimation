%% create resnet with 45 outputs, (x,y,z) for 15 key points
lgraph = resnet101('Weights', 'none');
layersToRemove = { 'data', 'fc1000', 'prob', 'ClassificationLayer_predictions'};
lgraph = removeLayers(lgraph, layersToRemove);
layersToAdd = [ fullyConnectedLayer(45, 'Name', 'fc45'), ...
                regressionLayer('Name', 'keypoints')];
lgraph = addLayers(lgraph, layersToAdd);
lgraph = connectLayers(lgraph, 'pool5', 'fc45');
lgraph = addLayers(lgraph, imageInputLayer([224, 224, 1], 'Name', 'data', 'Normalization', 'none'));
lgraph = connectLayers(lgraph, 'data', 'conv1');

%% create datastores
dataFile = fullfile('ITOP_side_train_depth_map.h5','ITOP_side_train_depth_map.h5');
labelsFile = fullfile('ITOP_side_train_labels.h5','ITOP_side_train_labels.h5');
dsInfo = h5info(dataFile);
dsSize = dsInfo.Datasets(2).Dataspace.Size;
trainBeginIdx = 1;
trainEndIdx = floor(0.7*dsSize);
valBeginIdx = trainEndIdx + 1;
valEndIdx = dsSize;

inputSize = [224 224];
miniBatchSize = 64;
trainDs = DepthMapDatastore(dataFile, ...
                            labelsFile, ...
                            miniBatchSize, ...
                            inputSize, ...
                            trainBeginIdx, trainEndIdx);
valDs = DepthMapDatastore(dataFile, ...
                           labelsFile, ...
                           miniBatchSize, ...
                           inputSize, ...
                           valBeginIdx, valEndIdx);
                       
 %% training
 options = trainingOptions('adam', 'MiniBatchSize', miniBatchSize, ...
                            'shuffle', 'every-epoch', ...
                            'ValidationData', valDs, ...
                            'ExecutionEnvironment', 'gpu');
net = trainNetwork(trainDs, lgraph, options);