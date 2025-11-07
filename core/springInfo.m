%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Hardik Y. Patil                                                      %
% Email: hardikyp@umich.edu                                                    %
% Date: October 19, 2025                                                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% This function calculates relative angle between the bars connected to the 
% torsional spring element.
%
% Inputs:
% -------
% coords (array): Nodal coordinates of the structure (nNodes, 2)
% springs (Array): Connectivity of the spring members (nSpr, 3)
%
% Outputs:
% --------
% alpha (array): Relative angle between bars connected to the spring members
%                (nSpr, 1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [alpha] = springInfo(coords, springs)
r1 = coords(springs(:, 1), :)'; 
r2 = coords(springs(:, 2), :)'; 
r3 = coords(springs(:, 3), :)';
a = r1 - r2;
b = r3 - r2;
N = [0 -1; 1 0];
C = dot(a, b, 1);
S = dot(a, N * b, 1);
alpha = mod(atan2(S, C) + 2 * pi, 2 * pi)';
end