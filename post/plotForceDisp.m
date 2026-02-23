%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Hardik Y. Patil                                                      %
% Email: hardikyp@umich.edu                                                    %
% Date: October 19, 2025                                                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% This function plots the force versus displacement and exports the figure in
% a scalable vector graphics (svg) format in the directory figures.
%
% Inputs:
% -------
% params (struct): Input and pre-processed parameters of the structure
% dofList (array): Indices of the DOFs whose force-disp curves are required
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plotForceDisp(params, dofList)
% Unpack encapsulated input parameters
U        = params.U;
P        = params.P;
nFree    = params.nFree;
identity = params.identity;

% Default: plot all free dofs
if nargin < 2 || isempty(dofList)
    dofList = 1:nFree;
end

% Create figure
figure('Name','Load-Displacement','NumberTitle','off'); hold on;
colors = lines(numel(dofList));
set(gcf, ...
    'DefaultTextFontName', 'Arial', ...
    'DefaultAxesFontName', 'Arial', ...
    'DefaultLegendFontName', 'Arial', ...
    'DefaultTextFontSize', 9, ...
    'DefaultAxesFontSize', 9);

for k = 1:numel(dofList)
    idx = dofList(k);      % free DOF index
    u = U(idx, :);     % displacement history
    f = P(idx, :);         % load history
    
    % Find node and DOF type from identity
    [node, dof] = find(identity == idx);
    if dof == 1
        dofLabel = 'X';
    elseif dof == 2
        dofLabel = 'Y';
    else
        dofLabel = sprintf('DOF%d', dof);
    end
    
    % Plot
    plot(u, f, 'LineWidth', 2, 'Color', colors(k,:), ...
         'DisplayName', sprintf('Node %d, %s', node, dofLabel));
end
legend('Location', 'best', 'EdgeColor', 'none', 'BackgroundAlpha', 0);
xlabel('Displacement', 'FontName', 'Arial', 'FontSize', 9, 'FontWeight', 'normal');
ylabel('Load', 'FontName', 'Arial', 'FontSize', 9, 'FontWeight', 'normal');
title('Load–Displacement Curves', 'FontName', 'Arial', 'FontSize', 9, 'FontWeight', 'normal');
y = yline(0, 'k', 'DisplayName', '');
x = xline(0, 'k', 'DisplayName', '');
y.Annotation.LegendInformation.IconDisplayStyle = 'off';
x.Annotation.LegendInformation.IconDisplayStyle = 'off';
grid on;
end