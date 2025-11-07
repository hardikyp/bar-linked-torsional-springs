%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Hardik Y. Patil                                                      %
% Email: hardikyp@umich.edu                                                    %
% Date: September 10, 2025                                                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% This function partitions the global stiffness matrix into parts 
% corresponding to free and fixed degrees of freedom.
% 
% Inputs:
% -------
% kSystem (float): Stiffness matrix of the system
% nfree (int): Number of free degrees of freedom
%
% Outputs:
% --------
% Kff (array): Part of system stiffness matrix corresponding to free DOFs
% Ksf (array): Part of system stiffness matrix corresponding to fixed DOFs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Kff, Ksf] = partitionStiffness(kSystem, nfree)
Kff = kSystem(1:nfree, 1:nfree);
Ksf = kSystem((nfree + 1):end, 1:nfree);
end