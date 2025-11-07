%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Hardik Y. Patil                                                      %
% Email: hardikyp@umich.edu                                                    %
% Date: September 10, 2025                                                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% This function loads a warren truss structure.
%
% Outputs:
% --------
% params (struct): Loads all structural and analysis parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [params] = loadWarrenTruss()
links = [1, 2;
         1, 4;
         2, 3;
         2, 5;
         3, 4;
         4, 5;
         4, 6;
         5, 7;
         5, 9;
         6, 7;
         7, 8;
         7, 10;
         8, 9;
         9, 10];

springs = [2, 3, 4;
           4, 6, 7;
           7, 8, 9];

coords = [0, 0;
          0.5, sin(pi/3);
          0.75, 0.5 * sin(pi/3);
          1, 0;
          1.5, sin(pi/3);
          1.5, 0;
          2, 0;
          2.25, 0.5*sin(pi/3);
          2.5, sin(pi/3);
          3, 0];

restraint = [1, 1;
             0, 0;
             0, 0;
             0, 0;
             0, 0;
             0, 0;
             0, 0;
             0, 0;
             0, 0;
             0, 1];

force = [0, 0;
         0, 0;
         0.1, 0;
         0, 0;
         0, 1;
         0, -0.1;
         0, 0;
         -0.1, 0;
         0, 0;
         0, 0];

A = [0.5; 
     0.5;
     0.5;
     0.5; 
     0.5;
     0.5;
     0.5; 
     0.5;
     0.5;
     0.5;
     0.5; 
     0.5;
     0.5;
     0.5];

E = [3000000;
     3000000;
     3000000;
     3000000;
     3000000;
     3000000;
     3000000;
     3000000;
     3000000;
     3000000;
     3000000;
     3000000;
     3000000;
     3000000];

[L, theta] = barInfo(coords, links);
L0 = L;
theta0 = theta;

kT = [200;
      200;
      200];

alpha0 = springInfo(coords, springs);

[nNodes, nDof] = size(restraint);
nBars = size(links, 1);
nSpr = size(springs, 1);

[identity, nFree, reshapeIdx] = numberDOF(restraint, nNodes, nDof);
[mapBars, mapSprings] = generateMapping(identity, links, springs);

params = struct('links', links, ...
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
                'identity', identity, ...
                'nNodes', nNodes, ...
                'nDof', nDof, ...
                'nBars', nBars, ...
                'nSpr', nSpr, ...
                'nFree', nFree, ...
                'reshapeIdx', reshapeIdx, ...
                'mapBars', mapBars, ...
                'mapSprings', mapSprings);
end