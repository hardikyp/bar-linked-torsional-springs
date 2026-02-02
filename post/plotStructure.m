%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Hardik Y. Patil                                                      %
% Email: hardikyp@umich.edu                                                    %
% Date: October 19, 2025                                                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% This function visualizes structural deformations and generates a video of 
% structure's motion as the loads are applied. Video is exported as a .mp4 file
% in videos directory.
%
% Inputs:
% -------
% params (struct): Input and pre-processed parameters of the structure.
% title (string): Video title string
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = plotStructure(params, title)
nodeLoc = params.nodeLoc;
links = params.links;
springs = params.springs;
restraint = params.restraint;
nodeForce = params.nodeForce;
force = params.force;
L0 = params.L0;
numSteps = params.numSteps;

barThickness = 0.065 * mean(L0);   % height of rounded rectangle bar

fprintf("PLOT: Structural deformation\n");
% Video setup
outDir = "videos";
if ~exist(outDir, 'dir'), mkdir(outDir); end
videoFile = fullfile(outDir, "StructuralDeformation" + title + ".mp4");
v = VideoWriter(videoFile, 'MPEG-4');
v.FrameRate = 30;
open(v);
% Figure/axes (off-screen, fixed size, OpenGL)
fig = figure('Name','Structural deformation', 'NumberTitle','off', ...
             'Visible','off', 'Color','w', ...
             'Units','pixels'); 
ax = axes('Parent',fig);
hold(ax,'on'); axis(ax,'equal'); axis(ax,'off');

% Fixed limits (set once; no relayout in the loop)
xMin = min(min(nodeLoc(:,1,:))) - 1;  xMax = max(max(nodeLoc(:,1,:))) + 1;
yMin = min(min(nodeLoc(:,2,:))) - 1;  yMax = max(max(nodeLoc(:,2,:))) + 1;
xlim(ax,[xMin xMax]); ylim(ax,[yMin yMax]);

for incr = 1:(numSteps + 1)
    cla(ax);
    axes(ax);
    hold(ax,'on'); axis(ax,'equal'); axis(ax,'off');
    xlim(ax,[xMin xMax]); ylim(ax,[yMin yMax]);
    
    % -- Plot bars -- %
    for bar = 1:size(links, 1)
        p1 = nodeLoc(links(bar, 1), :, incr);
        p2 = nodeLoc(links(bar, 2), :, incr);
        drawBar(p1, p2, barThickness);
    end
    
    % -- Plot nodes -- %
    for n = 1:size(nodeLoc, 1)
        center = nodeLoc(n, :, incr);
        r = 0.5 * barThickness;
        drawNode(center(1), center(2), r)
    end

    % -- Plot springs -- %
    for spr = 1:size(springs, 1)
        sprNodes = springs(spr, :);
        drawSpring(sprNodes, nodeLoc(:, :, incr), barThickness);
    end

    % -- Plot supports -- %
    triSize = 1.2 * barThickness;
    for s = 1:size(restraint, 1)
        if any(restraint(s, :))
            cx = nodeLoc(s, 1, incr);
            cy = nodeLoc(s, 2, incr);
            if all(restraint(s, :))
                drawFixedSupport(cx, cy, triSize, s, links, ...
                                 nodeLoc(:, :, incr));
            elseif restraint(s, 2) && ~restraint(s, 1)
                drawRollerSupport(cx, cy, triSize, 'horizontal')
            elseif restraint(s, 1) && ~restraint(s, 2)
                drawRollerSupport(cx, cy, triSize, 'vertical')
            end
        end
    end

    % -- Plot forces -- %
    for n = 1:size(nodeLoc, 1)
        if any(force(n, :))
            pos = nodeLoc(n, :, incr);
            frc = nodeForce(n, :, incr);
            drawArrow(pos, frc, barThickness);
        end
    end

    drawnow('limitrate','nocallbacks');
    
    % -- Write frame and clear for next frame -- %
    try
        frame = getframe(fig);
    catch
        % Fallback for some headless configs
        img = print(fig, '-RGBImage');
        frame = im2frame(img);
    end
    writeVideo(v, frame);
end
close(v);
close(fig);
fprintf("Saved: %s\n", videoFile);
end