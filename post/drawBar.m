%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Hardik Y. Patil                                                      %
% Email: hardikyp@umich.edu                                                    %
% Date: September 10, 2025                                                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% This function draws a rounded rectangle to visualize a bar element.
%
% Inputs:
% -------
% p1 (array): x and y coordinates of point 1 (2, 1)
% p2 (array): x and y coordinates of point 2 (2, 1)
% barThickness (float): thickness of the rounded rectangle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function drawBar(p1, p2, barThickness)
    midPt = (p1 + p2) / 2;
    len = norm(p2 - p1) + barThickness;
    theta = atan2(p2(2) - p1(2), p2(1) - p1(1));

    % Draw the bar at origin
    pos = [-len / 2, -barThickness / 2, len, barThickness];
    hold on;
    h = rectangle('Position', pos, ...
                  'Curvature', 1.0, ...
                  'FaceColor', '#d1d2d4', ...
                  'EdgeColor', 'none');
    
    % Rotate and translate
    hg = hgtransform;
    set(h, 'Parent', hg);
    R = makehgtform('translate', [midPt, 0], 'zrotate', theta);
    set(hg, 'Matrix', R);
end