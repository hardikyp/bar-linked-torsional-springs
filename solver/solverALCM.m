%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Hardik Y. Patil                                                      %
% Email: hardikyp@umich.edu                                                    %
% Date: October 19, 2025                                                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This function is an implementation of the Arc Length Control Method (ALCM)
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

function [outParams] = solverALCM(params)
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
alpha0 = params.alpha0;
identity = params.identity;
nNodes = params.nNodes;
nDof = params.nDof;
nBars = params.nBars;
nSpr = params.nSpr;
nFree = params.nFree;
reshapeIdx = params.reshapeIdx;
mapBars = params.mapBars;
mapSprings = params.mapSprings;

% Initialize parameters
disp('Select load stepping method:');
disp('0. Fixed');
disp('1. Auto');
autoLoadStep = input('Enter your choice (0 or 1): ');
while ~ismember(autoLoadStep, [0, 1])
    disp('Invalid choice. Please enter (0 or 1)');
    autoLoadStep = input('Enter your choice (0 or 1): ');
end

gamma = 1.0;
minIter = 3;
maxIter = 50;
dirSign = 1;
errTol = 1e-7;
if autoLoadStep == 1
    maxIncr = 700;
    lambda = zeros(maxIter, maxIncr);
    lambda(1, 1) = 0.005;
else
    loadFactor = 0.0001;
    maxIncr = round(1 / loadFactor);
    lambda = zeros(maxIter, maxIncr);
    lambda(1, :) = loadFactor;
end

% System load vector to get PRef
PRef = loadVector(force, reshapeIdx);

dU = zeros(nNodes * nDof, maxIter, maxIncr);
dUR = zeros(nFree, maxIter, maxIncr);
dUP = zeros(nFree, maxIter, maxIncr);
U = zeros(nNodes * nDof, maxIncr + 1);
dP = zeros(nNodes * nDof, maxIter, maxIncr);
P = zeros(nNodes * nDof, maxIncr + 1);
alpha = zeros(nSpr, maxIncr + 1);
barIntForce = zeros(nNodes * nDof, maxIncr + 1);
sprIntForce = zeros(nNodes * nDof, maxIncr + 1);
intForce = zeros(nNodes * nDof, maxIncr + 1);
axialF = zeros(nBars, maxIncr + 1);
nodeLoc = zeros(nNodes, nDof, maxIncr + 1);
nodeForce = zeros(nNodes, nDof, maxIncr + 1);
CSP = zeros(maxIncr, 1); % Current Stiffness Parameter
nodeLoc(:, :, 1) = coords;
alpha(:, 1) = alpha0;
coordsPrev = coords;

for i = 1:maxIncr
    % Reset iter counter and error
    j = 1;
    err = 10;

    % Prepare internal force counters for next increment
    axialF(:, i + 1) = axialF(:, i);
    barIntForce(:, i + 1) = barIntForce(:, i);
    R = zeros(nFree, 1);
    
    while (err > errTol || j <= minIter) && (j <= maxIter)
        % Generate stiffness matrix
        [kSystem, intF, axialF] = globalStiffness(coords, coordsPrev, ...
                                                  springs, nDof, nBars, ...
                                                  nNodes, nSpr, A, E, L, ...
                                                  L0, theta, kT, alpha0, ... 
                                                  reshapeIdx, mapBars, ...
                                                  mapSprings, axialF, i);
        [Kff, Ksf] = partitionStiffness(kSystem, nFree);

        % Update internal member forces based on dU applied
        barIntForce(:, i + 1) = barIntForce(:, i + 1) + intF(:, 1);
        sprIntForce(:, i + 1) = intF(:, 2);
        intForce(:, i + 1) = barIntForce(:, i + 1) + sprIntForce(:, i + 1);
        
        % Residual calculation
        if j > 1
            R = P(1:nFree, i + 1) - intForce(1:nFree, i + 1);
        end
        dUR(:, j, i) = Kff \ R;
        dUP(:, j, i) = Kff \ PRef(1:nFree);

        % Lambda updates
        if j == 1
            if i > 1
                dUi_1 = U(1:nFree, i) - U(1:nFree, i - 1);
                if dot(dUi_1, dUP(:, j, i)) < 0
                    dirSign = -1;
                else
                    dirSign = 1;
                end
            end
            if autoLoadStep == 1
                CSP(i) = (dUP(:, 1, 1)' * PRef(1:nFree)) / ...
                          (dUP(:, j, i)' * PRef(1:nFree));
                lambda(1, i) = dirSign * lambda(1, 1) * (abs(CSP(i)))^gamma;
            else
                lambda(1, i) = dirSign * lambda(1, i);
            end
        elseif j > 1 % Arc length updates
            num = dU(1:nFree, 1, i)' * dUR(:, j, i);
            den = dU(1:nFree, 1, i)' * dUP(:, j, i) + lambda(1, i);
            lambda(j, i) = - num / den;
        end

        dU(1:nFree, j, i) = lambda(j, i) * dUP(:, j, i) + dUR(:, j, i);
        dP(:, j, i) = lambda(j, i) * PRef;
        dP((nFree + 1):end, j, i) = Ksf * dU(1:nFree, j, i);

        % Update coordinates, bar lengths, forces and displacements
        coordsPrev = coords;
        coords = coords + reshape(dU(reshapeIdx, j, i), nDof, nNodes).';
        [L, theta] = barInfo(coords, links);
        alpha(:, i + 1) = springInfo(coords, springs);

        U(:, i + 1) = U(:, i) + sum(dU(:, 1:j, i), [2]);
        P(:, i + 1) = P(:, i) + sum(dP(:, 1:j, i), [2]);

        % Error calculation
        if j > 1
            trackedDisp = dU(:, j, i) / sqrt(nFree) / max(abs(U(:, i + 1)));
            err = max(norm(R) / norm(PRef(1:nFree)), norm(trackedDisp));
        end

        % Print progress
        fprintf('Incr: %02d, Iter: %02d, Err: %.7f\n', i, j, err);
        j = j + 1;
    end

    % Store updated node locations and forces at the end of increment
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
                'alpha0', alpha0, ...
                'alpha', alpha, ...
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
                'nodeLoc', nodeLoc, ...
                'sprIntForce', sprIntForce, ...
                'barIntForce', barIntForce, ...
                'intForce', intForce);
end