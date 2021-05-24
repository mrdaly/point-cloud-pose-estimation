%TODO add batch norm
function [dlY] = perceptron(dlX,parameters)
    % Convolution.
    W = parameters.learnables{1};
    B = parameters.learnables{2};
    dlY = dlconv(dlX,W,B);

    % ReLU.
    dlY = relu(dlY);
end