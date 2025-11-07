%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Hardik Y. Patil                                                      %
% Email: hardikyp@umich.edu                                                    %
% Date: September 10, 2025                                                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% This function generates mapping of individual element DOFs with respect to
% the global collection of DOFs.
%
% Inputs:
% -------
% identity (array): index identifier of the current bar element
% links (array): angle of the bar (radian) wrt global coordinate system
% springs (array): Modulus of elasticity of the bar element
%
% Outputs:
% --------
% mapBars (array): Mapping of local DOFs wrt global for bars (nBars, 4)
% mapSprings (array): Mapping of local DOFs wrt global for springs (nSpr, 6)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [mapBars, mapSprings] = generateMapping(identity, links, springs)
mapBars = [identity(links(:, 1), :), identity(links(:, 2), :)];
mapSprings = [identity(springs(:, 1), :), ...
              identity(springs(:, 2), :), ...
              identity(springs(:, 3), :)];
end