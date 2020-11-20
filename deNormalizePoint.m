%point 1x3, maxes mins 1x3
function [point] = deNormalizePoint(point, maxes, mins)
    point = (point .* (maxes - mins)) + mins;
end