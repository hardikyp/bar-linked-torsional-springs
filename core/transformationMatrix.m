%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Hardik Y. Patil                                                      %
% Email: hardikyp@umich.edu                                                    %
% Date: October 19, 2025                                                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% This function generates the transformation matrix for a 2D bar element to go
% from its global to local coordinate system and vice versa
% 
% Inputs:
% -------
% theta (float): Angle (rad) of the bar element in global coordinate system
%                with respect to X-axis.
%
% Outputs:
% --------
% T (array): Transformation matrix for a 2D bar element (4, 4)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [T] = transformationMatrix(theta)
c = cos(theta);
s = sin(theta);
T = [ c, s,  0, 0;
     -s, c,  0, 0;
      0, 0,  c, s;
      0, 0, -s, c];
end