%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Hardik Y. Patil                                                      %
% Email: hardikyp@umich.edu                                                    %
% Date: September 10, 2025                                                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% This function generates the local geometric stiffness matrix for a bar element 
% based on the internal force observed in the bar.
%
% Inputs:
% -------
% F (float): Axial force value in the bar element
% L (float): Current length of the bar element
%
% Outputs:
% --------
% kGeom (array): Bar geometric stiffness matrix in local coordinates (4, 4) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [kGeom] = geomStiffness(F, L)
kGeom = F / L * [ 1,  0, -1,  0;
                  0,  1,  0, -1;
                 -1,  0,  1,  0;
                  0, -1,  0,  1];
end