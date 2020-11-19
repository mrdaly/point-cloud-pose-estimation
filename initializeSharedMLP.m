%TODO add batch norm
function [params] = initializeSharedMLP(inputChannelSize,hiddenChannelSize)
    weights = initializeWeightsHe([1 1 inputChannelSize hiddenChannelSize(1)]);
    bias = zeros(hiddenChannelSize(1),1,"single");
    p.Conv.Weights = dlarray(weights);
    p.Conv.Bias = dlarray(bias);

    params.Perceptron(1) = p;

    for k = 2:numel(hiddenChannelSize)
        weights = initializeWeightsHe([1 1 hiddenChannelSize(k-1) hiddenChannelSize(k)]);
        bias = zeros(hiddenChannelSize(k),1,"single");
        p.Conv.Weights = dlarray(weights);
        p.Conv.Bias = dlarray(bias);

        params.Perceptron(k) = p;
    end
end
