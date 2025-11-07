%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Hardik Y. Patil                                                      %
% Email: hardikyp@umich.edu                                                    %
% Date: October 19, 2025                                                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% This function generates the stiffness matrix for a three-node torsional 
% spring element. The function also calculates the internal nodal forces due to
% the deformation of spring elements.
% 
% Inputs:
% -------
% springs (array): Nodes forming each three-node spring element (1, 3)
% kT (float): Rotational spring stiffness for each spring
% coords (array): Nodal coordinates of the structure in current iteration 
%                 (nNodes, 2)
%
% Outputs:
% --------
% kSpring (array): Stiffness matrix of a three-node torsional spring
%                  element (6, 6)
% intF (array): Total internal nodal force vector for each spring element (6, 1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [kSpring, intF] = springStiffness(springs, kT, coords, alpha0)
r1 = coords(springs(1, 1), :)'; 
r2 = coords(springs(1, 2), :)'; 
r3 = coords(springs(1, 3), :)';
a = r1 - r2;
b = r3 - r2;
L1 = norm(a);
L2 = norm(b);
N = [0 -1; 1 0];
C = dot(a, b);
S = a' * N * b;
alpha = mod(atan2(S, C) + 2 * pi, 2 * pi);

% Jacobian
J11 = N * a / L1^2;
J21 = N * b / L2^2 - N * a / L1^2;
J31 = -N * b / L2^2;
J = [J11; J21; J31];

% Hessian
H11 = (1 / L1^2) * N - (2 / L1^4) * (N * a) * a';
H12 = - H11;
H13 = zeros(2, 2);
H23 = (1 / L2^2) * N - (2 / L2^4) * (N * b) * b';
H33 = - H23;
H22 = H11 + H33;
H = [H11,  H12,  H13;
     H12', H22,  H23;
     H13', H23', H33];

% Internal force
M = kT * (alpha - alpha0);
intF = M * J;

% Spring stiffness matrix
kSpring = kT * (J * J') + M * H;
end