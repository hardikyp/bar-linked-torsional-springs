%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Hardik Y. Patil                                                      %
% Email: hardikyp@umich.edu                                                    %
% Date: October 19, 2025                                                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% This function draws a circular node.
%
% Inputs:
% -------
% x (array): X coordinate of the node
% y (array): Y coordinate of the node
% r (float): Radius of the node circle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function drawNode(x, y, r)
    rectangle('Position', [x - r, y - r, 2 * r, 2 * r], ... 
              'Curvature', 1.0, ...
              'FaceColor', 'k', ...
              'EdgeColor', 'none');
end