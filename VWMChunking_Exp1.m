% Chunking in Visual Working Memory 
% Experiment 1 - Colours Chunked as Learned Stimuli

% This project is designed to examine how the contralateral delay activity
% (CDA) is sensitive to chunking in visual working memory (VWM). The CDA is
% known to track online VWM load but it is unclear how it is influenced by
% the complexity of the items stored and how it is sensitive to the
% chunking of items in VWM. Knowing how the CDA can reveal how the VWM
% deals with compressing complex items into limited storage.

% In this experiment, participants will be shown the same conjunctions of
% colours repeatedly, using associative learning to chunk stimuli. From a
% set of eight colours, four colour pairs will be selected and shown as
% stimuli throughout the experiment. This simple pairing should result in
% participants learning the colour pairs and chunking them as one item.
% This chunking should result in a drop in the CDA amplitude to one that
% matches the number of chunked items.

% --------------------------- Change Log -------------------------------- %

% WXQN started writing this experimental code on 5/7/17.

% ----------------------------- Details --------------------------------- %

% This code and previous edits can be found at github.com/WilliamNgiam. 
% Email: william.ngiam@sydney.edu.au

% ----------------------------------------------------------------------- %

clear all;
Screen('CloseAll');

% Initial settings
porting = 1;

%% Set up experiment parameters

experiment.nConditions = 3;             % Number of conditions
experiment.nTrialsPerCondition = 120;   % Number of trials per condition 
experiment.nBlocks = 4;                 % Number of blocks
experiment.breakSecs = 60;              % Duration of break in seconds

%% Set up directories

rootDir = '/Users/wngi5916/Documents/MATLAB/VWMChunking/';

userDataDir = [rootDir, 'UserData/'];
bhvDataDir = [rootDir, 'Data/'];
eegDataDir = [rootDir, 'EEGData/'];

%% Set up equipment parameters

equipment.viewDist = 600;               % Viewing distance in mm - !remeasure!
equipment.ppm = 3.6;                    % Pixels per mm - !remeasure!
equipment.refreshRate = 1/120;          % Monitor - !remeasure!

equipment.blackVal = 0;
equipment.greyVal = .5;
equipment.whiteVal = 1;

%% Set up colour parameters

colour.yellow = [255, 255, 0];
colour.blue = [0, 0, 255];
colour.red = [255, 0, 0];
colour.green = [0, 255, 0];
colour.magenta = [255, 0, 255];
colour.cyan = [0, 255, 255];
colour.white = [255, 255, 255];
colour.black = [0, 0, 0];

colour.textVal = 0;
colour.fixVal = 1;
colour.probeVal = 0;

colour.orange = [1, 90/255, 71/255];
colour.purple = [160/255, 32/255, 140/255];             % Necessary for fixation?

%% Set up stimulus parameters

% Colours
stimulus.nColours = 8;                          % Total number of colours
stimulus.nPairs = stimulus.nColours/2;          % Total number of pairs
stimulus.colourList = {'Yellow', 'Blue', 'Red', 'Green', 'Magenta', 'Cyan', 'White', 'Black'};
stimulus.colours = [colour.yellow; colour.blue; colour.red; colour.green; colour.magenta; colour.cyan; colour.white; colour.black];

stimulus.innerSize_dva = 1.6;                   % Size of inner shape (diameter of circle, width of square)
stimulus.outerSize_dva = 2.5;                   % Size of outer shape (circle, square)        
stimulus.refSize_dva = mean([stimulus.innerSize_dva stimulus.outerSize_dva]);
stimulus.pairEccentricity_dva = 2.0;            % Eccentricity between (center of) colour pairs
stimulus.refEccentricity_dva = 3.5;             % Eccentricity between the colour references
stimulus.fixationEccentricity_dva = 3.4;        % Eccentricity of stimulus from fixation point

stimulus.foreEccentricity_dva = 5.8;            % Eccentricity of centre of the imaginary regions from fixation
stimulus.foreWidth_dva = 7.8;                   % Imaginary region width is 3.9 in retracted Anderson paper
stimulus.foreLength_dva = 8.6;                  % Imaginary region length is 4.3 in retracted Anderson paper
stimulus.foreBound_dva = stimulus.foreEccentricity_dva - (stimulus.foreWidth_dva/2);

% Fixation
stimulus.fixationOn = 1;                        % Toggle fixation on or off
stimulus.fixationSize_dva = .5;                 % Fixation size in degrees of visual angle

% Probe Rectangle
stimulus.thinPenWidth = 1;                      % Thin line for non-probed memoranda rect
stimulus.thickPenWidth = 3;                     % Thick line for probed memoranda rect

%% Set up timing parameters

timing.clickDelay = .2;     % Delay after mouse click
timing.cue = .5;            % Duration of direction cue
timing.memory = 1;          % Duration of memory array
timing.delay = 1;          % Duration of delay 
timing.ITI = .5;            % Inter-trial interval

%% Build GUI for participant information
rng('default');
rng('shuffle');             % Use MATLAB twister for rng
participant.rng = rng;      % Save rng structure

while true
    prompt = {'Participant Initials','Participant Age','Participant Gender','Participant Number','Random Seed'};
    rngSeed = participant.rng.Seed;
    defAns = {'XX','99','X','99',num2str(rngSeed)};
    box = inputdlg(prompt, 'Enter Subject Information', 1,defAns);
    participant.initials = char(box(1));
    participant.age = char(box(2));
    participant.gender = char(box(3));
    participant.ID = char(box(4));
    participant.rngSeed = char(box(5));
    if length(participant.initials) == 2 && length(participant.age) == 2 && length(participant.gender) == 1 && length(participant.ID) == 2
        break
    end
end

participant.ID = str2num(participant.ID);
cd(userDataDir);
participant.userFile = [num2str(participant.ID) '_VWMChunking_Exp1.mat'];
newUser = ~exist(participant.userFile,'file');

if ~newUser    
    duplicate = 1;
    while duplicate
    answer = input('Data file already exists! New participant number? ');
    participant.ID = answer;
    participant.userFile = [num2str(participant.ID) '_VWMChunking_Exp1.mat'];
        if ~exist(participant.userFile,'file')
            duplicate = 0;
        end    
    end
end

% Calculate participant parameters
participant.whichRandShape = mod(participant.ID,2)+1;       % Determines which shape used for random arrays
conditionOrder = perms(1:3);
whichConditionOrder = mod(participant.ID,6)+1;              % Determines starting condition
participant.condnOrder = conditionOrder(whichConditionOrder,:);

participant.whichColourCue = ceil((mod(participant.ID,4)+1)/2);

save(participant.userFile,'participant');

%% Set up Psychtoolbox Pipeline

AssertOpenGL;

% Imaging set-up
screenID = max(Screen('Screens'));
PsychImaging('PrepareConfiguration');
PsychImaging('AddTask', 'FinalFormatting', 'DisplayColorCorrection', 'SimpleGamma');
PsychImaging('AddTask', 'General', 'NormalizedHighresColorRange');
Screen('Preference','SkipSyncTests',0);

% Window set-up   
[ptbWindow, winRect] = PsychImaging('OpenWindow', screenID, equipment.greyVal,[],[],[],[],[],6);
[screenWidth, screenHeight] = RectSize(winRect);
screenCentreX = round(screenWidth/2);
screenCentreY = round(screenHeight/2);
flipInterval = Screen('GetFlipInterval', ptbWindow);

% Text set-up   
Screen('TextFont',ptbWindow,'Arial');
Screen('TextSize',ptbWindow,20);
Screen('TextStyle',ptbWindow,1);        % Bold text

global ptb_drawformattedtext_disableClipping;       % Disable clipping of text 
ptb_drawformattedtext_disableClipping = 1;

if porting
    
    config_io;
    portCode = hex2dec('D050');
    
    %% Set up port codes
    % Memory array port codes
    
    %%% 10 + 1 = 11 (2 items, LEFT)
    %%% 10 + 2 = 12 (2 items, RIGHT)
    %%% 20 + 1 = 21 (4 items paired, LEFT)
    %%% 20 + 2 = 22 (4 items paired, RIGHT)
    %%% 30 + 1 = 31 (4 items random, LEFT)
    %%% 30 + 2 = 32 (4 items random, RIGHT)
    
    % Trial port codes
    
    %%% 100 (Trial initiated)
    %%% 101 (Direction cue appears)    
    %%% 102 (Jitter)
    
    %%% 104 (Blank delay)
    %%% 105 (Probe display)
    %%% 106 (Response made)
    
    % Response codes
    
    %%% 90 (Incorrect)
    %%% 91 (Correct)
    
    port.codeNumbers = [11,12,21,22,31,32,100:105];
    port.codeLabels = {'2UL','2UR','4PL','4PR','4UL','4UR', ...
        'Trial Initiated','Direction Cue','Memory Array','Blank Delay','Probe Display', 'Response Made' ...
        'Incorrect', 'Correct'};
    
end

%% Calculate equipment parameters

equipment.mpd = (equipment.viewDist/2)*tan(deg2rad(2*stimulus.fixationEccentricity_dva))/stimulus.fixationEccentricity_dva;
equipment.ppd = equipment.ppm*equipment.mpd;        % Pixels per degree

%% Calculate spatial parameters

stimulus.innerSize_pix = round(stimulus.innerSize_dva*equipment.ppd);
stimulus.outerSize_pix = round(stimulus.outerSize_dva*equipment.ppd);
stimulus.refSize_pix = round(stimulus.refSize_dva*equipment.ppd);
stimulus.pairEccentricity_pix = round(stimulus.pairEccentricity_dva*equipment.ppd);
stimulus.refEccentricity_pix = round(stimulus.refEccentricity_dva*equipment.ppd);
stimulus.fixationSize_pix = stimulus.fixationSize_dva*equipment.ppd;
stimulus.fixationEccentricity_pix = round(stimulus.fixationEccentricity_dva*equipment.ppd);     % Eccentricity of stimulus in pixels

stimulus.foreEccentricity_pix = round(stimulus.foreEccentricity_dva*equipment.ppd);                % Eccentricity of centre of the imaginary regions from fixation
stimulus.foreWidth_pix = round(stimulus.foreWidth_dva*equipment.ppd);                              % Imaginary region width is 3.9 but subtracted half stimulus size
stimulus.foreLength_pix = round(stimulus.foreLength_dva*equipment.ppd);                            % Imaginary region length is 4.3 but subtracted half stimulus size
stimulus.foreBound_pix = round(stimulus.foreBound_dva*equipment.ppd);   

%% Calculate co-ordinates of the corners of fixation diamond

fixation_leftX = NaN(3,1);
fixation_rightX = NaN(3,1);
fixation_leftY = NaN(3,1);
fixation_rightY = NaN(3,1);
    
for thisCorner = 1:3

    fixation_leftY(thisCorner) = screenCentreY+((stimulus.fixationSize_pix*(thisCorner-2))/2);  % Generates y-coordinates

    if mod(thisCorner,2) == 1       % Generates x-coordinates
        
        fixation_leftX(thisCorner) = screenCentreX;
        fixation_rightX(thisCorner) = screenCentreX;
        
    elseif mod(thisCorner,2) == 0
        
        fixation_leftX(thisCorner) = screenCentreX-(stimulus.fixationSize_pix/2);
        fixation_rightX(thisCorner) = screenCentreX+(stimulus.fixationSize_pix/2);
    
    end
    
end

fixation_rightY = fixation_leftY;
    
stimulus.fixation_left = [fixation_leftX fixation_leftY];       % Combining coordinates into one matrix
stimulus.fixation_right = [fixation_rightX fixation_rightY];

%% Set up location rects

fixRect = [0 0 stimulus.fixationSize_pix stimulus.fixationSize_pix];    % Fixation rect
fixRect = CenterRectOnPoint(fixRect, screenCentreX, screenCentreY);     % Centred in the middle of the screen

innerColourRect = [0 0 stimulus.innerSize_pix stimulus.innerSize_pix];                 % Colour stimulus rect
outerColourRect = [0 0 stimulus.outerSize_pix stimulus.outerSize_pix];
awareRect = CenterRectOnPoint(innerColourRect, screenCentreX, screenCentreY);

foreRect = [0 0 stimulus.foreWidth_pix stimulus.foreLength_pix];

%% Build location rects of the colours for EEG display

% Build two imaginary square regions

leftRegionRect = round(CenterRectOnPoint(foreRect, screenCentreX-stimulus.foreEccentricity_pix, screenCentreY));
rightRegionRect = round(CenterRectOnPoint(foreRect, screenCentreX+stimulus.foreEccentricity_pix, screenCentreY));     

% Build probe rects of the response screen

innerProbeRect = [0 0 stimulus.innerSize_pix stimulus.innerSize_pix];
outerProbeRect = [0 0 stimulus.outerSize_pix stimulus.outerSize_pix];

% Build location rects of the reference colours

refRect = [0 0 stimulus.refSize_pix stimulus.refSize_pix];        % Same size as colour rects
refRects = NaN(4,stimulus.nColours);
refJitter = [1:stimulus.nColours]-((stimulus.nColours+1)/2);  % Reference of the colour blocks
       
for thisItem = 1:stimulus.nColours
    
    refRects(:,thisItem) = round(CenterRectOnPoint(refRect, screenCentreX+(refJitter(thisItem)*stimulus.refEccentricity_pix),screenCentreY+2.5*stimulus.refEccentricity_pix));
   
end

%% Calculate stimulus parameters

% Select the colour pairs for paired condition
randColours = randperm(stimulus.nColours);      % Creates a random order from 1 to the number of colours
stimulus.colourPairs = reshape(randColours,stimulus.nPairs,2);     % Reshapes vector into a matrix of pairs

for thisPair = 1:stimulus.nPairs
    
    for thisColour = 1:2
        
        stimulus.colourPairNames(thisPair, thisColour) = stimulus.colourList(stimulus.colourPairs(thisPair,thisColour));
    
    end
    
end

%% ----- Start Experiment Loop --- %%

ListenChar(2);

% Instruction Text

startText = ['In this study, you will be required to remember the location of colours on one side of the screen.' ...
    '\n\nTo start each trial, you need to click on the diamond in the middle of the screen.' ...
    '\nThe diamond will change to two colours indicating which side of the screen you have to attend.' ...
    '\n\nShortly after, colours will briefly appear on both sides of the screen before disappearing.' ...
    '\nAfter a delay, you will be required to report which colour appeared at a location that is bolded.' ...
    '\nRespond by clicking on the colour at the bottom of the screen.' ...
    '\n\n\nPlease ask the experimenter if you have any questions.'];

if participant.whichColourCue == 1      % Use orange to cue
    
    colour.cueVal = colour.orange;
    colour.notCueVal = colour.purple;

    whichColourText = ['You will need to attend to the side of the diamond that is ORANGE.' ...
        '\nHowever, it is important you keep your eyes fixed on the diamond after you click.' ...
        '\nTry and resist the urge to move your eyes from the diamond when the colours appear.' ...
        '\nYou may blink and move your eyes only when you are making a response and before you click to start the next trial.'];
    
elseif participant.whichColourCue == 2      % User purple to cue
    
    colour.cueVal = colour.purple;
    colour.notCueVal = colour.orange;
   
    whichColourText = ['You will need to attend to the side of the diamond that is PURPLE.' ...
        '\nHowever, it is important you keep your eyes fixed on the diamond after you click.' ...
        '\nTry to resist the urge to move your eyes from the diamond when the colours appear on the screen.' ...
        '\nYou may blink and move your eyes only when you are making a response and before you click to start the next trial.'];

end
 
startRecordText = ['Please wait for the experimenter to start recording.'];

DrawFormattedText(ptbWindow,startText,'center','center',colour.textVal);
startTime = Screen('Flip',ptbWindow);
waitResponse = 1;

while waitResponse
    
    [time, keyCode] = KbWait(-1,2);
    waitResponse = 0;
    
end

DrawFormattedText(ptbWindow,whichColourText,'center','center',colour.textVal);
Screen('Flip',ptbWindow);
waitResponse = 1;

while waitResponse
    
    [time, keyCode] = KbWait(-1,2);
    waitResponse = 0;
    
end

Screen('Flip',ptbWindow);

DrawFormattedText(ptbWindow,startRecordText,'center','center',colour.textVal);
Screen('Flip',ptbWindow);
waitResponse = 1;

while waitResponse
    
    [time, keyCode] = KbWait(-1,2);
    waitResponse = 0;
    
end

for thisCondition = 1:experiment.nConditions
    
    whichCondition = participant.condnOrder(thisCondition);
    
    if whichCondition == 2      % If 4-item paired condition
    
        whichShape = 3-participant.whichRandShape;        % Retrieves participant's random shape
      
    else
        
        whichShape = participant.whichRandShape;
        
    end
    
    if whichCondition == 1
        
        stimulus.nItems = 2;        % 2-item condition
        
    else
        
        stimulus.nItems = 4;        % 4-item condition
        
    end
    
    % Start condition text
    
    if whichCondition == 1
    
        startConditionText = ['In this session, two items will appear on each side of the screen.' ...
            '\n\nPress the spacebar to begin.'];
        
    else
        
        startConditionText = ['In this session, four items will appear on each side of the screen.' ...
            '\n\nPress the spacebar to begin.'];
        
    end
    
    DrawFormattedText(ptbWindow,startConditionText,'center','center',colour.textVal);
    Screen('Flip',ptbWindow);
    waitResponse = 1;
    
    while waitResponse
        
        [startBlockTime, keyCode] = KbWait(-1,2);
        waitResponse = 0;
        
    end
    
    % Set up condition block parameters
    
    trialsPerBlock = ceil(experiment.nTrialsPerCondition/experiment.nBlocks);
    stopTrials = 0:trialsPerBlock:experiment.nTrialsPerCondition;
    stopTrials(1) = [];
    stopTrials(numel(stopTrials)) = [];
    
    block.allLColours = NaN(experiment.nTrialsPerCondition,stimulus.nItems);
    block.allRColours = NaN(experiment.nTrialsPerCondition,stimulus.nItems);
    
    block.allLCoords = NaN(experiment.nTrialsPerCondition,2,2);
    block.allRCooords = NaN(experiment.nTrialsPerCondition,2,2);
    block.allLRects = NaN(experiment.nTrialsPerCondition,stimulus.nItems,4);
    block.allRRects = NaN(experiment.nTrialsPerCondition,stimulus.nItems,4);
    
    block.allProbes = mod(randperm(experiment.nTrialsPerCondition),stimulus.nItems)+1;
    
    block.allResponseColour = NaN(experiment.nTrialsPerCondition,1);
    block.allCorrect = NaN(experiment.nTrialsPerCondition,1);
    block.allRT = NaN(experiment.nTrialsPerCondition,1);
    
    block.allCueJitter = (mod(randperm(experiment.nTrialsPerCondition),3)-1)*.1;
    block.allCueDirection = mod(randperm(experiment.nTrialsPerCondition),2)+1;
    
    % Build which side will be tested 

    block.allTargetSide = mod(randperm(experiment.nTrialsPerCondition),2)+1;

    % Build location rects for every trial in this condition
    
    for thisTrial = 1:experiment.nTrialsPerCondition
    
        % For all conditions, pick two coordinates in the left and right
        % regions.
        
        [Lx,Ly] = randomArrayCoords(leftRegionRect,2,stimulus.innerSize_pix*2);
        [Rx,Ry] = randomArrayCoords(rightRegionRect,2,stimulus.innerSize_pix*2);
    
        for thisCoord = 1:2
            
                block.allLCoords(thisTrial,thisCoord,:) = round([Lx(thisCoord) Ly(thisCoord)]);
                block.allRCoords(thisTrial,thisCoord,:) = round([Rx(thisCoord) Ry(thisCoord)]);
             
        end
        
        if whichCondition == 1
            
            for thisColour = 1:stimulus.nItems      % 2-item conditions

                block.allLRects(thisTrial,thisColour,:) = CenterRectOnPoint(outerColourRect, ...
                    block.allLCoords(thisTrial,thisColour,1),block.allLCoords(thisTrial,thisColour,2));
                block.allRRects(thisTrial,thisColour,:) = CenterRectOnPoint(outerColourRect, ...
                    block.allRCoords(thisTrial,thisColour,1),block.allRCoords(thisTrial,thisColour,2));
                
            end
            
        elseif whichCondition ~= 1
            
            for thisPair = 1:stimulus.nItems/2        % 4-item conditions
        
                for thisColour = 1:2
                    
                    if thisColour == 1      % Outer colour rect

                        block.allLRects(thisTrial,thisPair*2-1,:) = CenterRectOnPoint(outerColourRect, ...
                            block.allLCoords(thisTrial,thisPair,1),block.allLCoords(thisTrial,thisPair,2));

                        block.allRRects(thisTrial,thisPair*2-1,:) = CenterRectOnPoint(outerColourRect, ...
                        block.allRCoords(thisTrial,thisPair,1),block.allRCoords(thisTrial,thisPair,2));

                    elseif thisColour == 2  % Inner colour rect

                        block.allLRects(thisTrial,thisPair*2,:) = CenterRectOnPoint(innerColourRect, ...
                            block.allLCoords(thisTrial,thisPair,1),block.allLCoords(thisTrial,thisPair,2));

                        block.allRRects(thisTrial,thisPair*2,:) = CenterRectOnPoint(innerColourRect, ...
                            block.allRCoords(thisTrial,thisPair,1),block.allRCoords(thisTrial,thisPair,2));

                    end
                    
                end
                
            end
                
        end
        
        % Select the colours to be shown in this condition block
        
        if whichCondition ~= 2      % Is not the 4 item paired condition
            
            allColours = randperm(stimulus.nColours,stimulus.nItems*2);
            block.allLColours(thisTrial,:) = allColours(1:stimulus.nItems);
            block.allRColours(thisTrial,:) = allColours(stimulus.nItems+1:stimulus.nItems*2);

        elseif whichCondition == 2  % Is the 4 item paired condition
            
            if block.allTargetSide(thisTrial) == 1      % Target on the left side
            
                whichPairs = randperm(stimulus.nPairs,2);
                block.allLColours(thisTrial,:) = reshape(stimulus.colourPairs(whichPairs,:)',1,stimulus.nItems);

                whichColours = randperm(stimulus.nColours,stimulus.nItems);
                block.allRColours(thisTrial,:) = whichColours;
            
            elseif block.allTargetSide(thisTrial) == 2  % Target on the right side
                
                whichPairs = randperm(stimulus.nPairs,2);
                block.allRColours(thisTrial,:) = reshape(stimulus.colourPairs(whichPairs,:)',1,stimulus.nItems);
                
                whichColours = randperm(stimulus.nColours,stimulus.nItems);
                block.allLColours(thisTrial,:) = whichColours;
                
            end
            
        end   
        
    end
    
  
    % Start Block Time
    
    endTrialTime = Screen('Flip',ptbWindow);
    
    % --- Start trial loop --- %

    for thisTrial = 1:experiment.nTrialsPerCondition
        
        % Get trial parameters
        thisTrialLRects = block.allLRects(thisTrial,:,:);
        thisTrialRRects = block.allRRects(thisTrial,:,:);
        
        thisTrialLColours = block.allLColours(thisTrial,:);
        thisTrialRColours = block.allRColours(thisTrial,:);
        
        thisTargetSide = block.allTargetSide(thisTrial);
        
        thisProbeLoc = block.allProbes(thisTrial);
        
        % Participant initiates trial with mouse click at fixation
        ShowCursor(0);
        
        if stimulus.fixationOn
            
            Screen('FillPoly',ptbWindow,colour.fixVal,stimulus.fixation_left);
            Screen('FillPoly',ptbWindow,colour.fixVal,stimulus.fixation_right);
            
        end
        
        waitClickTime = Screen('Flip',ptbWindow,endTrialTime+timing.ITI);    
        
        CheckResponse = zeros(1,stimulus.nColours);
        
        while ~any(CheckResponse)
            
            [~,xClickResponse,yClickResponse] = GetClicks(ptbWindow,0);
            clickTime = GetSecs;
        
            CheckResponse(thisColour) = IsInRect(xClickResponse,yClickResponse,fixRect);
        
        end
   
        % Start trial by disappearing mouse
        
        HideCursor;
        
        if stimulus.fixationOn
            
            Screen('FillPoly',ptbWindow,colour.fixVal,stimulus.fixation_left);
            Screen('FillPoly',ptbWindow,colour.fixVal,stimulus.fixation_right);
            
        end
        
        startTrialTime = Screen('Flip',ptbWindow,clickTime+(2.5*equipment.refreshRate));
        
        if porting
            
            outp(portCode,100);     % Trial start
            
        end
        
        % Show direction cue
        
        if stimulus.fixationOn
            
            if thisTargetSide == 1      % Target on left side
                
                Screen('FillPoly',ptbWindow,colour.cueVal,stimulus.fixation_left);
                Screen('FillPoly',ptbWindow,colour.notCueVal,stimulus.fixation_right);
                
            elseif thisTargetSide == 2  % Target on right side
                
                Screen('FillPoly',ptbWindow,colour.notCueVal,stimulus.fixation_left);
                Screen('FillPoly',ptbWindow,colour.cueVal,stimulus.fixation_right);
                
            end
            
        end
        
        cueDirectionTime = Screen('Flip',ptbWindow,startTrialTime+timing.clickDelay-.5*equipment.refreshRate);
        
        if porting
            
            outp(portCode,101);     % Direction cue
            
        end
        
        % Display fixation point with jitter timing
        
        if stimulus.fixationOn

            Screen('FillPoly',ptbWindow,colour.fixVal,stimulus.fixation_left);
            Screen('FillPoly',ptbWindow,colour.fixVal,stimulus.fixation_right);

        end
        
        jitterTime = Screen('Flip',ptbWindow,cueDirectionTime+timing.cue-.5*equipment.refreshRate);
        
        if porting
            
            outp(portCode,102);     % Jitter
            
        end
        
        % Build the stimuli display for this trial
        
        for thisColour = 1:stimulus.nItems
            
            thisLColour = thisTrialLColours(thisColour);
            thisRColour = thisTrialRColours(thisColour);

            thisLRect = squeeze(block.allLRects(thisTrial,thisColour,:))';
            thisRRect = squeeze(block.allRRects(thisTrial,thisColour,:))';

            if whichShape == 1

                Screen('FillRect',ptbWindow,[stimulus.colours(thisLColour,:)],thisLRect);
                Screen('FillRect',ptbWindow,[stimulus.colours(thisRColour,:)],thisRRect);
                Screen('FrameRect',ptbWindow,colour.probeVal,thisLRect,stimulus.thinPenWidth);
                Screen('FrameRect',ptbWindow,colour.probeVal,thisRRect,stimulus.thinPenWidth);
                        
            elseif whichShape == 2

                Screen('FillOval',ptbWindow,[stimulus.colours(thisLColour,:)],thisLRect);
                Screen('FillOval',ptbWindow,[stimulus.colours(thisRColour,:)],thisRRect);
                Screen('FrameOval',ptbWindow,colour.probeVal,thisLRect,stimulus.thinPenWidth);
                Screen('FrameOval',ptbWindow,colour.probeVal,thisRRect,stimulus.thinPenWidth);
    
            end
            
        end
        
        % Draw the stimuli display
        
        if stimulus.fixationOn
            
            Screen('FillPoly',ptbWindow,colour.fixVal,stimulus.fixation_left);
            Screen('FillPoly',ptbWindow,colour.fixVal,stimulus.fixation_right);
            
        end
        
        stimDisplayTime = Screen('Flip',ptbWindow,jitterTime+timing.ITI+block.allCueJitter(thisTrial)-.5*equipment.refreshRate);
        
        if porting
            
            %%% Memory array port codes
                
            %%% 10 + 1 = 11 (2 items, LEFT)
            %%% 10 + 2 = 12 (2 items, RIGHT)
            %%% 20 + 1 = 21 (4 items paired, LEFT)
            %%% 20 + 2 = 22 (4 items paired, RIGHT)
            %%% 30 + 1 = 31 (4 items random, LEFT)
            %%% 30 + 2 = 32 (4 items random, RIGHT)
            
            outp(portCode,whichCondition*10+thisTargetSide);
            
        end
        
        % Flip to blank
        
        if stimulus.fixationOn
             
            Screen('FillPoly',ptbWindow,colour.fixVal,stimulus.fixation_left);
            Screen('FillPoly',ptbWindow,colour.fixVal,stimulus.fixation_right);
            
        end
  
        blankTime = Screen('Flip',ptbWindow,stimDisplayTime+timing.memory-.5*equipment.refreshRate);
        
        if porting
            
            outp(portCode,104);     % Blank delay
            
        end
        
        % Retrieve probed colour
        
        if thisTargetSide == 1
            
            thisProbeColour = thisTrialLColours(thisProbeLoc);
            
        elseif thisTargetSide == 2
            
            thisProbeColour = thisTrialRColours(thisProbeLoc);
            
        end
        
        % Build the memoranda display with probed location
        
        for thisItem = 1:stimulus.nItems
            
            thisLRect = squeeze(block.allLRects(thisTrial,thisItem,:))';
            thisRRect = squeeze(block.allRRects(thisTrial,thisItem,:))';
            
            if thisTargetSide == 1              % Left side cued
                
                if whichShape == 1          % Squares
                    
                    if thisItem ~= thisProbeLoc

                        Screen('FrameRect',ptbWindow,colour.probeVal,thisLRect,stimulus.thinPenWidth);
                        Screen('FrameRect',ptbWindow,colour.probeVal,thisRRect,stimulus.thinPenWidth);

                    elseif thisItem == thisProbeLoc

                        Screen('FrameRect',ptbWindow,colour.probeVal,thisLRect,stimulus.thickPenWidth);
                        Screen('FrameRect',ptbWindow,colour.probeVal,thisRRect,stimulus.thinPenWidth);

                    end
                
                elseif whichShape == 2      % Ovals

                    if thisItem ~= thisProbeLoc

                        Screen('FrameOval',ptbWindow,colour.probeVal,thisLRect,stimulus.thinPenWidth);
                        Screen('FrameOval',ptbWindow,colour.probeVal,thisRRect,stimulus.thinPenWidth);

                    elseif thisItem == thisProbeLoc

                        Screen('FrameOval',ptbWindow,colour.probeVal,thisLRect,stimulus.thickPenWidth);
                        Screen('FrameOval',ptbWindow,colour.probeVal,thisRRect,stimulus.thinPenWidth);

                    end
                
                end
                
            elseif thisTargetSide == 2          % Right side cued
                
                if whichShape == 1          % Squares
                    
                    if thisItem ~= thisProbeLoc
                        
                        Screen('FrameRect',ptbWindow,colour.probeVal,thisLRect,stimulus.thinPenWidth);
                        Screen('FrameRect',ptbWindow,colour.probeVal,thisRRect,stimulus.thinPenWidth);
                        
                    elseif thisItem == thisProbeLoc
                        
                        Screen('FrameRect',ptbWindow,colour.probeVal,thisLRect,stimulus.thinPenWidth);
                        Screen('FrameRect',ptbWindow,colour.probeVal,thisRRect,stimulus.thickPenWidth);
                        
                    end
                    
                elseif whichShape == 2      % Ovals
                    
                    if thisItem ~= thisProbeLoc
                        
                        Screen('FrameOval',ptbWindow,colour.probeVal,thisLRect,stimulus.thinPenWidth);
                        Screen('FrameOval',ptbWindow,colour.probeVal,thisRRect,stimulus.thinPenWidth);
                        
                    elseif thisItem == thisProbeLoc
                        
                        Screen('FrameOval',ptbWindow,colour.probeVal,thisLRect,stimulus.thinPenWidth);
                        Screen('FrameOval',ptbWindow,colour.probeVal,thisRRect,stimulus.thickPenWidth);
                        
                    end
                    
                end
                
            end
            
        end
        
        % Build reference display for response
        
        for thisColour = 1:stimulus.nColours
            
            if whichShape == 1
                
                Screen('FillRect',ptbWindow,stimulus.colours(thisColour,:),refRects(:,thisColour));
            
            elseif whichShape == 2
                
                Screen('FillOval',ptbWindow,stimulus.colours(thisColour,:),refRects(:,thisColour));
                
            end
            
        end
        
        % Draw the screen
        
        if stimulus.fixationOn
            
            Screen('FillPoly',ptbWindow,colour.fixVal,stimulus.fixation_left);
            Screen('FillPoly',ptbWindow,colour.fixVal,stimulus.fixation_right);
            
        end
        
        responseTime = Screen('Flip',ptbWindow,blankTime+timing.delay-.5*equipment.refreshRate);
        
        if porting
            
            outp(portCOde,105);     % Probe display
            
        end
        
        % Get participant mouse click response
        ShowCursor(0);
        SetMouse(screenCentreX,screenCentreY,ptbWindow);
        CheckResponse = zeros(1,stimulus.nColours);
        
        while ~any(CheckResponse)
            
            [~,xClickResponse,yClickResponse] = GetClicks(ptbWindow,0);     % Retrieves click
            clickSecs = GetSecs;
            
            for thisColour = 1:stimulus.nColours
                
                CheckResponse(thisColour) = IsInRect(xClickResponse,yClickResponse,refRects(:,thisColour));
                
            end
            
        end
        
        responseColour = find(CheckResponse);
        
        % Save response
        block.allResponseColour(thisTrial) = responseColour;
        block.allRT(thisTrial) = clickSecs - responseTime;
        
        if block.allResponseColour(thisTrial) == thisProbeColour
            
            block.allCorrect(thisTrial) = 1;
            
        else
            
            block.allCorrect(thisTrial) = 0;
            
        end
        
        endTrialTime = Screen('Flip',ptbWindow);
        
        if porting
            
            outp(portCode,106);     % Response made
            
        end
        
        % End block if on stop trial
        
        if ismember(thisTrial,stopTrials)       % Is stop trial
            
            whichBlock = find(thisTrial==stopTrials);
            
            for thisSec = 1:experiment.breakSecs
            
                endBlockText = ['Please take a short break.' ...
                '\nYou have completed ' num2str(whichBlock) ' out of ' num2str(experiment.nBlocks) ' blocks.' ...
                '\n\nTime remaining: ' num2str(experiment.breakSecs-thisSec)];
                DrawFormattedText(ptbWindow,endBlockText,'center','center',colour.textVal);
                Screen('Flip',ptbWindow);
                WaitSecs(1);
            
            end
            
        end
               
    end
    
    % Save a block file
    
    cd(bhvDataDir);
    blockFileName = [num2str(participant.ID) '_VWMChunking_Exp1_' num2str(whichCondition) '.mat'];
    save(blockFileName,'block','experiment','equipment','colour','stimulus','timing','participant','startBlockTime');
     
    % Completed condition text
    
    for thisSec = 1:experiment.breakSecs
    
        endConditionText = ['You have completed this session.' ...
            '\nPlease take a break before starting the next session.' ...
            '\n\nTime remaining: ' num2str(experiment.breakSecs - thisSec)];
        
        DrawFormattedText(ptbWindow,endConditionText,'center','center',colour.textVal);
        Screen('Flip',ptbWindow);
        WaitSecs(1);
        
    end
    
        
end

% Completed experiment text

endExperimentText = ['Thank you for completing the study!' ...
    '\n\nPlease wait for the experimenter.'];

DrawFormattedText(ptbWindow,endExperimentText,'center','center',colour.textVal);
Screen('Flip',ptbWindow);
waitResponse = 1;

while waitResponse
    
    [time, keyCode] = KbWait(-1,2);
    waitResponse = 0;
    
end

% Pack up and go home
ListenChar;
Screen('CloseAll');
clear all;
close all;
