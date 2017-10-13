classdef MRparameterDoc
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = protected)
        Parameter2Read;     % Specifies which data is read when calling the ReadData function. Data can be read selectively by modifying the Parameter2Read struct. 
        Chunk;              % The chunk parameters used when data is reconstructed in smaller portions (chunks).
        Scan;               % The scan parameter which where set in the user interface. 
        Encoding;           % Encoding parameters such as matrix sized oversampling factors etc.     
        Recon;              % Reconstruction parameter and options
        Gridder;            % Gridder parameter.
        Cardiac;            % Cardiac Parameter
        DataFormat;         % Specifies the data format of the current MRecon object
        ReconFlags;         % The recon flags which specify which reconstruction steps have already been executed. 
		Spectro; 			% Holds a few settings specific to the processing of spectroscopy data.
    end
    
    properties
        Filename;           % The filename of the data and parameter file to be reconstructed.  
        Labels;             % The label information and parameters received by the scanner. These are the raw parameters which are then sorted into the scan, encoding, gridder etc. parameters
        ImageInformation;   % The image information. Every image of the Data matrix has its own parameter set. The Image information is written to the par/xml file when the data is exported to the REC format.
        Bruker;             % Specifies Bruker parameter (work in progress).
        LabelLookupTable;   % The label lookup table which links the label information of every profile (r.Parameter.Labels.Index) to the data which is currently stored in r.Data. With the lookup table we can obtain information about every profile in the Data matrix (e.g. profile number, dynamic scan number, random phase etc.).
        EPICorrData;        % The EPI correction factors. Please see the documentation of the <a href="matlab:helpwin('MReconDoc.EPIPhaseCorrection')">EPI phase correction</a> for more information.
    end           
    methods       
        % ---------------------------------------------------------------%
        % Public Parameter Functions
        % ---------------------------------------------------------------%
        function Reset()
            % This function resets all the parameter to their initial
            % states            
        end               
        
        % ---------------------------------------------------------------%
        % Deep copy of Parameter class
        % ---------------------------------------------------------------%
        function new = Copy(this)
            % Instantiate new object of the same class.            
        end
    end        
end

