%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Hardik Y. Patil                                                      %
% Email: hardikyp@umich.edu                                                    %
% Date: October 19, 2025                                                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% This function draws a roller support.
%
% Inputs:
% -------
% x (array): X coordinate of the roller support
% y (array): Y coordinate of the roller support
% triSize (float): Length of the triangle to be drawn for roller support
% rollerType (string): 'vertical' or 'horizontal' type of roller support
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function drawRollerSupport(x, y, triSize, rollerType)
    h = sqrt(3)/2 * triSize;
    triColor = [129, 130, 132] / 255;
    d = 0.1 * h;
    t = 0.1 * h;
    
    if isstring(rollerType) || ischar(rollerType)
        rt = char(rollerType);
    else
        error('rollerType must be a string or char vector');
    end

    if strcmpi(rt, 'vertical')
        xCoords = [x, x + h, x + h];
        yCoords = [y, y - triSize/2, y + triSize/2];    
        xLine = [xCoords(2) + d, xCoords(2) + d, ...
                 xCoords(3) + d + t, xCoords(3) + d + t];
        yLine = [yCoords(2:3), yCoords(3:-1:2)];
    elseif strcmpi(rt, 'horizontal')
        xCoords = [x, x - triSize/2, x + triSize/2];
        yCoords = [y, y - h, y - h];
        xLine = [xCoords(2:3), xCoords(3:-1:2)];
        yLine = [yCoords(2) - d, yCoords(2) - d, ...
                 yCoords(3) - d - t, yCoords(3) - d - t];
    else
        error('Wrong support type specified');
    end
    hold on;
    patch(xCoords, yCoords, triColor, 'EdgeColor', 'none');
    patch(xLine, yLine, 'k', 'EdgeColor', 'none');
end