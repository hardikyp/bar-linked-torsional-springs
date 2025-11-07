%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Hardik Y. Patil                                                      %
% Email: hardikyp@umich.edu                                                    %
% Date: September 10, 2025                                                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% This function generates identity matrix for each degree of freedom, 
% identifies the number of free degrees of freedom, and calculates an order
% of indices required to reshape structure's data
% 
% Inputs:
% -------
% restraint (float): Matrix indicating DOF is fixed(1) of free(0) (nNodes, 2)
% nNodes (int): Number of nodes
% nDof (int): Total number of DOFS (2 * nNodes)
%
% Outputs:
% --------
% identity (array): matrix ordering the free and fixed DOFs (nNodes, 2)
% nfree (int): Number of free DOFs
% reshapeIdx (array): order of indices required to reshape structure's 
%                     dofs (nDof, 1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [identity, nfree, reshapeIdx] = numberDOF(restraint, nNodes, nDof)
restraint = reshape(restraint.', [], 1);
identity = zeros(size(restraint));
free_idx = find(restraint == 0);
nfree = numel(free_idx);
identity(free_idx) = 1:nfree;
rest_idx = find(restraint == 1);
identity(rest_idx) = nfree + (1:numel(rest_idx));
identity = reshape(identity, nDof, nNodes).';
reshapeIdx = reshape(identity.', [], 1);
end