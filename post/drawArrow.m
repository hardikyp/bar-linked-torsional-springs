%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Hardik Y. Patil                                                      %
% Email: hardikyp@umich.edu                                                    %
% Date: October 19, 2025                                                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% This function draws an arrow to specify the force vector at a node.
%
% Inputs:
% -------
% nodePos (array): Coordinates of the node where arrow needs to be drawn (1, 2)
% forceVec (array): Force vector at the node of interest (1, 2)
% barThickness (float): Thickness of the bar element in structure's rendering
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function drawArrow(nodePos, forceVec, barThickness)
    dir = forceVec / norm(forceVec);
    arrowColor = [144, 19, 46] / 255;
    
    % Arrow dimensions based on the barThickness
    arrowLength = 2.0 * barThickness;
    headLength  = 0.5 * barThickness;
    headWidth   = 0.75 * barThickness;
    shaftWidth  = 0.2 * barThickness;

    % Offsets for arrow start
    offset   = 1.0 * barThickness;
    startPt  = nodePos + offset * dir;
    endPt    = startPt + arrowLength * dir;

    % shaft polygon
    dx = endPt(1) - startPt(1);
    dy = endPt(2) - startPt(2);
    L  = hypot(dx,dy);
    ux = dx/L; uy = dy/L;
    R  = [ux -uy; uy ux];

    xs = [0 L-headLength L-headLength 0];
    ys = [-shaftWidth/2 -shaftWidth/2 shaftWidth/2 shaftWidth/2];
    shaft = R * [xs; ys];
    shaft(1,:) = shaft(1,:) + startPt(1);
    shaft(2,:) = shaft(2,:) + startPt(2);

    % head polygon
    xh = [L-headLength L L-headLength];
    yh = [-headWidth/2 0 headWidth/2];
    head = R * [xh; yh];
    head(1,:) = head(1,:) + startPt(1);
    head(2,:) = head(2,:) + startPt(2);
    
    % draw patches
    hold on;
    patch(shaft(1,:), shaft(2,:), arrowColor, 'EdgeColor','none');
    patch(head(1,:),  head(2,:), arrowColor, 'EdgeColor','none');
end
