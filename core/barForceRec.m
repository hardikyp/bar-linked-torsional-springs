%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Hardik Y. Patil                                                      %
% Email: hardikyp@umich.edu                                                    %
% Date: October 19, 2025                                                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% This function calculates internal force in each bar element of the truss 
% system and assembles into the global internal force vector.
%
% Inputs:
% -------
% coords (array): nodal coordinates in the current iteration (nNodes, 2)
% coordsPrev (array): nodal coornidates in the previous iteration (nNodes, 2)
% E (float): Modulus of elasticity of the bar element
% A (float): Cross-sectional area of the bar element
% L (float): Current length of the bar element
% L0 (float): Original length of the bar element
% theta (float): angle of the bar (radian) wrt global coordinate system
% intF (array): Internal force vector of the bar element (2 * nDof, 1)
% map (array): Mapping of the DOFs of current bar element wrt system (4, 1)
% reshapeIdx (array): order of indices required to reshape structure's 
%                     dofs (nDof, 1)
% barF (float): Value of axial force in the bar element in current iteration
%
% Outputs:
% --------
% axialForce (float): Axial force of the bar element in current iteration
% intF (array): Internal force vector of the bar element in current 
%               iteration (2 * nDof, 1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [axialForce, intF] = barForceRec(coords, coordsPrev, E, A, L, L0, ...
                                          theta, intF, map, reshapeIdx, barF)
    % Nodal displacements in local frame
    dU = reshape((coords - coordsPrev)', [], 1);
    T = transformationMatrix(theta);
    dULocal = T * dU(ismember(reshapeIdx, map), 1);

    % Axial force from bar's natural deformations
    natDef = [-1, 0, 1, 0] * dULocal;
    axialForce = E * A / L0 * natDef;

    % Internal nodal forces
    kLocal = barStiffness(E, A, L);
    kGeom = geomStiffness(barF, L);
    fLocal = (kLocal + kGeom) * dULocal;
    intF(map, 1) = intF(map, 1) + T.' * fLocal;
end