function [depthImage] = normalizeDepthImage(depthImage)
    imMax = max(depthImage(:));
    imMin = min(depthImage(:));
    depthImage = (depthImage - imMin) ./ (imMax - imMin);
end