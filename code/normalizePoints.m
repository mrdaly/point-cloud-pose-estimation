%points(nx3), maxes 1x3, mins 1x3
function [points] = normalizePoints(points, maxes, mins)
    points = (points - mins) ./ (maxes - mins);
end