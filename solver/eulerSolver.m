%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Hardik Y. Patil                                                      %
% Email: hardikyp@umich.edu                                                    %
% Date: October 19, 2025                                                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This function is an implementation of the Euler load controlled
% iterative scheme for non-linear analysis of structures.
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

function [outParams] = eulerSolver(params)
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

% Initialize simulation parameters
maxIncr = 100;
delta = zeros(nNodes*nDof, maxIncr + 1);
dDelta = zeros(nNodes*nDof, maxIncr);
dP = zeros(nNodes*nDof, maxIncr);
P = zeros(nNodes*nDof, maxIncr + 1);
nodeForce = zeros(nNodes, nDof, maxIncr + 1);
nodeLoc = zeros(nNodes, nDof, maxIncr + 1);
nodeLoc(:, :, 1) = coords;

% Assemble and partition the system load vector
Pref = loadVector(force, reshapeIdx);
dP(1:nFree, :) = repmat(Pref(1:nFree) ./ maxIncr, 1, maxIncr);

for incr = 1:maxIncr
    fprintf("%.1f %% Analysis Complete. Incr: %d/%d\n", ...
            incr / maxIncr * 100, incr, maxIncr);
    % Assemble and partition the system stiffness matrix
    kSystem = globalStiffness(coords, springs, ...
                              nDof, nBars, nNodes, ...
                              nSpr, A, E, L, theta, kT, ...
                              mapBars, mapSprings);
    [Kff, Ksf] = partitionStiffness(kSystem, nFree);
    dDelta(1:nFree, incr) = Kff \ dP(1:nFree, incr);
    
    % Reaction forces at restrained nodes
    dP(nFree+1:end, incr) = Ksf * dDelta(1:nFree, incr);

    % Save displacement and force history for each increment
    P(:, incr + 1) = P(:, incr) + dP(:, incr);
    delta(:, incr + 1) = delta(:, incr) + dDelta(:, incr);
    
    % Find nodal forces and displacements
    nodeForce(:, :, incr + 1) = nodeForce(:, :, incr) + ...
                                 reshape(P(reshapeIdx, incr + 1), ...
                                         nDof, nNodes).';
    nodeLoc(:, :, incr + 1) = nodeLoc(:, :, incr) + ...
                              reshape(delta(reshapeIdx, incr + 1), ...
                                      nDof, nNodes).';
    
    % Update nodal coordinates
    coords = coords + reshape(dDelta(reshapeIdx, incr), nDof, nNodes).';
    [L, theta] = barInfo(coords, links);
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
                   'delta', delta, ...
                   'nodeForce', nodeForce, ...
                   'nodeLoc', nodeLoc);
end