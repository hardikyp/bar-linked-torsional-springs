%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Hardik Y. Patil                                                      %
% Email: hardikyp@umich.edu                                                    %
% Date: October 20, 2025                                                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% This script is to validate the torsional spring unit's performance with
% analytical solution for a vertical column buckling problem. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc; clear; close all;
addpath(genpath("core"));
addpath(genpath("post"));
addpath(genpath("solver"));
addpath(genpath("structures"));

% Load test structure
disp("Loading vertical column structure...");
inputStructure = loadVertColumn();
inputStructureName = "VertCol";

% Run displacement controlled analysis
disp("Running elastic second order analysis using displacement controlled algorithm (Arc-length)...");
[results] = dispControlSolver(inputStructure);

% Visualize the results of structural analysis
% plotStructure(results, inputStructureName);

% Plot internal vs external energy
% plotEnergy(results);

% Plot force vs displacement curve(s) with analytical solution
plotForceDisp(results, [1]);

theta = linspace(0.001, pi/2, 16);
A = 1;
E = 3e9;
L = 1;
K = 1000;
P = [0 2*K/L*theta./sin(theta)];
delta = [0 2*L*(1 - cos(theta))];
hold on;
plot(delta, P, '--k', 'DisplayName', 'Analytical', 'LineWidth', 3);
ax = gca;
xlim(ax, [0 2]);
ylim(ax, [0 4000]);
xticks(ax, 0:0.4:2);
yticks(ax, 0:1000:4000);
yticks([0 1000 2000 3000 4000]);
yticklabels({'0', '1000', '2000', '3000', '4000'});
dx = 0.4;  dy = 1000;
xr = diff(xlim(ax));   yr = diff(ylim(ax));
ratio = (dx * yr) / (dy * xr);   % Ly/Lx
pbaspect(ax, [1 ratio 1]);
disp("Analysis completed! All files saved.");