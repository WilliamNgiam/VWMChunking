% Define random coordinates in a rectangle

% Adapted from randomArrayRects function given by KA from AwhVogelLab
% WXQN started adapting this for VWMStatisticalLearning_Exp2_EEG.m on
% 7/12/16

% This function produces a random set of x,y co-ordinates for a given rect
% and number of items.

% List of changes:

% Changed parameters required: Now needs the foreground/destination rect
% and minimum distance between co-ordinates(in pixels).

% For VWMStatisticalLearning - It takes the destination rectangles, splits
% it into four quadrants (really halves)

%-------------------------------------------------------------------------
% Grabs the locations anywhere within the designated stimulus rect!
% function rects = randomArrayRects(rect, nItems, win, prefs)
function [xPos,yPos] = randomArrayCoords(foreRect,nItems,minDist)
% segment the inner win into four quadrants - for xCoords, 1st
% row = positions in left half of display, 2nd row = right half.
% For yCoords - 1st row = top half, 2nd row = bottom half
xCoords = [linspace(foreRect(1),(foreRect(1)+foreRect(3))/2,300); linspace(((foreRect(1)+foreRect(3))/2),foreRect(3),300)];
yCoords = [linspace((foreRect(2)),((foreRect(2)+foreRect(4))/2)-minDist,300); linspace(((foreRect(2)+foreRect(4))/2)+minDist,foreRect(4),300)];
xLocInd = randperm(size(xCoords,2)); yLocInd = randperm(size(yCoords,2));

% Pick x,y coords for drawing stimuli on this trial, making sure
% that all stimuli are seperated by >= minDist
if nItems ==1
    xPos = [xCoords(randi(2),xLocInd(1))];  % pick randomly from first and second x rows (L/R halves)
    yPos = [yCoords(randi(2),yLocInd(1))];  % pick randomly from first and second y rows (Top/Bottom).
elseif nItems ==2 % always bilateral without randomPosition
        randomPosition = randi(2);
        if randomPosition == 1
    xPos = [xCoords(1,xLocInd(1)),xCoords(2,xLocInd(2))]; % pick one left and one right item
    yPos = [yCoords(1,yLocInd(1)),yCoords(2,yLocInd(2))]; % pick one top and one bottom
        else
            xPos = [xCoords(randi(2),xLocInd(1)),xCoords(randi(2),xLocInd(2))]; % pick randomly, left or right!
            yPos = [yCoords(1,yLocInd(1)),yCoords(2,yLocInd(2))]; % pick one top, one bottom!
        end
elseif nItems ==3
    xPos = [xCoords(1,xLocInd(1)),xCoords(2,xLocInd(2)),xCoords(1,xLocInd(3)),xCoords(2,xLocInd(4))]; % one L one R
    yPos = [yCoords(1,yLocInd(1)),yCoords(1,yLocInd(2)),yCoords(2,yLocInd(3)),yCoords(2,yLocInd(4))]; % one top one bottom for e/ L/R
    % let's use the same scheme as 4 items, but randomly leave one
    % out!
    randomOrder = randperm(4);
    xPos = xPos(randomOrder(1:3));
    yPos = yPos(randomOrder(1:3));
elseif nItems ==4
    xPos = [xCoords(1,xLocInd(1)),xCoords(2,xLocInd(2)),xCoords(1,xLocInd(3)),xCoords(2,xLocInd(4))]; % one L one R
    yPos = [yCoords(1,yLocInd(1)),yCoords(1,yLocInd(2)),yCoords(2,yLocInd(3)),yCoords(2,yLocInd(4))]; % one top one bottom for e/ L/R
elseif nItems ==5
    randomPosition = randi(2); % pick one of two quadrants to stick the second item
    while 1
        if randomPosition == 1
            xLocInd = Shuffle(xLocInd); yLocInd = Shuffle(yLocInd);
            xPos = [xCoords(1,xLocInd(1)),xCoords(2,xLocInd(2)),xCoords(1,xLocInd(3)),xCoords(2,xLocInd(4)),xCoords(1,xLocInd(5))];
            yPos = [yCoords(1,yLocInd(1)),yCoords(1,yLocInd(2)),yCoords(2,yLocInd(3)),yCoords(2,yLocInd(4)),yCoords(1,yLocInd(5))];
            % make sure that w/in quadrant points satisfy the minimum
            % distance requirement
            if sqrt(abs(xPos(1)-xPos(5))^2+abs(yPos(1)-yPos(5))^2)>minDist
                %             if sqrt((xPos(2)-xPos(6))^2+(yPos(2)-yPos(6))^2)>minDist
                break;
            end
        elseif randomPosition == 2
            xLocInd = Shuffle(xLocInd); yLocInd = Shuffle(yLocInd);
            xPos = [xCoords(1,xLocInd(1)),xCoords(2,xLocInd(2)),xCoords(1,xLocInd(3)),xCoords(2,xLocInd(4)),xCoords(2,xLocInd(5))];
            yPos = [yCoords(1,yLocInd(1)),yCoords(1,yLocInd(2)),yCoords(2,yLocInd(3)),yCoords(2,yLocInd(4)),yCoords(1,yLocInd(5))];
            % make sure that w/in quadrant points satisfy the minimum
            % distance requirement
            if sqrt((xPos(2)-xPos(5))^2+(yPos(2)-yPos(5))^2)>minDist
                break;
            end
        end
    end
elseif nItems ==6
    randomPosition = randi(6); % put extra squares in top or bottom half;
    while 1
        if randomPosition == 1 % both in top
            xLocInd = Shuffle(xLocInd); yLocInd = Shuffle(yLocInd);
            xPos = [xCoords(1,xLocInd(1)),xCoords(2,xLocInd(2)),xCoords(1,xLocInd(3)),xCoords(2,xLocInd(4)),xCoords(1,xLocInd(5)),xCoords(2,xLocInd(6))];
            yPos = [yCoords(1,yLocInd(1)),yCoords(1,yLocInd(2)),yCoords(2,yLocInd(3)),yCoords(2,yLocInd(4)),yCoords(1,yLocInd(5)),yCoords(1,yLocInd(6))];
            % make sure that w/in quadrant points satisfy the minimum
            % distance requirement
            if sqrt(abs(xPos(1)-xPos(5))^2+abs(yPos(1)-yPos(5))^2)>minDist % both in left top
                if sqrt((xPos(2)-xPos(6))^2+(yPos(2)-yPos(6))^2)>minDist % both in right top
                    break;
                end
            end
        elseif randomPosition == 2 % both in bottom
            xLocInd = Shuffle(xLocInd); yLocInd = Shuffle(yLocInd);
            xPos = [xCoords(1,xLocInd(1)),xCoords(2,xLocInd(2)),xCoords(1,xLocInd(3)),xCoords(2,xLocInd(4)),xCoords(1,xLocInd(5)),xCoords(2,xLocInd(6))];
            yPos = [yCoords(1,yLocInd(1)),yCoords(1,yLocInd(2)),yCoords(2,yLocInd(3)),yCoords(2,yLocInd(4)),yCoords(2,yLocInd(5)),yCoords(2,yLocInd(6))];
            % make sure that w/in quadrant points satisfy the minimum
            % distance requirement
            if sqrt(abs(xPos(3)-xPos(5))^2+abs(yPos(3)-yPos(5))^2)>minDist % both  in left bottom
                if sqrt((xPos(4)-xPos(6))^2+(yPos(4)-yPos(6))^2)>minDist   % both in right bottom
                    break;
                end
            end
        elseif randomPosition == 3 %both left
            xLocInd = Shuffle(xLocInd); yLocInd = Shuffle(yLocInd);
            xPos = [xCoords(1,xLocInd(1)),xCoords(2,xLocInd(2)),xCoords(1,xLocInd(3)),xCoords(2,xLocInd(4)),xCoords(1,xLocInd(5)),xCoords(1,xLocInd(6))];
            yPos = [yCoords(1,yLocInd(1)),yCoords(1,yLocInd(2)),yCoords(2,yLocInd(3)),yCoords(2,yLocInd(4)),yCoords(1,yLocInd(5)),yCoords(2,yLocInd(6))];
            % make sure that w/in quadrant points satisfy the minimum
            % distance requirement
            if sqrt(abs(xPos(1)-xPos(5))^2+abs(yPos(1)-yPos(5))^2)>minDist % both in left top
                if sqrt((xPos(3)-xPos(6))^2+(yPos(3)-yPos(6))^2)>minDist % both in left bottom
                    break;
                end
            end
        elseif randomPosition == 4 % both right
            xLocInd = Shuffle(xLocInd); yLocInd = Shuffle(yLocInd);
            xPos = [xCoords(1,xLocInd(1)),xCoords(2,xLocInd(2)),xCoords(1,xLocInd(3)),xCoords(2,xLocInd(4)),xCoords(2,xLocInd(5)),xCoords(2,xLocInd(6))];
            yPos = [yCoords(1,yLocInd(1)),yCoords(1,yLocInd(2)),yCoords(2,yLocInd(3)),yCoords(2,yLocInd(4)),yCoords(1,yLocInd(5)),yCoords(2,yLocInd(6))];
            % make sure that w/in quadrant points satisfy the minimum
            % distance requirement
            if sqrt(abs(xPos(2)-xPos(5))^2+abs(yPos(2)-yPos(5))^2)>minDist % both in right top
                if sqrt((xPos(4)-xPos(6))^2+(yPos(4)-yPos(6))^2)>minDist   % both in right bottom
                    break;
                end
            end
        elseif randomPosition == 5 % left up right down
            xLocInd = Shuffle(xLocInd); yLocInd = Shuffle(yLocInd);
            xPos = [xCoords(1,xLocInd(1)),xCoords(2,xLocInd(2)),xCoords(1,xLocInd(3)),xCoords(2,xLocInd(4)),xCoords(1,xLocInd(5)),xCoords(2,xLocInd(6))];
            yPos = [yCoords(1,yLocInd(1)),yCoords(1,yLocInd(2)),yCoords(2,yLocInd(3)),yCoords(2,yLocInd(4)),yCoords(1,yLocInd(5)),yCoords(2,yLocInd(6))];
            % make sure that w/in quadrant points satisfy the minimum
            % distance requirement
            if sqrt(abs(xPos(1)-xPos(5))^2+abs(yPos(1)-yPos(5))^2)>minDist % both in left top
                if sqrt((xPos(4)-xPos(6))^2+(yPos(4)-yPos(6))^2)>minDist  % both  in right bottom
                    break;
                end
            end
        elseif randomPosition == 6 %  right up left down
            xLocInd = Shuffle(xLocInd); yLocInd = Shuffle(yLocInd);
            xPos = [xCoords(1,xLocInd(1)),xCoords(2,xLocInd(2)),xCoords(1,xLocInd(3)),xCoords(2,xLocInd(4)),xCoords(2,xLocInd(5)),xCoords(1,xLocInd(6))];
            yPos = [yCoords(1,yLocInd(1)),yCoords(1,yLocInd(2)),yCoords(2,yLocInd(3)),yCoords(2,yLocInd(4)),yCoords(1,yLocInd(5)),yCoords(2,yLocInd(6))];
            % make sure that w/in quadrant points satisfy the minimum
            % distance requirement
            if sqrt(abs(xPos(2)-xPos(5))^2+abs(yPos(2)-yPos(5))^2)>minDist % both in right top
                if sqrt((xPos(3)-xPos(6))^2+(yPos(3)-yPos(6))^2)>minDist  % both in left bottom
                    break;
                end
            end
            
            
        end
    end
elseif nItems == 8
    while 1
        xLocInd = Shuffle(xLocInd); yLocInd = Shuffle(yLocInd);
        xPos = [xCoords(1,xLocInd(1)),xCoords(2,xLocInd(2)),xCoords(1,xLocInd(3)),xCoords(2,xLocInd(4)),xCoords(1,xLocInd(5)),xCoords(2,xLocInd(6)),xCoords(1,xLocInd(7)),xCoords(2,xLocInd(8))];
        yPos = [yCoords(1,yLocInd(1)),yCoords(1,yLocInd(2)),yCoords(2,yLocInd(3)),yCoords(2,yLocInd(4)),yCoords(1,yLocInd(5)),yCoords(1,yLocInd(6)),yCoords(2,yLocInd(7)),yCoords(2,yLocInd(8))];
        % make sure that w/in quadrant points satisfy the minimum
        % distance requirement
        if sqrt(abs(xPos(1)-xPos(5))^2+abs(yPos(1)-yPos(5))^2)>minDist
            if sqrt((xPos(2)-xPos(6))^2+(yPos(2)-yPos(6))^2)>minDist
                if sqrt((xPos(3)-xPos(7))^2+(yPos(3)-yPos(7))^2)>minDist
                    if sqrt((xPos(4)-xPos(8))^2+(yPos(4)-yPos(8))^2)>minDist
                        break;
                    end
                end
            end
        end
    end
end

%   coor = [xPos' yPos']; % set up nItemx X 2 matrix of center coordinates
%   rects = [coor(:, 1)-rect(3)/2 , coor(:, 2)-rect(3)/2, coor(:, 1)+rect(3)/2, coor(:, 2)+rect(3)/2]; %translate into rects based on stimSize (rect)

end
