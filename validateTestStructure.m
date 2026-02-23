%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Hardik Y. Patil                                                      %
% Email: hardikyp@umich.edu                                                    %
% Date: October 20, 2025                                                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% This script is to validate the torsional spring unit's performance with
% analytical solution for the most basic three-node spring structure. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc; clear; close all;
addpath(genpath("core"));
addpath(genpath("post"));
addpath(genpath("solver"));
addpath(genpath("structures"));

% Load test structure
disp("Loading test structure...");
inputStructure = loadTestStructure();
inputStructureName = "Test";

% Run displacement controlled analysis
disp("Running elastic second order analysis using displacement controlled algorithm (Arc-length)...");
[results] = solverALCM(inputStructure);

% Visualize the results of structural analysis
% plotStructure(results, inputStructureName);

% Plot internal vs external energy
plotEnergy(results);

% Plot force vs displacement curve(s) with analytical solution
plotForceDisp(results, [2]);

% theta = 0:0.04:pi/2-0.2;
% A = 0.5;
% E = 3000000;
% L = 1;
% K = 50;
% den = 2 * L * sin(theta) .* cos(theta);
% sqrtTerm = sqrt((L*cos(theta)/E/A) .* (4*K.*theta.*sin(theta)+A*E*L*cos(theta)));
% num = -A*E*L*cos(theta) + A*E*sqrtTerm;
% P = num ./ den;
% dL = (P * L / E / A) .* sin(theta);
% delta = (L+dL).*sin(theta);
% hold on;
% plot(delta, P, 'ko', 'DisplayName', 'Analytical');
% ax = gca;
% xlim(ax, [0 1]);
% ylim(ax, [0 400]);
% xticks(ax, 0:0.2:1);
% yticks(ax, 0:100:400);
% yticks([0 100 200 300 400]);
% yticklabels({'0', '100', '200', '300', '400'});
% dx = 0.2;  dy = 100;
% xr = diff(xlim(ax));   yr = diff(ylim(ax));
% ratio = (dx * yr) / (dy * xr);   % Ly/Lx
% pbaspect(ax, [1 ratio 1]);  

disp("Analysis completed! All files saved.");
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% END OF PROGRAM %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%