%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Hardik Y. Patil                                                      %
% Email: hardikyp@umich.edu                                                    %
% Date: October 19, 2025                                                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This function performs first-order elastic analysis of a structure.
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

function [outParams] = elasticFirstOrder(params)
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

% Initialize output variables
maxIncr = 1;
delta = zeros(nNodes * nDof, maxIncr + 1);
P = zeros(nNodes * nDof, maxIncr + 1);
nodeLoc = ones(nNodes, nDof, maxIncr + 1) .* coords;
nodeForce = zeros(nNodes, nDof, maxIncr + 1);

% Assemble and partition the system stiffness matrix
kSystem = globalStiffness(coords, springs, nDof, nBars, ...
                          nNodes, nSpr, A, E, L, theta, kT, ...
                          mapBars, mapSprings);
                          
[Kff, Ksf] = partitionStiffness(kSystem, nFree);

% Assemble the system load vector
P(:, end) = loadVector(force, reshapeIdx);

% Assemble and partition system displacement vector
delta(1:nFree, end) = Kff \ P(1:nFree, end);
P(nFree + 1:end, end) = Ksf * delta(1:nFree, end);

% Find nodal forces and displacements
nodeForce(:, :, end) = reshape(P(reshapeIdx, end), nDof, nNodes).';
nodeLoc(:, :, end) = nodeLoc(:, :, end) + reshape(delta(reshapeIdx, end), nDof, nNodes).';

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