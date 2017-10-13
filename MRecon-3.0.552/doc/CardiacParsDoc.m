classdef CardiacParsDoc
    % These are the cardiac parameters of the current scan, describing functionalities such as
    % cardiac triggering and respiratory synchronization/compensation. 
    properties (SetObservable) 
        Synchronization;        % The cardiac synchronization method which was used in the current scan. The values can be 'No', 'Trigger', 'Gate', 'Retro' and 'PhaseWindow'.
        RespSync;               % The respiratory synchronization method which was used in the current scan. The values can be 'No', 'Trigger', 'Breathold', 'Pear', 'Gate'.
        RespComp;               % The respiratory compensation method which was used in the current scan. The values can be 'No', 'Gate', 'Track', 'GateAndTrack', 'Trigger', 'TriggerAndTrack'.
        RetroPhases;            % The number of reconstructed heart phases in a retrospectively triggered scan.
        RetroBinning;           % The binning method for retrospective triggered scans. Possible values are: {'Relative'} = Every profile is assigned to a heart phase according to its relative trigger delay defined as: rtop/rr. 'Absolute' = Every profile is assigned to a heart phase according to its absolute trigger delay (rtop). The longest rr interval is taken as reference to calculate the duration of a heart phase. 'Mixed' = The systole is binned absolutely while the diastole is binned relatively. The duration of the systole is defined in the parameter RetroEndSystoleMs. The mean rr-interval is taken as reference to calculate the duration of a heart phase. 
        RetroEndSystoleMs;      % The duration of the systole used in 'Mixed' binning mode (see above)
        RetroHoleInterpolation; % The temporal interpolation method for missing k-space profiles after binning restrospective triggered scans. Possible values are: 'nearest' = Nearest neighbour interpolation, {'average'} = Average of the left and right neighbour, 'linear' = linear interpolation of the neighbours, 'cubic' = cubic interpolation of the neighbours
        HeartPhaseInterval;     % The duration of the heart phase interval in a cardiac scan.
        PhaseWindow;            % The user has the possibility to reconstruct a single heart phase of a retrospective triggered scan. This parameter determines the phase interval in ms. Please set the Synchronization to PhaseInterval to use this option.
        RNAV;                   % The respiratory navigator positions as calculated by the scanner
    end           
    methods        
        % ---------------------------------------------------------------%
        % Deep Copy of Class
        % ---------------------------------------------------------------%
        function new = Copy(this)            
        end
    end
end

