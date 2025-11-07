%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Hardik Y. Patil                                                      %
% Email: hardikyp@umich.edu                                                    %
% Date: October 19, 2025                                                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% This function forms the global stiffness matrix of the system by combining
% the local stiffness matrices of all bar and spring elements in the system for
% non-linear solvers. The function also computes and updates internal forces
% in the system required for the formulation of geometric stiffness matrix and
% the calculation of the residual in each iteration.
%
% Inputs:
% -------
% coords (array): Nodal coordinates in current iteration (nNodes, 2)
% coordsPrev (array): Nodal coordinates in last iteration (nNodes, 2)
% springs (array): connectivity of springs (nSpr, 3)
% nDof (int): Number of degrees of freedom per node (2)
% nBars (int): Number of bars in the system
% nNodes (int): Number of nodes in the system
% nSpr (int): Number of springs in the system
% A (array): Area of the bar members (nBars, 1)
% E (array): Young's modulus of the bar members (nBars, 1)
% L (array): Current lengths of the bar members (nBars, 1)
% L0 (array): Original lengths of the bar members (nBars, 1)
% theta (array): Current angle wrt global X of bar members (nBars, 1)
% kT (array): Torsional stiffness of spring members (nSpr, 1)
% alpha0 (array): Undeformed (rest) angle of spring members (nSpr, 1)
% reshapeIdx (array): order of indices required to reshape structure's 
%                     dofs (nDof, 1)
% mapBars (array): Local<->global dof mapping for bars (nBars, 4)
% mapSprings (array): Local<->global dof mapping for springs (nSpr, 4)
% axialF (array): History of axial force in each bar member (nBar, maxIncr + 1)
% i (int): current increment number
%
% Outputs:
% --------
% kSystem (array): System stiffness matrix (nNodes * nDof, nNodes * nDof)
% intF (array): Internal nodal forces in current iteration due to bars and 
%               spring elements (nNoges, 2)
% aialF (array): Updated history of axial force in bar each member 
%                (nBar, maxIncr + 1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [kSystem, intF, axialF] = globalStiffnessNL(coords, coordsPrev, ...
                                                     springs, nDof, nBars, ...
                                                     nNodes, nSpr, A, E, L, ...
                                                     L0, theta, kT, alpha0, ...
                                                     reshapeIdx, mapBars, ...
                                                     mapSprings, axialF, i)

    kSystem = zeros(nNodes * nDof, nNodes * nDof);
    intFBar = zeros(nNodes * nDof, 1);
    intFSpr = zeros(nNodes * nDof, 1);

    % Loop over bar elements
    for el = 1:nBars
        map = mapBars(el, :);
        [axialForce, intFBar] = barForceRec(coords, coordsPrev, ...
                                            E(el), A(el), L(el), L0(el), ...
                                            theta(el), intFBar, map, ...
                                            reshapeIdx, axialF(el, i + 1));

        axialF(el, i + 1) = axialF(el, i + 1) + axialForce;
        
        kLocal = barStiffness(E(el), A(el), L(el));
        kGeom = geomStiffness(axialF(el, i + 1), L(el));
        T = transformationMatrix(theta(el));
        kGlobal = T.' * (kLocal + kGeom) * T;
        kSystem(map, map) = kSystem(map, map) + kGlobal;
    end

    % Loop over spring elements
    for el = 1:nSpr
        map = mapSprings(el, :);
        [kLocal, sprIntF] = springStiffness(springs(el, :), kT(el), coords, ...
                            alpha0(el));
        intFSpr(map, 1) = intFSpr(map, 1) + sprIntF;
        kSystem(map, map) = kSystem(map, map) + kLocal;
    end
    
    % encapsulate internal nodal force for output
    intF = [intFBar, intFSpr];
end