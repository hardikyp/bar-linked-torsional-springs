%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Hardik Y. Patil                                                      %
% Email: hardikyp@umich.edu                                                    %
% Date: October 19, 2025                                                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This function performs the eigen value analysis of the structure.
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

function [outParams] = eigenValueAnalysis(params)
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



% Assemble and partition the system stiffness matrix
kSystem = globalStiffness(coords, springs, nDof, nBars, ...
                          nNodes, nSpr, A, E, L, theta, kT, ...
                          mapBars, mapSprings);
                          
[Kff, ~] = partitionStiffness(kSystem, nFree);

% Calculate eigenvalues and eigen vectors
[nKff, mKff] = size(Kff);
if isequal(nKff, mKff)
    [eigVec, eigVal] = eig(Kff);
else
    error("Free stiffness matrix is not square!");
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
                   ... % --- Analysis results --- %
                   'eigVal', eigVal, ...
                   'eigVec', eigVec);
end