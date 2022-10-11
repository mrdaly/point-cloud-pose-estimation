%% get network to evaluate
% itop_cnn_v2_net = load('itop_cnn_v2_net.mat');
% net = itop_cnn_v2_net.net;
itop_cnn_v3_net = load('itop_cnn_v3_net.mat');
net = itop_cnn_v3_net.itop_cnn_v3_net;


%% create itop test datastore
test_data_file = fullfile('ITOP_side_test_depth_map.h5', 'ITOP_side_test_depth_map.h5');
test_labels_file = fullfile('ITOP_side_test_labels.h5', 'ITOP_side_test_labels.h5');
test_ptCloud_file = fullfile('ITOP_side_test_point_cloud.h5', 'ITOP_side_test_point_cloud.h5');
dsInfo = h5info(test_data_file);
dsSize = dsInfo.Datasets(2).Dataspace.Size;
testDs = DepthMapEvalDatastore(test_data_file, ...
                               test_labels_file, ...
                               test_ptCloud_file,[224 224],1, dsSize);

%% evaluate
NUM_KEYPOINTS = 15;

count_within_10_cm = zeros(1,15);
count_evaluated = 0;

while hasdata(testDs)
    data = read(testDs);
    depth_image = data{1,1};
    depth_image = depth_image{1};
    keypoints = data{1,2};
    keypoints = keypoints{1};
    keypoints = reshape(keypoints, [3 15]);
    maxes = data{1,3};
    maxes = maxes{1};
    mins = data{1,4};
    mins = mins{1};
    
    predicted_keypoints = predict(net,depth_image);
    %MADE MISTAKE< DIDNT RESIZE??
    predicted_keypoints = reshape(predicted_keypoints,[3 15]);
    for i = 1:NUM_KEYPOINTS
        keypoint = keypoints(:,i);
        predicted_keypoint = predicted_keypoints(:,i);
        %de-normalize keypoint
        predicted_keypoint = deNormalizeKeyPoint(predicted_keypoint, maxes, mins);
        dist = norm(predicted_keypoint - keypoint);
        
        if dist < 0.1
            count_within_10_cm(i) = count_within_10_cm(i) + 1;
        end
    end
    count_evaluated = count_evaluated + 1;
end

AP = count_within_10_cm ./ count_evaluated
mAP = mean(AP)