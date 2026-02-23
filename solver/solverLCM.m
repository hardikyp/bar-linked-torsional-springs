%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Hardik Y. Patil                                                      %
% Email: hardikyp@umich.edu                                                    %
% Date: October 19, 2025                                                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This function is an implementation of the Newton-Raphson load controlled
% iterative-corrective scheme for non-linear analysis of structures.
%
% Inputs:
% -------
% params (struct): Structural information like nodes, coordinates, material 
%                  properties, etc.
%
% Outputs:
% --------
% outParams (struct): Sructural deformation behaviour and other information 
%                     like forces, displacements, etc.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [outParams] = solverLCM(params)
% Unpack encapsulated input parameters
links = params.links;
springs = params.springs;
coords = params.coords;
restraint = params.restraint;
force = params.force;
A = params.A;
E = params.E;
L = params.L;
L0 = params.L0;
theta = params.theta;
theta0 = params.theta0;
kT = params.kT;
identity = params.identity;
nNodes = params.nNodes;
nDof = params.nDof;
nBars = params.nBars;
nSpr = params.nSpr;
nFree = params.nFree;
reshapeIdx = params.reshapeIdx;
mapBars = params.mapBars;
mapSprings = params.mapSprings;

% System load vector to get Pref
Pref = loadVector(force, reshapeIdx); 

% Initialize parameters
maxIncr = 100;
maxIter = 100;
lambda = ones(maxIncr, 1) / 10;
dU = zeros(nNodes * nDof, maxIter, maxIncr);
U = zeros(nNodes * nDof, maxIncr + 1);
dP = zeros(nNodes * nDof, maxIncr);
P = zeros(nNodes * nDof, maxIncr + 1);
barIntForce = zeros(nNodes * nDof, maxIncr + 1);
sprIntForce = zeros(nNodes * nDof, maxIncr + 1);
axialF = zeros(nNodes * nDof, maxIncr + 1);
errTol = 1e-7;
nodeLoc = zeros(nNodes, nDof, maxIncr + 1);
nodeLoc(:, :, 1) = coords;
coordsPrev = coords;
nodeForce = zeros(nNodes, nDof, maxIncr + 1);

for i = 1:maxIncr
    j = 1;
    err = 10;
    dP(:, i) = Pref * lambda(i);
    P(:, i + 1) = P(:, i) + dP(:, i);
    R = zeros(nNodes * nDof, 1);

    % Prep internal force counters
    axialF(:, i + 1) = axialF(:, i);
    barIntForce(:, i + 1) = barIntForce(:, i);
    sprIntForce(:, i + 1) = sprIntForce(:, i);

    while j < maxIter && err > errTol
        % Generate stiffness matrix
        [kSystem, intF, axialF] = globalStiffnessNL(coords, coordsPrev, ...
                                                    nodeLoc(:, :, i), ...
                                                    springs, nDof, nBars, ...
                                                    nNodes, nSpr, A, E, L, ...
                                                    L0, theta, kT, ...
                                                    reshapeIdx, mapBars, ...
                                                    mapSprings, axialF, i);
        [Kff, Ksf] = partitionStiffness(kSystem, nFree);

        % Update internal member forces based on dU applied
        barIntForce(:, i + 1) = barIntForce(:, i + 1) + intF(:, 1);
        sprIntForce(:, i + 1) = sprIntForce(:, i + 1) + intF(:, 2);
        intForce = barIntForce(:, i + 1) + sprIntForce(:, i + 1);

        if j == 1
            dU(1:nFree, j, i) = Kff \ dP(1:nFree, i);
        else
            R = P(:, i + 1) - intForce;
            dU(1:nFree, j, i) = Kff \ R(1:nFree);
        end

        dP((nFree + 1):end, j, i) = Ksf * dU(1:nFree, j, i);
        
        % Update coordinates, bar lengths and displacements
        coordsPrev = coords;
        coords = coords + reshape(dU(reshapeIdx, j, i), nDof, nNodes).';
        [L, theta] = barInfo(coords, links);
        U(:, i + 1) = U(:, i) + sum(dU(:, 1:j, i), [2, 3]);

        % Error calculation
        if j > 1
            err = max(norm(R(1:nFree)), ...
                  norm(dU(:, j, i)) / sqrt(nFree) / ...
                  max(abs(U(:, i + 1))));
        end
        
        % Print progress
        fprintf('Incr: %02d, Iter: %02d, Err: %.6f, Norm(R): %.6f\n', ...
                i, j, err, norm(R(i:nFree)));
        j = j + 1;
    end
    nodeLoc(:, :, i + 1) = coords;
    nodeForce(:, :, i + 1) = reshape(P(reshapeIdx, i + 1), nDof, nNodes).';
end

% Encapsulate results
outParams = struct('links', links, ...
                   'springs', springs, ...
                   'coords', coords, ...
                   'restraint', restraint, ...
                   'force', force, ...
                   'A', A, ...
                   'E', E, ...
                   'L', L, ...
                   'L0', L0, ...
                   'theta', theta, ...
                   'theta0', theta0, ...
                   'kT', kT, ...
                   'identity', identity, ...
                   'nNodes', nNodes, ...
                   'nDof', nDof, ...
                   'nBars', nBars, ...
                   'nSpr', nSpr, ...
                   'nFree', nFree, ...
                   'reshapeIdx', reshapeIdx, ...
                   'mapBars', mapBars, ...
                   'mapSprings', mapSprings, ...
                   ... % --- Results --- %
                   'numSteps', maxIncr, ...
                   'P', P, ...
                   'U', U, ...
                   'nodeForce', nodeForce, ...
                   'nodeLoc', nodeLoc);
end