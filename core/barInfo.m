%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Hardik Y. Patil                                                      %
% Email: hardikyp@umich.edu                                                    %
% Date: September 10, 2025                                                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% This function calculates the length and angle of each bar element in the
% truss system.
%
% Inputs:
% -------
% coords (array): nodal coordinates of the truss (nNodes, 2)
% links (array): bar connectivity between nodes (nBars, 2)
%
% Outputs:
% --------
% L (array): lengths of all bars in the truss (nBars, 1)
% theta (array): angles of all bars in radians with respect to global 
%                X-axis (nBars, 1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [L, theta] = barInfo(coords, links)
D = coords(links(:, 2), :) - coords(links(:, 1), :);
L = sqrt(sum(D.^2, 2));
theta = atan2(D(:, 2), D(:, 1));
end