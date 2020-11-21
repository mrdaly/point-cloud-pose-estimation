%normalize pose point labels (3x15), maxes 1x3, mins 1x3
function [normalizedLabels] = normalizeLabelsPoints(labelsPoints, maxes, mins)
    normalizedLabels = (labelsPoints - mins') ./ (maxes' - mins');
end