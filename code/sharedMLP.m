function [dlY] = sharedMLP(dlX,parameters)
    dlY = dlX;
%     for k = 1:numel(parameters) 
%         [dlY] = perceptron(dlY,parameters(k));
%     end
    dlY = perceptron(dlY,parameters.Perceptron1);
    dlY = perceptron(dlY,parameters.Perceptron2);
end