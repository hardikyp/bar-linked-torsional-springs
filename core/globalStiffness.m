%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Hardik Y. Patil                                                      %
% Email: hardikyp@umich.edu                                                    %
% Date: October 19, 2025                                                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% This function forms the global stiffness matrix (first order elastic) of 
% the system by combining the local stiffness matrices of all bar and 
% spring elements in the system.
%
% Inputs:
% -------
% coords (array): Nodal coordinates of the structure (nNodes, 2)
% springs (array): connectivity of spring members (nSpr, 3)
% nDof (int): Number of degrees of freedom per node (2)
% nBars (int): Number of bars in the system
% nNodes (int): Number of nodes in the system
% nSpr (int): Number of springs in the system
% A (array): Area of the bar members (nBars, 1)
% E (array): Young's modulus of the bar members (nBars, 1)
% L (array): Current lengths of the bar members (nBars, 1)
% theta (array): Current angle wrt global B of bar members (nBars, 1)
% kT (array): Torsional stiffness of spring members (nSpr, 1)
% mapBars (array): Local<->global dof mapping for bars (nBars, 4)
% mapSprings (array): Local<->global dof mapping for springs (nSpr, 4)
%
% Outputs:
% --------
% kSystem (array): System stiffness matrix (nNodes * nDof, nNodes * nDof) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [kSystem] = globalStiffness(coords, springs, nDof, nBars, nNodes, ...
                                     nSpr, A, E, L, theta, kT, mapBars, ...
                                     mapSprings)

kSystem = zeros(nNodes * nDof, nNodes * nDof);

% Loop over bar elements
for el = 1:nBars
    map = mapBars(el, :);
    kLocal = barStiffness(E(el), A(el), L(el));
    T = transformationMatrix(theta(el));
    kGlobal = T.' * kLocal * T;
    kSystem(map, map) = kSystem(map, map) + kGlobal;
end

% Loop over spring elements
for el = 1:nSpr
    map = mapSprings(el, :);
    [kLocal, ~] = springStiffness(springs(el, :), kT(el), coords, alpha0(el));
    kSystem(map, map) = kSystem(map, map) + kLocal;
end
end