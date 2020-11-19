%TODO add batch norm
function [dlY] = perceptron(dlX,parameters)
    % Convolution.
    W = parameters.Conv.Weights;
    B = parameters.Conv.Bias;
    dlY = dlconv(dlX,W,B);

    % ReLU.
    dlY = relu(dlY);
end