%TODO add batch norm
function [params] = initializeSharedMLP(inputChannelSize,hiddenChannelSize, outchnlsz)
    weights = initializeWeightsHe([1 inputChannelSize hiddenChannelSize]);
    bias = zeros(hiddenChannelSize,1,"single");
    params.Perceptron1.learnables{1} = dlarray(weights);
    params.Perceptron1.learnables{2} = dlarray(bias);
    
    weights = initializeWeightsHe([1 hiddenChannelSize outchnlsz]);
    bias = zeros(outchnlsz,1,"single");
    params.Perceptron2.learnables{1} = dlarray(weights);
    params.Perceptron2.learnables{2} = dlarray(bias);

end
