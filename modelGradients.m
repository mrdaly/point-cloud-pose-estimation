% params:
%   X - nx3 dlarray, I guess 1024
%   Y - 15x3 dlarray
%   parameters - params needed for gridgcn
function [gradients, loss] = modelGradients(X,Y,parameters) %TODO add accuracy to return parameters
    YPred = gridGCN(X, parameters);
    
    %compute loss
    loss = mse(YPred, Y, 'DataFormat', 'SC');
    gradients = dlgradient(loss,parameters);
end