function [dlY] = sharedMLP(dlX,parameters)
    dlY = dlX;
    for k = 1:numel(parameters) 
        [dlY] = perceptron(dlY,parameters(k));
    end
end