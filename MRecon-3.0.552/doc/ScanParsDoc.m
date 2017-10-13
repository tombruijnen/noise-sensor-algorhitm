classdef ScanParsDoc
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Date                = []; % The date on which the scan was acquired 
        FieldStrength       = []; % The field strength of the scanner on which the scan was acquired
        ScanType            = []; % Specifies if it is an imaging or spectroscopy acquisition. 
        ScanMode            = []; % The scan mode as set in the user interface (e.g. 3D, M2D etc.)   
        AcqMode             = []; % The acquisition mode as set in the user interface (e.g. cartesian, radial etc.)               
        Technique           = []; % The scan technique as set in the user interface. It speciefies what kind of acqisition it was e.g. Gradient echo, spin echo etc.     
        FastImgMode         = []; % The fast imaging mode as set in the user interface.
        TFEfactor           = []; % The TFE factor as set in the user interface (e.g. EPI).
        EPIFactor           = []; % The EPI factor as set in the user interface. 
        ProtocolName        = []; % The protocol which is important when importing a reconstructed scan back into the scanner database. It specifies the name of the scan in the database.   
        ScanDuration        = []; % The scan duration as displayed in the user interface. 
        AcqNo               = []; % The acquisition number which is important when importing a reconstructed scan back into the scanner database. The acquisition number specifies where the imported scan will appear on the console.     
        PartialEcho         = []; % Specifies if partial echo sampling was enabled.
        HalfScanFactors     = []; % The half scan factors as set in the user interface in phase encoding directions. 
        UTE                 = []; % Specifies if ultra short TE sampling was enabled.     
        KooshBall           = []; % Specifies if kooshball radial sampling was enabled.       
        TR                  = []; % The repetition time as set in the user interface.
        TE                  = []; % The echo times as set in the user interface.
        FlipAngle           = []; % The flip angle as set in the user interface.
        FOV                 = []; % [AP FH RL]. The field-of-view (FOV) as set in the user interface.
        curFOV              = []; % [ijk]. The current FOV of the data in the ijk system including oversampling and undersampling. curFOV does change during the reconstruction process, e.g. when removing the oversampling.
        RecVoxelSize        = []; % [MPS]. The reconstructed voxel size.
        AcqVoxelSize        = []; % [MPS]. The acquired voxel size.
        SliceGap            = []; % The slice gap as set in the user interface.
        Samples             = []; % [MPS]. The acquired number of samples in all 3 directions.
        Stacks              = []; % The number of acquired stacks.
        ImagesPerStack      = []; % The number of images per stacks. The number of acuired images per stack can only be different when the scan mode was set to M2D or MS.
        Offcentre           = []; % [AP FH RL]. The image offcentre as set in the user interface given in the patient coordinate system.
        Angulation          = []; % [AP FH RL]. The image angulation as set in the user interface given in the patient coordinate system.
        MPSOffcentres       = []; % [MPS]. The MPS offcentre in pixel. The MPS offcenter corresponds to the vector from the MPS origin to the isocenter. 
        MPSOffcentresMM     = []; % [MPS]. The MPS offcentre in mm. The MPS offcenter corresponds to the vector from the MPS origin to the isocenter. 
        xyzOffcentres       = []; % [xyz]. The image offcentre in the xyz system. If the table did not move during the exam the values in the xyzOffcentre are equal to the ones in Offcentre (they might have different signs though).
        Orientation         = []; % The image orientation as set in the user interface.
        FoldOverDir         = []; % The fold over direction as set in the user interface.
        FatShiftDir         = []; % The fat shift direction as set in the user interface.
        ijk                 = []; % The ijk coordinate system, which corresponds to the system of the curret data, expressed in patient axes (R = right, L = left, A = anterior, P = posterior, F = feet, H = head). (see the <a href="matlab:open('CoordinateTransformations.pdf')">transformation manual</a> for more details)
        MPS                 = []; % The MPS coordinate system expressed in patient axes (R = right, L = left, A = anterior, P = posterior, F = feet, H = head). (see the <a href="matlab:open('CoordinateTransformations.pdf')">transformation manual</a> for more details)
        xyz                 = []; % The Scanner fixed xyz coordinate system expressed in patient axes (R = right, L = left, A = anterior, P = posterior, F = feet, H = head). (see the <a href="matlab:open('CoordinateTransformations.pdf')">transformation manual</a> for more details)
        REC                 = []; % The coordinate system if the final reconstructed image (REC data) expressed in patient axes (R = right, L = left, A = anterior, P = posterior, F = feet, H = head). (see the <a href="matlab:open('CoordinateTransformations.pdf')">transformation manual</a> for more details)
        WaterFatShiftPix    = []; % The water fat shift in pixel, as set in the user interface.
        PatientPosition     = []; % The patient position (head first or feet first)
        PatientOrientation  = []; % The patient oriantation (supine, prone, right, left)
        SENSEFactor         = []; % The SENSE factor as set in the user interface
        Kt                  = []; % Specifies if kt undersampling was enabled and in which direction (No, HeartPhases or DynamicScans).
        KtFactor            = []; % The kt factor as set in the user interface
        AngioMode           = []; % Specifies the angio mode (No, Inflow, Phase Contrast, Contrast Enhancement).
        QuantFlow           = []; % Specifies if quantitative flow was enabled.   
        Venc                = []; % The velocity encoding value in flow acquisitions.
        PCAcqType           = []; % The flow encoding scheme (Hadamard or MPS)
        SPIR                = []; % Specifies if SPIR was used as fat supression method.     
        MTC                 = []; % Specifies if magnetization transfer contrast was enabled.        
        Diffusion           = []; % Specifies if it is a diffusion scan.       
    end
    
    methods        
        function new = Copy(this)
            % Instantiate new object of the same class.           
        end
    end
end

