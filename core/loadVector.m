%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Hardik Y. Patil                                                      %
% Email: hardikyp@umich.edu                                                    %
% Date: October 19, 2025                                                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% This function convers external force information into a load vector. The top
% part of the load vector belongs to free dofs and the bottom part belongs to
% fixed dofs.
%
% Inputs:
% -------
% force (array): Force values acting on each dof of each node (nNodes, nDof)
% reshapeIdx (Array): Order of indexing for dofs based on fixity 
%                     (nNodes * nDofs, 1)
%
% Outputs:
% --------
% pSystem (array): System load vector (nNodes * nDof, 1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function pSystem = loadVector(force, reshapeIdx)
pSystem = zeros(numel(force), 1);
force = reshape(force.', [], 1);
pSystem(reshapeIdx) = force;
end