classdef EncodingParsDoc
    %UNTITLED5 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties 
		NrFids		 = [];  % The Number of FIDs/dynamics. This is intended for spectroscopy data. Every mix has its own encoding parameter.
		NrDyn		 = [];  % The Number of dynamics. This is intended for spectroscopy data. Every mix has its own encoding parameter.
        NrMixes      = [];  % The Number of mixes in the current scan. Every mix and echo has its seperate encoding parameter.
        NrEchoes     = [];  % The Number of echoes in the current scan. Every mix and echo has its seperate encoding parameter.
        Mix          = [];  % Specifies the mix number of the encoding parameters below. Every row in the encoding paramters below corresponds to one mix or echo.
        Echo         = [];  % Specifies the echo number of the encoding parameters below. Every row in the encoding paramters below corresponds to one mix or echo.
        DataSizeByte = [];  % Specifies the the size of one acquired profile in bytes. Every mix and echo has its own value.
        KxRange      = [];  % Specifies the sampled k-space range in readout direction. If partial echo was enabled the range might be asymmetric. Please note that for data which has to be gridded (radial, spiral, EPI), the values specify the range after gridding. Every mix and echo has its own value.
        KyRange      = [];  % Specifies the sampled k-space range in phase encoding direction. If halfscan was enabled the range might be asymmetric. Please note that for data which has to be gridded (radial, spiral, EPI), the values specify the range after gridding. Every mix and echo has its own value.
        KzRange      = [];  % Specifies the sampled k-space range in slice encoding direction. If halfscan was enabled the range might be asymmetric. Please note that for data which has to be gridded (radial, spiral, EPI), the values specify the range after gridding. Every mix and echo has its own value.
        XRange       = [];  % Specifies the image-space range in readout direction just after the fourier transformation. The ranges already include k-space zero filling but no oversampling. These values also specify the image space shifts after fourier transformation. If the values are asymmetric we have to shift the images by that amount which make the ranges symmetric around 0. Every mix and echo has its own value.
        YRange       = [];  % Specifies the image-space range in phase encoding direction just after the fourier transformation. The ranges already include k-space zero filling but no oversampling. These values also specify the image space shifts after fourier transformation. If the values are asymmetric we have to shift the images by that amount which make the ranges symmetric around 0. Every mix and echo has its own value.
        ZRange       = [];  % Specifies the image-space range in slice encoding direction just after the fourier transformation. The ranges already include k-space zero filling but no oversampling. These values also specify the image space shifts after fourier transformation. If the values are asymmetric we have to shift the images by that amount which make the ranges symmetric around 0. Every mix and echo has its own value.
        XRes         = [];  % Specifies the image-space matrix size in readout direction just after the fourier transformation. The matrix sizes already include k-space zero filling but no oversampling. Every mix and echo has its own value.
        YRes         = [];  % Specifies the image-space matrix size in phase encoding direction just after the fourier transformation. The matrix sizes already include k-space zero filling but no oversampling. Every mix and echo has its own value.
        ZRes         = [];  % Specifies the image-space matrix size in slice encoding direction just after the fourier transformation. The matrix sizes already include k-space zero filling but no oversampling. Every mix and echo has its own value.
        XReconRes    = [];  % Specifies the final reconstructed size in readout direction. Every mix and echo has its own value.
        YReconRes    = [];  % Specifies the final reconstructed size in phase encoding direction. Every mix and echo has its own value.
        ZReconRes    = [];  % Specifies the final reconstructed size in slice encoding direction. Every mix and echo has its own value.
        KxOversampling = 2; % Specifies the amount of oversampling in readout direction. Every mix and echo has its own value.
        KyOversampling = 1; % Specifies the amount of oversampling in phase encoding direction. Every mix and echo has its own value.
        KzOversampling = 1; % Specifies the amount of oversampling in slice encoding direction. Every mix and echo has its own value.
        FFTShift     = [1, 1, 1];   % Enables/Disables the image space shifts in every direction. 
        FFTDims      = [1, 1, 1];   % Specifies in which directions the fourier transformation is performed.               
    end
       
    methods        
        % ---------------------------------------------------------------%
        % Reset Encoding Parameter
        % ---------------------------------------------------------------%        
        function Reset( )                    
        end
        
        % ---------------------------------------------------------------%
        % Deep Copy of Class
        % ---------------------------------------------------------------%
        function new = Copy(this)
            % Instantiate new object of the same class.          
        end               
    end        
end