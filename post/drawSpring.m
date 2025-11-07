%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Hardik Y. Patil                                                      %
% Email: hardikyp@umich.edu                                                    %
% Date: October 19, 2025                                                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% This function draws a circular node with red dashed outline to denote 
% a torsional spring.
%
% Inputs:
% -------
% sprNodes (array): Node numbers forming the spring unit
% coords (array): X & Y coordinate of the spring nodes at a given instance
% barThickness (float): Thickness of the bar drawn
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function drawSpring(sprNodes, coords, barThickness)
    n1 = sprNodes(1);
    n2 = sprNodes(2);
    n3 = sprNodes(3);
    
    % node positions
    p1 = coords(n1, :);
    p2 = coords(n2, :);
    p3 = coords(n3, :);

    % --- Bar directions ---
    v1 = (p1 - p2); v1 = v1 / norm(v1);
    v2 = (p3 - p2); v2 = v2 / norm(v2);

    % --- Radii for arcs ---
    r1 = 0.75 * barThickness;  % distance from node to arc1
    r2 = 1 * barThickness;  % arc2 spaced same distance outward

    % --- Angles of bars relative to node ---
    a1 = atan2(v1(2), v1(1));
    a2 = atan2(v2(2), v2(1));

    % Ensure a2 > a1 (counter-clockwise sweep)
    if a2 < a1
        a2 = a2 + 2*pi;
    end

    % --- Plot arcs ---
    nseg = 20; % smoothness
    th = linspace(a1, a2, nseg);

    x1 = p2(1) + r1*cos(th);
    y1 = p2(2) + r1*sin(th);

    x2 = p2(1) + r2*cos(th);
    y2 = p2(2) + r2*sin(th);

    hold on;
    plot(x1, y1, 'Color', '#9b231e', 'LineWidth', 1.5);
    plot(x2, y2, 'Color', '#9b231e', 'LineWidth', 1.5);
end
