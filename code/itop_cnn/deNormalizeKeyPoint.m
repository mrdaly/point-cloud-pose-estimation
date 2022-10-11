%keypoint 3x1, maxes mins 1x3
function [keypoint] = deNormalizeKeyPoint(keypoint, maxes, mins)
    keypoint = (keypoint .* (maxes' - mins')) + mins';
end