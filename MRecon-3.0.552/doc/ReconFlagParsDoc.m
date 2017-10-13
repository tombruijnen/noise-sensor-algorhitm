classdef ReconFlagParsDoc
    %UNTITLED9 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        isread            = 0;          % Specifies if the data is already read
        issorted          = 0;          % Specifies if the data is already sorted
        ispartialfourier  = [0, 0];     % Specifies if the data is already partial fourier reconstructed. The first number specifies if the homodyne filter has already been applied in k-space and the second if the low resolution phase has been added to the data in image space.
        isgridded         = 0;          % Specifies if the data is already gridded
        isimspace         = [0,0,0];    % Specifies which dimensions are in image space and which in k-space (matrix notation)
        iscombined        = 0;          % Specifies if the coil combination is already performed
        isoversampled     = [0,0,0];    % Specifies if the oversampling is already removed (one flag for every direction)
        isreadparameter   = 0;          % Specifies if the parameter file is already read
        israndphasecorr   = 0;          % Specifies if the random phase correction is already performed
        ispdacorr         = 0;          % Specifies if the profile dependent amplification correction is already performed
        isdcoffsetcorr    = 0;          % Specifies if the DC-offset correction is already performed
        isdepicorr        = 0;          % Specifies if the EPI correction is already performed
        ismeasphasecorr   = 0;          % Specifies if the measurement phase correction is already performed
        isunfolded        = 0;          % Specifies if the data is already SENSE unfolded
        iszerofilled      = [0,0];      % Specifies if the data is already zero-filled
        isrotated         = 0;          % Specifies if the images are already rotated.
        isconcomcorrected = 0;          % Specifies if the concomitant field correction is already performed
        isgeocorrected    = 0;          % Specifies if the geometry correction is already performed
		isecc			  = 0;			% Specifies if eddy current correction has already been applied
		isaveraged 		  = 0; 			% Specifies if the FIDs have already been averaged
    end
    
    methods       
        function Init( DataFormat )                        
        end
        function new = Copy(this)
            % Instantiate new object of the same class.            
        end
            
    end
    
end

