%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Hardik Y. Patil                                                      %
% Email: hardikyp@umich.edu                                                    %
% Date: October 19, 2025                                                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% This function plots the work done by external forces and compares it to the 
% strain energies of the bar and spring members. Figures are exported in 
% scalable vector graphics (svg) format.
%
% Inputs:
% -------
% params (struct): input and pre-processed parameters of the structure.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = plotEnergy(params)
% Unpack encapsulated input parameters
kT = params.kT;
alpha = params.alpha;
alpha0 = params.alpha0;
numSteps = params.numSteps;
P = params.P;
delta = params.delta;
barIntForce = params.barIntForce;

% Calculate external work
externalWork = zeros(1, size(delta, 2));
for inc = 2:size(delta, 2)
    deltaIncr = delta(:, inc) - delta(:, inc-1);
    PAvg = (P(:, inc) + P(:, inc-1)) / 2;
    externalWork(inc) = externalWork(inc-1) + sum(deltaIncr .* PAvg);
end

% Calculate internal work
springEnergy = zeros(1, size(delta, 2));
barEnergy = zeros(1, size(delta, 2));

for inc = 2:(numSteps + 1)
    dU = delta(:, inc) - delta(:, inc - 1);
    
    % Spring strain energy
    springEnergy(1, inc) = 0.5 * kT' * (alpha(:, inc) - alpha0).^2; 

    % Bar strain energy    
    barAvgE = (barIntForce(:, inc) + barIntForce(:, inc - 1))';
    barEnergy(1, inc) = barEnergy(1, inc - 1) + 0.5 * barAvgE * dU;
end

% Total internal work
internalWork = barEnergy + springEnergy;

% --- Plot
figure('Name', 'Energy Analysis', 'NumberTitle', 'off');
hold on;

% Global text/axes defaults for this figure
set(gcf, ...
    'DefaultTextFontName', 'Arial', ...
    'DefaultAxesFontName', 'Arial', ...
    'DefaultLegendFontName', 'Arial', ...
    'DefaultTextFontSize', 9, ...
    'DefaultAxesFontSize', 9);

% Stacked area for bar + spring energies
colors = ["#ffa600", "#ff6361", "#bc5090"]; colororder(colors);
area(1:numSteps+1, [barEnergy' springEnergy'], 'LineStyle', 'none', ...
     'FaceAlpha', 0.8); 
plot(externalWork, 'LineStyle', '--', 'LineWidth', 3, 'Color', '#003f5c', ...
     'DisplayName', 'External Work');
energyDiff = abs(externalWork - internalWork);

% Fix legend in the northwest corner, left aligned
leg = legend({'Bar Energy','Spring Energy','External Work'}, ...
             'Location', 'northwest', 'EdgeColor', 'none', ...
             'BackgroundAlpha', 0);
set(leg, 'Units', 'normalized');
legPos = get(leg, 'Position');

% Calculate energy conservation info
maxEnergyDiff = max(energyDiff);
maxEnergy = max(max(internalWork), max(externalWork));
if maxEnergy > 0
    relativeError = maxEnergyDiff / maxEnergy * 100;
else
    relativeError = 0;
    warning('Maximum energy is zero - cannot calculate relative error');
end

% Place textbox directly below legend, left aligned
textStr = sprintf('Max Relative Error: %.3f%%', relativeError);
textBoxWidth = legPos(3); % same width as legend
textBoxHeight = 0.08;     % tweak if needed
textBoxX = legPos(1);     % align left edge
textBoxY = legPos(2) - textBoxHeight - 0.5*textBoxHeight; % below legend

annotation('textbox', [textBoxX, textBoxY, textBoxWidth, textBoxHeight], ...
           'String', textStr, 'FitBoxToText', 'on', ...
           'BackgroundColor', 'white', 'EdgeColor', 'none', ...
           'HorizontalAlignment', 'left', 'VerticalAlignment', 'top', ...
           'FaceAlpha', 0);
xlim([0, numSteps]);
grid on;
xlabel('Load Increment', 'FontName', 'Arial', 'FontSize', 9, 'FontWeight', 'normal');
ylabel('Energy',          'FontName', 'Arial', 'FontSize', 9, 'FontWeight', 'normal');
title('Energy Balance Analysis', 'FontName', 'Arial', 'FontSize', 9, 'FontWeight', 'normal');

% Export to svg
% ax = gca;
% set(gcf, 'Units', 'inches', 'Position', [1 1 6.5 4.0]);  % width x height
% set(ax, 'LooseInset', max(get(ax,'TightInset'), 0.02*[1 1 1 1]));
% exportgraphics(gcf, 'figures\\energy_analysis.svg', 'ContentType', 'vector', ...
%     'BackgroundColor', 'none');
end