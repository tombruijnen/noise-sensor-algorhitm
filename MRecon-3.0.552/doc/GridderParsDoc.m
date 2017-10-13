classdef GridderParsDoc
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        % Preset - The gridder preset. When set the trajectory and all necessray parameters for the
        % current scan are calculated. Possible values are 'Radial', 'Spiral', 'EPI'.
        Preset               = 'none';  
        % Kooshball - Specifies if a 3D radial scan is sampled on a kooshball trajectory.
        KooshBall            = [];
        % SpiralLeadingSamples - Specifies the number of samples which should be omitted in the
        % beginning of a spiral trajectory. This is de to the fact that the first acquired sample of
        % a spiral readout does not correspond to the k-space center. 
        SpiralLeadingSamples = [];
        % Kpos - The k-space trajectory used for gridding. A vector of 3 coordinates (kx, ky, kz) is
        % assignied to every sample in the Data array. Therefore Kpos must have the dimensions:
        % [size(r.Data,1), size(r.Data,2), size(r.Data,3), 3], where r.Data correspnds to the Data
        % array before calling GridData. For more information see example 2) in the documentation of
        % <a href="matlab:helpwin('MRecon.GridData')">GridData</a>. The k-space coordinates are normalized to a range of -floor(n/2):ceil(n/2)-1, 
        % where n is the number of samples:
        Kpos                 = [];
        % The angles for a radial acquisiton. When set every acquired profile is assigned an angle.
        % Use this parameter to reconstruct golden angle acquistions for example. For more
        % information see example 1) in the documentation of <a href="matlab:helpwin('MRecon.GridData')">GridData</a>.
        RadialAngles         = [];
        % The gridder weights corresponding to the sampling densitiy in k-space. A weight is
        % assigned to every sample in the Data array. Therefore Weights must have the dimensions:
        % [size(r.Data,1), size(r.Data,2), size(r.Data,3)], where r.Data correspnds to the Data
        % array before calling GridData
        Weights              = [];
        % The gridding oversampling factor. For more information see example 3) in the documentation
        % of <a href="matlab:helpwin('MRecon.GridData')">GridData</a>.
        GridOvsFactor        = [];
        % The output matrix size after gridding. For more information see example 3) in the 
        % documentation of <a href="matlab:helpwin('MRecon.GridData')">GridData</a>.
        OutputMatrixSize     = [];
        % The width of the bessel kernel used in the gridder
        KernelWidth          = 4 %(4)   
        % Specifies if the images should be corrected for signal weighting in image space
        % introduced by the convolution with the bessel kernel. See <a href="matlab:helpwin('MRecon.GridderNormalization')">GridderNormalization</a>
        % fr more information.
        Normalize            = 'yes';  
        % Specifies if a phase correction should be performed in the radial profiles. In radial
        % imaging every even profile is measured "forward" in k-space while every odd profile is
        % acquired "backward". Due to eddy current effects however the positve "forward" gradients
        % are not exactly the same as the negativ "backward" gradients. This introduces a temporal
        % shift of the profiles in k-space, which will be corrected here. 
        RadialPhaseCorr      = 'yes';
        % Specifies if the radial sampling direction is alternating
        % (forward backward sampling) or non-alternating. On the scanner
        % this is a control parameter whos default value is alternating
        AlternatingRadial    = 'yes';
    end        
    
    methods             
        function Reset()
        % Resets the gridder parameter                        
        end    
        % ---------------------------------------------------------------%
        % Deep Copy of Class
        % ---------------------------------------------------------------%
        function new = Copy(this)
        % Deep Copy of the gridder parameter. The syntax is: g_new = r.Parameter.Gridder.Copy                            
        end
    end
    
   
    
end

