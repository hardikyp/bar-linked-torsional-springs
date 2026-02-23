%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Hardik Y. Patil                                                      %
% Email: hardikyp@umich.edu                                                    %
% Date: October 19, 2025                                                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% This script is the main entry point for running the reconfigurable
% truss simulations. It allows the user to select a structure from a
% list of predefined structures and choose the type of simulation to
% perform. The script then outputs the results of the simulation and
% allows the user to visualize the results.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc; clear; close all;
addpath(genpath("core"));
addpath(genpath("post"));
addpath(genpath("solver"));
addpath(genpath("structures"));

% Require user input for the structure to be loaded
disp("Select structure to load:");
disp("0. Test structure");
disp("1. Vertical column");
disp("2. Cantilever truss");
disp("3. Two unit cantilever truss");
disp("4. Shallow arch truss");
disp("5. Warren truss");
structType = input("Enter your choice (0, 1, 2, 3, 4, 5): ");
while ~ismember(structType, [0, 1, 2, 3, 4, 5])
    disp("Invalid choice. Please enter (0, 1, 2, 3, 4, 5)");
    structType = input("Enter your choice (0, 1, 2, 3, 4, 5): ");
end

if structType == 0
    disp("Loading test structure...");
    inputStructure = loadTestStructure();
    inputStructureName = "Test";
elseif structType == 1
    disp("Loading vertical column...");
    inputStructure = loadVertColumn();
    inputStructureName = "VertCol";
elseif structType == 2
    disp("Loading cantilever truss...");
    inputStructure = loadCantileverTruss();
    inputStructureName = "CantTruss";
elseif structType == 3
    disp("Loading 2 unit cantilever truss...");
    inputStructure = load2UnitCantileverTruss();
    inputStructureName = "CantTruss2";    
elseif structType == 4
    disp("Loading shallow arch truss...");
    inputStructure = loadShallowArch();
    inputStructureName = "ShallowArch";
elseif structType == 5
    disp("Loading warren truss...");
    inputStructure = loadWarrenTruss();
    inputStructureName = "Warren";    
end

% Require user input for what simulation type to run
disp("\nSelect solver type:");
disp("0. Load-controlled solver (Newton-Raphson)");
disp("1. Arc Length Control Method");
simType = input("Enter your choice (0 or 1): ");
while ~ismember(simType, [0, 1])
    disp("Invalid choice. Please enter 0 or 1");
    simType = input("Enter your choice (0 or 1): ");
end

% Run simulation based on user input
if simType ==0
    disp("Running elastic second order analysis using load-controlled algorithm (Newton-Raphson)...");
    [results] = solverLCM(inputStructure);    
elseif simType == 1
    disp("Running elastic second order analysis using Arc-length control method algorithm...");
    [results] = solverALCM(inputStructure);
end

% Visualize the results of structural analysis
plotStructure(results, inputStructureName);

% Plot internal vs external energy
plotEnergy(results);

% Plot force vs displacement curve(s)
plotForceDisp(results);
disp("Analysis completed! All files saved.");
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% END OF PROGRAM %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%