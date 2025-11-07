%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Hardik Y. Patil                                                      %
% Email: hardikyp@umich.edu                                                    %
% Date: October 19, 2025                                                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% This function draws a fixed support.
%
% Inputs:
% -------
% x (array): X coordinate of the fixed support
% y (array): Y coordinate of the fixed support
% triSize (float): Length of the triangle to be drawn for fixed support
% nodeIdx (float): Index of the node acting as fixed support
% links (array): Connectivity of bar elements in the structure (nBars, 2)
% coords (array): Nodal coordinates of the structure (nNodes, 2)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function drawFixedSupport(x, y, triSize, nodeIdx, links, coords)
    % Triangle parameters
    h = sqrt(3)/2 * triSize;
    xCoords = [x, x - triSize/2, x + triSize/2];
    yCoords = [y, y - h, y - h];
    triColor = [129, 130, 132] / 255;
    
    % Hatch line parameters
    nHatch = 3;
    xMargin = 0.1 * triSize;
    yMargin = 0.05 * triSize;
    t = 0.1 * triSize;
    xBase = linspace(xCoords(2) + xMargin, xCoords(3) - 2 * xMargin , nHatch);  
    yBase = repmat(yCoords(2) + yMargin, 1, nHatch);
    dx = 0.15 * triSize * sqrt(2);
    dy = -0.15 * triSize * sqrt(2);

    % Plot hatching 
    L  = hypot(dx, dy);
    px = -dy/L; py = dx/L;
    X = [xBase+px*t/2; xBase-px*t/2; xBase+dx-px*t/2; xBase+dx+px*t/2];
    Y = [yBase+py*t/2; yBase-py*t/2; yBase+dy-py*t/2; yBase+dy+py*t/2];

    % --- Check for connected bars ---
    conn = find(any(links == nodeIdx,2));  
    rotationAngle = 0; % default (triangle base horizontal)

    if ~isempty(conn)
        % use first bar
        bar = links(conn(1),:);
        otherNode = bar(bar ~= nodeIdx);
        dirVec = coords(otherNode,:) - [x,y];
        dirVec = dirVec / norm(dirVec);

        % bar more horizontal than vertical?
        if abs(dirVec(1)) > abs(dirVec(2))
            % base should be vertical → rotate ±90
            if dirVec(1) > 0
                rotationAngle = -pi/2; % bar to the right → rotate CW
            else
                rotationAngle =  pi/2; % bar to the left → rotate CCW
            end
        else
            % base stays horizontal (default)
            % could add 180 flip if needed
            rotationAngle = 0;
        end
    end

    % --- Apply rotation about (x,y) ---
    R = [cos(rotationAngle) -sin(rotationAngle);
         sin(rotationAngle)  cos(rotationAngle)];

    triRot = R * ([xCoords; yCoords] - [x;y]) + [x;y];
    hatchRot = R * ([X(:)'; Y(:)'] - [x;y]) + [x;y];

    % --- Plot ---
    hold on;
    patch(reshape(hatchRot(1,:),4,[]), reshape(hatchRot(2,:),4,[]), ...
          'k', 'EdgeColor','none');
    fill(triRot(1,:), triRot(2,:), triColor, 'EdgeColor','none');
end