%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Hardik Y. Patil                                                      %
% Email: hardikyp@umich.edu                                                    %
% Date: September 10, 2025                                                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% This function generates the stiffness matrix for a 2D bar element capable of 
% carrying only an axial force in its local axes.
% 
% Inputs:
% -------
% E (float): Modulus of elasticity of the bar element
% A (float): Area of the bar element
% L (float): Length of the bar element.
%
% Outputs:
% --------
% kLocal (array): local stiffness matrix of 2D bar element (4, 4)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [kLocal] = barStiffness(E, A , L)
kLocal = E * A / L * [ 1, 0, -1, 0;
                       0, 0,  0, 0;
                      -1, 0,  1, 0;
                       0, 0,  0, 0];
end
