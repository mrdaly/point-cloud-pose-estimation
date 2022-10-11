%ptCloud - nx3, keypoints - 15x3
function showPose(points, keypoints)
    pcshow(points, [0 0 1], 'VerticalAxis', 'Y', 'MarkerSize', 10)
    hold on
    pcshow(keypoints, [1 0 0], 'VerticalAxis', 'Y', 'MarkerSize', 100)
end