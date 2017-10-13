classdef ReconParsDoc
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties 
        DcOffsetCorrection          = 'Yes';            % Enables/disables the DC offset correction
        PDACorrection               = 'Yes';            % Enables/disables the profile dependent amplification correction
        RandomPhaseCorrection       = 'Yes';            % Enables/disables the random phase correction correction
        MeasPhaseCorrection         = 'Yes';            % Enables/disables the measurement phase correction
        PartialFourier              = 'Yes';            % Enables/disables the partial fourier reconstruction
        Gridding                    = 'Yes';            % Enables/disables the gridding
        RingingFilter               = 'Yes';            % Enables/disables the ringing filter
        RingingFilterStrength       = [0.25,0.25,0.25]; % [0-1]. The strength of the ringing filter. 0 means no filter is applied. 1 is the maximim filter strength
        kSpaceZeroFill              = 'Yes';            % Enables/disables the zero filling in k-space
        EPIPhaseCorrection          = 'Yes';            % Enables/disables the EPI correction
        EPICorrectionMethod         = 'Linear';         % Specifies the EPI correction method. The odd/even profiles are either corrected using a linear or nonlinear phase. Possible values are 'Linear', 'Nonlin'. 
        EPI2DCorr                   = 'Yes';            % Enables/disables the EPI correction
        CoilCombination             = 'sos';            % Specifies the Coil Combination Method
        ImageSpaceZeroFill          = 'Yes';            % Enables/disables the zero filling in image-space
        RotateImage                 = 'Yes';            % Enables/disables the image rotation
        GeometryCorrection          = 'Yes';            % Enables/disables the geometry correction
        RemoveMOversampling         = 'Yes';            % Enables/disables the oversamping removal in readout direction
        RemovePOversampling         = 'Yes';            % Enables/disables the oversamping removal in phase-encoding direction(s)
        ConcomitantFieldCorrection  = 'Yes';            % Enables/disables the concomitant field correction
        ArrayCompression            = 'No';             % Enables/diasables the array compression which reduces the amount of data by compression the physical channels into a lower number of virtual channels when reading the raw file. Array compression is implemented according to: Buehrer, M., Pruessmann, K. P., Boesiger, P. and Kozerke, S. (2007), Array compression for MRI with large coil arrays. Magnetic Resonance in Medicine, 57: 1131–1139.
        ACNrVirtualChannels         = []                % The number of virtual channels in the array compression
        ACMatrix                    = [];               % The comppression matrix used in array compression
        ImmediateAveraging          = 'Yes';            % Enables/disables the averaging during SortData. When enabled the averages are sumed up in k-space when the data is sorted. If the individual averages should be reconstructed then disable this function. Please note that immediate averaging should be disabled for diffusion imaging. 
        ExportRECImgTypes           = { 'M' };          % Specifies which images types are exported into the rec file when WriteRec is called. Possible values are: M (Magnitude), P (Phase), R (Real part), I (Imaginary part). 
        AutoUpdateInfoPars          = 'Yes';            % Specifies if the ImageInformation parameters are updated after every reconstruction step. The ImageInformation parameters are used to write the .par/.xml files when exporting the data to rec format. If par/rec export is not used the disable this functionality for increased speed. 
        SENSE                       = 'Yes';            % Enables/disables the SENSE unfolding
        Sensitivities               = [];               % The sensitivity object (MRsense) used in the unfolding process. The sensitivity object holds the coil sensitivities, the noise covariance matrix as well as regularisation images.
        SENSERegStrength            = 2;                % The regularization strength used during the SENSE unfolding. A higher regularizazion results in a stronger suppression of low signal values in the unfolded images. 
        StatusMessage               = 'Yes';            % Enables/disables the starus message during reconstruction. 
        Logging                     = 'No'
		EddyCurrentCorrection 		= 'No'; 			% Enables/disables the Klose eddy current correction for spectroscopic data
    end
            
    methods        
        function InitReconPars( )           
        end
        function new = Copy(this)
            % Instantiate new object of the same class.            
        end
    end       
end

