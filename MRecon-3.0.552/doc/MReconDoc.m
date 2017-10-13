classdef MReconDoc
    % MRecon is an extensive object-oriented Matlab library, implementing many 
    % common image and spectrum reconstruction task. The object-oriented design 
    % makes it easy to expand or alter the existing functionality. Code examples 
    % of complete reconstructions are provided. They can serve as a starting point 
    % for custom development. 
    
    properties           
        Parameter;  % Scan and reconstruction parameter                    
        Data;       % The current data                       
    end    
    
    methods
        % ---------------------------------------------------------------%
        % Constructor
        % ---------------------------------------------------------------%
        function MR = MReconDoc( Filename, Datafile )
            
        end
        
        % ---------------------------------------------------------------%
        % Perform Reconstruction
        % ---------------------------------------------------------------%
        function Perform( )
            % Perform: Performs a complete reconstruction of the selected MR data. Please see the
            % source code below for meore details.
            %
            % Syntax:     r.Perform; 
            %
            % Source: 
            %
            % ---------------------------------------------------------------%
            % Perform Reconstruction
            % ---------------------------------------------------------------%
            % function Perform( MR )
            %     switch MR.Parameter.DataFormat
            %         case{'ExportedRaw', 'Raw', 'Bruker' }
            % 
            %             %Reconstruct only standard (imaging) data
            %             MR.Parameter.Parameter2Read.typ = 1;
            %             MR.Parameter.Parameter2Read.Update;
            % 
            %             % Check if enough memory is available to reconstruct
            %             % the whole file at once. Otherwise reconstruct the
            %             % data in chunks
            %             if ispc 
            %                 [MemoryNeeded, MemoryAvailable, MaxDataSize] = MR.GetMemoryInformation;
            %                 if MemoryNeeded > MemoryAvailable
            %                     MR.Parameter.Chunk.Def = {'kx', 'ky', 'kz', 'chan' };
            %                 end
            %             end                       
            % 
            %             % Switch off for performance reasons (after recon it is
            %             % switched back to original state again)
            %             AutoUpdateStatus = MR.Parameter.Recon.AutoUpdateInfoPars;
            %             MR.Parameter.Recon.AutoUpdateInfoPars = 'no';
            % 
            %             % Define new counter
            %             counter = Counter( 'Performing Recon --> Chunk %d/%d\n');
            % 
            %             % Loop over all chunks
            %             for cur_loop = 1:MR.Parameter.Chunk.NrLoops
            % 
            %                 % Update Counter
            %                 if strcmpi( MR.Parameter.Recon.StatusMessage, 'yes')
            %                     counter.Update( {cur_loop ,MR.Parameter.Chunk.NrLoops} );
            %                 end
            % 
            %                 % Set the chunk-loop which automatically determines the
            %                 % image parameter to read for the current chunk
            %                 MR.Parameter.Chunk.CurLoop = cur_loop;
            % 
            %                 % --------------------------------------------------------
            %                 % Perform the Reconstruction for the Current Chunk (Start)
            %                 % --------------------------------------------------------
            % 
            %                 % spectro begin ----------------------------
            %                 if MR.Parameter.Labels.Spectro
            %                     MR.ReadData;
            %                     MR.PDACorrection;
            %                     MR.DcOffsetCorrection;
            %                     MR.RandomPhaseCorrection;
            %                     MR.MeasPhaseCorrection;
            %                     MR.SortData;
            %                     MR.Average;
            %                     MR.RemoveOversampling;
            %                     MR.RingingFilter;
            %                     MR.ZeroFill;
            %                     MR.SENSEUnfold;
            %                     MR.EddyCurrentCorrection;
            %                     MR.CombineCoils;
            %                     MR.GeometryCorrection;
            %                     MR.K2I;
            %                 else
            %                 % spectro end ------------------------------
            %                     MR.ReadData;
            %                     MR.RemoveOversampling;
            %                     MR.PDACorrection;
            %                     MR.DcOffsetCorrection;
            %                     MR.RandomPhaseCorrection;
            %                     MR.MeasPhaseCorrection;
            %                     MR.SortData;
            %                     MR.GridData;
            %                     MR.RingingFilter;
            %                     MR.ZeroFill;                                                                                    
            %                     MR.K2IM;
            %                     MR.EPIPhaseCorrection;
            %                     MR.K2IP;
            %                     MR.GridderNormalization;
            %                     MR.SENSEUnfold;
            %                     MR.PartialFourier;
            %                     MR.ConcomitantFieldCorrection;
            %                     MR.DivideFlowSegments;
            %                     MR.CombineCoils;
            %                     MR.Average;
            %                     MR.GeometryCorrection;
            %                     MR.RemoveOversampling;							
            %                     MR.ZeroFill;
            %                     MR.FlowPhaseCorrection;
            %                     MR.RotateImage;
            %                 end
            % 
            %                 % The current chunk is now reconstructed. If the data is
            %                 % reconstructed in more than one chunk write the result to
            %                 % a temporary file on the disk.
            %                 if MR.Parameter.Chunk.NrLoops > 1
            %                     [exported_datafile, exported_listfile] = MR.WriteExportedRaw( [MR.Parameter.Filename.Data, '_temp.data'], MR.Parameter.Parameter2Read );
            %                 end
            % 
            %                 % --------------------------------------------------------
            %                 % Perform the Reconstruction for the Current Chunk (End)
            %                 % --------------------------------------------------------
            %             end
            % 
            %             % If data has been written to a temporary file read it
            %             % again
            %             if MR.Parameter.Chunk.NrLoops > 1
            %                 r_temp = MRecon(exported_datafile);
            %                 r_temp.ReadData;
            %                 r_temp.SortData;
            %                 MR.Data = r_temp.Data;
            %                 fclose all;
            %                 delete(exported_datafile);
            %                 delete(exported_listfile);
            %                 clear r_temp;
            %             end
            %             if strcmpi( MR.Parameter.Recon.StatusMessage, 'yes')
            %                 fprintf('\n');
            %             end
            %             MR.Parameter.Recon.AutoUpdateInfoPars = AutoUpdateStatus;
            %             MR.Parameter.Reset;
            %          case 'ExportedCpx'
            %             MR.ReadData;
            %             MR.SortData;
            %             MR.CombineCoils;
            %         case 'Cpx'
            %             MR.ReadData;
            %             MR.CombineCoils;
            %         case 'Rec'
            %             MR.ReadData;
            %             MR.RescaleREC;
            %             MR.CreateComplexREC;
            %         otherwise
            %             error( 'Error in Perform: Unknown data format' );
            %     end
            % end
        end
        
        % ---------------------------------------------------------------%
        % Data Reading
        % ---------------------------------------------------------------%
        function ReadData( )
            % ReadData: Reads all supported data formats into Matlab. 
            %
            % Syntax:     r.ReadData;            
            %           
            % Parameters used: 
            %
            %           All formats:
            %           - <a href="matlab:helpwin('MRparameterDoc.DataFormat')">Parameter.DataFormat</a>:
            %             Used to check which data format is passed to the reader 
            %           - <a href="matlab:helpwin('Parameter2ReadParsDoc')">Parameter.Parameter2Read</a>:
            %             Specifies what data is read from the file.
            %           - <a href="matlab:helpwin('MRparameterDoc.Filename')">Parameter.Filename.ijk</a>:
            %             The filename of the data and parameter file to be read. 
            %           - <a href="matlab:helpwin('MRparameterDoc.Labels')">Parameter.Labels</a>:
            %             The data labels which hold the image attributes for every profile. 
            %
            %           Raw and ExportedRaw data
            %           - <a href="matlab:helpwin('EncodingParsDoc.KxRange')">Parameter.Encoding.KxRange</a>:
            %             The sampled k-space range in readout direction used to place the data
            %             correctly in k-space (e.g. in partial echo acquisitions). Please note that
            %             for data which has to be gridded (e.g. radial, spiral, EPI data), this
            %             parameter specifies the k-space range after gridding.
            %           - <a href="matlab:helpwin('ReconParsDoc.ArrayCompression')">Parameter.Recon.ArrayCompression</a>:
            %             Enables the array compression, according to: Buehrer, M., Pruessmann, K. P.
            %             , Boesiger, P. and Kozerke, S. (2007), Array compression for MRI with large 
            %               coil arrays. Magnetic Resonance in Medicine, 57: 1131–1139.
            %             The individual profiles are compressed to the userd defined number of
            %             virtual coils immediately after reading. 
            %           - <a href="matlab:helpwin('ReconParsDoc.ACNrVirtualChannels')">Parameter.Recon.ACNrVirtualChannels</a>:
            %             The number of virtual coils used in array compression. 
            %           - <a href="matlab:helpwin('ReconParsDoc.ACMatrix')">Parameter.Recon.ACMatrix</a>:
            %             The compression matrix used in array compression. 
            %
            % Recon Flag: <a href="matlab:helpwin('ReconFlagParsDoc.isread')">Parameter.ReconFlags.isread</a>
            %
            % Location:   Beginning of recon
            %
            % Formats:    Raw | ExportedRaw | Cpx | Rec | Bruker
            %
            % Description/Algorithm: The ReadData function reads the MR data from the selected file
            %             and stores it into Matlab. The function supports selective reading,
            %             meaning that the user can specify what data should be read via
            %             r.Parameter.Parameter2Read. After calling the ReadData function, the data
            %             is stored in the order it was saved in the data file. This means that for
            %             raw data we obtain a matrix containing the individual k-space profiles in
            %             the order they have been measured. For Rec and Cpx data however we obtain
            %             (partly) reconstructed images in image-space.             
            %             Generally the data is stored in a cell array where the different rows hold
            %             different data types (e.g. imaging data, correction data, noise data etc)
            %             and the columns different data sizes (e.g. kt-undersampled and training
            %             data). The number of rows in the cell array is predefined while the number
            %             of columns varies depending on the data in the file. Generally the cell
            %             array has the following form:
            %
            %                                               Data size 1     Data size 2
            %
            %               1. Accepted imaging data        { STD },        { STD }
            %               2. Rejected imaging data        { REJ },        { REJ }
            %               3. Phase correction data        { PHX },        { PHX }
            %               4. Frequency correction data    { FRX },        { FRX }            
            %               5. Noise data                   { NOI },        { NOI }
            %
            %             I a data type does not occur in the file the the selected cell element is
            %             left empty. If only one data type and size is read (cell array with one
            %             element) then a ordinary Matrix is returned instead of a cell. 
            %
            % Examples:   Read only imaging data from the first coil and the third dynamic:            
            %             
            %               r = MRecon( 'rawfile.raw' );
            %               r.Parameter.Parameter2Read.typ  = 1;   % Imaging data
            %               r.Parameter.Parameter2Read.chan = 0;   % First coil
            %               r.Parameter.Parameter2Read.dyn  = 2;   % Third dynamic
            %               r.ReadData;
            %
            %             Read the noise samples from a raw file:
            %               r = MRecon( 'rawfile.raw' );
            %               r.Parameter.Parameter2Read.typ  = 5;   % Noise data            
            %               r.ReadData;            
        end
        
        % ---------------------------------------------------------------%
        % Data Writing
        % ---------------------------------------------------------------%
        function [datafile, listfile] = WriteExportedRaw( Filename, Parameter2Write )
            % WriteExportedRaw: Exports the data to Philips exported raw format.
            %
            % Syntax:     [datafile, listfile] = r.WriteExportedRaw( Filename, Parameter2Write );           
            %           
            % Parameters used:             
            %
            % Location:   k-space | image-space.
            %
            % Formats:    Raw | ExportedRaw
            %
            % Description/Algorithm: Exports the images in the data array to Philips exported format
            %             (data/list file pair). The Parameter2Write which have to be given as input
            %             is usually the current Parameter2Read struct (r.Parameter.Parameter2Read).                         
        end
        function WriteRec( Filename )
            % WriteRec: Exports the data to Philips rec format.
            %
            % Syntax:     r.WriteRec( filename );            
            %           
            % Parameters used: 
            %           - <a href="matlab:helpwin('ReconParsDoc.ExportRECImgTypes')">Parameter.Recon.ExportRECImgTypes</a>: {'M', 'P', 'R', 'I'}
            %             Specifies the images which should be exported (Magnitude, Phase, Real
            %             part, Imagenary part).
            %           - <a href="matlab:helpwin('InfoParsDoc.RescaleIntercept')">Parameter.ImageInformation.RescaleIntercept</a>, <a href="matlab:helpwin('InfoParsDoc.RescaleSlope')">Parameter.ImageInformation.RescaleSlope</a>:
            %             Defines the scaling of the images in the rec file. If these values are
            %             empty (default) then the scaling is calculated automatically in the
            %             WriteRec function. For details see below. 
            %
            % Location:   image-space.
            %
            % Formats:    Raw | ExportedRaw | Cpx | Rec 
            %
            % Description/Algorithm: Exports the images in the data array to Philips rec format.
            %             During the export the data is rescaled according to:
            %
            %             Magnitude data, Real part, Imagenary part:          
            %                Value_in_Rec File = round( (Value_in_r.Data - RescaleIntercept) / RescaleSlope )
            %
            %             Phase data:          
            %                Value_in_Rec_File = round( (1000 * Phase_in_r.Data - RescaleIntercept) / RescaleSlope )
            %                                                      
            % Notes:    - When the exported rec data is reimported into the scanner database the
            %             values are rescaled such that they correspond the the original values
            %             in r.Data before exporting.
        end
        function WritePar( Filename )
            % WritePar: Exports the parameter to a Philips par file.
            %
            % Syntax:     r.WritePar( filename );            
            %           
            % Parameters used: 
            %           - <a href="matlab:helpwin('ScanParsDoc')">Parameter.Scan</a>:
            %             Holds the general parameters (uper part of the par file)
            %           - <a href="matlab:helpwin('InfoParsDoc')">Parameter.ImageInformation</a>:
            %             Holds the individual parameters for every image (lower part of the par
            %             file).
            %
            % Location:   image-space.
            %
            % Formats:    Raw | ExportedRaw | Cpx | Rec 
            %
            % Description/Algorithm: Exports the parameters in to a Philips par file.            
        end
        function WriteXMLPar( Filename )
            % WriteXMLPar: Exports the parameter to a Philips XML par file.
            %
            % Syntax:     r.WriteXMLPar( filename );            
            %           
            % Parameters used: 
            %           - <a href="matlab:helpwin('ScanParsDoc')">Parameter.Scan</a>:
            %             Holds the general parameters (upper part of the par file)
            %           - <a href="matlab:helpwin('InfoParsDoc')">Parameter.ImageInformation</a>:
            %             Holds the individual parameters for every image (lower part of the par
            %             file).
            %
            % Location:   image-space.
            %
            % Formats:    Raw | ExportedRaw | Cpx | Rec 
            %
            % Description/Algorithm: Exports the parameters in to a Philips XML par file.     
        end        

		% spectro begin ----------------------------
		function WriteSdat( Filename )
			% WriteSdat: Exports the spectroscopy data to a Philips binary SDAT file and a corresponding
			% 			 SPAR text file containing scan parameter informations.
			%
			% Syntax:    r.WriteSdat; or r.WriteSdat( filename );
			%
			% Parameters used:
			% 			 - <a href="matlab:helpwin('ScanParsDoc')">Parameter.Scan</a>:
			% 			   Holds all parameters that will be written to the SPAR file.
			%
			% Location:  k-space.
			%
			% Formats:   Raw (Spectro)
			%
			% Description/Algorithm:
			% 			 Exports the spectroscopy data to a Philips binary SDAT file and a corresponding
			% 			 SPAR text file containing scan parameter informations. If no filename is provided 
			% 			 the same name and location of the raw file is used for export. For unsuppressed water 
			% 			 scans that may be included in the raw data the extension '_ref' will be added to the 
			% 			 filename and a separate pair of SDAT/SPAR files will be saved to the same location. 
			% 			 The individual measurements of a spectroscopy experiment need to be averaged to 1 final 
			% 			 FID. If dynamics are present or CSI data, the individual FIDs/dynamic or FIDs/CSI voxel 
			% 			 are organized in a 2 dimensional data matrix. The binary data is stored as interleaved 
			% 			 real and imaginary values in VAX floating point format.
		end
		% spectro end ------------------------------

        function ExportLabels( Filename )
            % ExportLabels: Exports the imaging labels, which are stored in the .lab file to a
            % textfile
            %
            % Syntax:     r.ExportLabels( filename );            
            %           
            % Parameters used: 
            %           - <a href="matlab:helpwin('MRparameterDoc.Labels.Index')">Parameter.Labels.Index</a>:
            %             The labels to be exported.            
            %
            % Location:   k-space, image-space.
            %
            % Formats:    Raw | ExportedRaw | Bruker
            %
            % Description/Algorithm: This function exports the imaging labels, which were sent from
            %             the spectrometer to the reconstructor, to a textfile. Every row in the
            %             file corresponds to an measured k-space line in the order they have been
            %             acquired. Exporting the labels is useful to get an overview over the
            %             sampling order for example. 
            %                                   
            % Notes:    - The format of the textfile is virtually identical to the one of the .list
            %             file of the exported raw data format.             
        end
        
        % ---------------------------------------------------------------%
        % Data Sorting
        % ---------------------------------------------------------------%
        function SortData( )
            % SortData: Sorts the acquired profiles by their image attributes and generates proper
            % k-space data.
            %
            % Syntax:     r.SortData;            
            %           
            % Parameters used: 
            %
            %           All formats:
            %           - <a href="matlab:helpwin('ReconParsDoc.ImmediateAveraging')">Parameter.Recon.ImmediateAveraging</a>:
            %             When enabled the averages are added immediately during SortData. If you
            %             want to reconstruct the individual averages seperately then disable this
            %             parameter.
            %            - <a href="matlab:helpwin('MRparameterDoc.Labels')">Parameter.Labels</a>:
            %             The data labels which hold the image attributes for every profile. 
            %           - <a href="matlab:helpwin('MRparameterDoc.LabelLookupTable')">Parameter.LabelLookupTable</a>: 
            %             Links the profiles which are currently stored in the Data array with the
            %             data lables.
            %           - <a href="matlab:helpwin('EncodingParsDoc.KyRange')">Parameter.Encoding.KyRange</a>,  <a href="matlab:helpwin('EncodingParsDoc.KzRange')">Parameter.Encoding.KzRange</a>:
            %             The sampled k-space ranges in phase encoding directions used to place the
            %             data correctly in k-space (e.g. in halfscan acquisitions).
            %           - <a href="matlab:helpwin('EncodingParsDoc.KyOversampling')">Parameter.Encoding.KyOversampling</a>,  <a href="matlab:helpwin('EncodingParsDoc.KyOversampling')">Parameter.Encoding.KyOversampling</a>:
            %             The oversampling factors in phase encoding directions used to place the
            %             data correctly in k-space.            
            %
            % Recon Flag: <a href="matlab:helpwin('ReconFlagParsDoc.issorted')">Parameter.ReconFlags.issorted</a>
            %
            % Location:   After ReadData
            %
            % Formats:    Raw | ExportedRaw | ExportedCpx
            %
            % Description/Algorithm: After reading the data into Matlab with ReadData, the acquired
            %             profiles are stored in temporal order (in the order they have been
            %             measured). The SortData function sorts the profiles by their image
            %             attributes phase encoding number, cardiac phase, dynamic scan number etc.
            %             After the sorting the data the data array holds proper k-space data which
            %             can be fourier transformed to generate images. Please note that averages
            %             are summed up immediately during sorting if immediate averaging is enabled
            %             (see above). 
            %
            %             After SortData the data array has a predifined form with 12 dimensions,
            %             where every array dimension corresponds to an image attribute:
            %
            %             r.Data = [kx, ky, kz, coils, dynamics, cadiac phases, echoes, locations, 
            %                       mixes, extra1, extra2, averages ]                                
        end
        
        % ---------------------------------------------------------------%
        % Corrections
        % ---------------------------------------------------------------%
        function RandomPhaseCorrection( )
            % RandomPhaseCorrection: Corrects for the random phase which is added to the measured
            % profiles
            %
            % Syntax:     r.RandomPhaseCorrection;            
            %           
            % Parameters used: 
            %           - <a href="matlab:helpwin('ReconParsDoc.RandomPhaseCorrection')">Parameter.Recon.RandomPhaseCorrection</a>: {'yes'} | 'no'
            %             Enables/disables the random phase correction. 
            %           - <a href="matlab:helpwin('MRparameterDoc.DataFormat')">Parameter.DataFormat</a>:
            %             Used to check if raw data is passed to the function 
            %           - <a href="matlab:helpwin('MRparameterDoc.LabelLookupTable')">Parameter.LabelLookupTable</a>: 
            %             Defines the profiles which are currently stored in the Data array.
            %           - <a href="matlab:helpwin('MRparameterDoc.Labels')">Parameter.Labels.Index.random_phase</a>: 
            %             Holds the random phases which are subtracted from the profiles.
            %
            % Recon Flag: <a href="matlab:helpwin('ReconFlagParsDoc.israndphasecorr')">Parameter.ReconFlags.israndphasecorr</a>
            %
            % Location:   k-space
            %
            % Formats:    Raw
            %
            % Description/Algorithm: The receiver adds a random phase to every acquired profile to
            %             reduce artifacts. This random phase has to be subtracted in
            %             reconstruction since the phase is used for spatial encoding. The added
            %             phase is stored in the profile labels and the phase which is subtraced is
            %             given by: 
            %             
            %             Let ri be the random phase label of the i-th profile:                
            %
            %                 ri = Parameter.Labels.Index.meas_phase(i); 
            %
            %             then the phase subtracted to that profile is given by: 
            %
            %                 phase = 2*pi / double( intmax('uint16') ) * ri;       
        end
        function MeasPhaseCorrection( )
            % MeasPhaseCorrection: Corrects for an offset phase which might have been added to
            % certain profiles
            %
            % Syntax:     r.DcOffsetCorrection;            
            %           
            % Parameters used: 
            %           - <a href="matlab:helpwin('ReconParsDoc.MeasPhaseCorrection')">Parameter.Recon.MeasPhaseCorrection</a>: {'yes'} | 'no'
            %             Enables/disables the measurement phase correction. 
            %           - <a href="matlab:helpwin('MRparameterDoc.DataFormat')">Parameter.DataFormat</a>:
            %             Used to check if raw data is passed to the function 
            %           - <a href="matlab:helpwin('MRparameterDoc.LabelLookupTable')">Parameter.LabelLookupTable</a>: 
            %             Defines the profiles which are currently stored in the Data array.
            %           - <a href="matlab:helpwin('MRparameterDoc.Labels')">Parameter.Labels.Index.meas_phase</a>: 
            %             Holds the measurement phases.
            %
            % Recon Flag: <a href="matlab:helpwin('ReconFlagParsDoc.isdcoffsetcorr')">Parameter.ReconFlags.isdcoffsetcorr</a>
            %
            % Location:   k-space
            %
            % Formats:    Raw
            %
            % Description/Algorithm: Different profiles can sometimes exhibit a phase shift, which
            %             originates from either the RF pulse phase or the acquistion phase
            %             specified in the AQ object. Different averages for example are usually
            %             acquired with a phase difference of pi between them. If we wouldn't
            %             correct for this phase then the signal would effectively cancel out when
            %             summing up the averages. MeasPhaseCorrection therefore corrects for this
            %             possible phase shift using the values in the labels, received by the
            %             scanner.
            %             Let mi be the measurement of the i-th profile: 
            %
            %                 mi = Parameter.Labels.Index.meas_phase(i); 
            %
            %             then the phase added to that profile is given by: 
            %
            %                 phase = -mi * pi/2                                                                       
        end
        function DcOffsetCorrection( )
            % DcOffsetCorrection: Corrects for a signal offset that might occur in the acquired
            % samples.
            %
            % Syntax:     r.DcOffsetCorrection;            
            %           
            % Parameters used: 
            %           - <a href="matlab:helpwin('ReconParsDoc.DcOffsetCorrection')">Parameter.Recon.DcOffsetCorrection</a>: {'yes'} | 'no'
            %             Enables/disables the DC-offset correction. 
            %           - <a href="matlab:helpwin('MRparameterDoc.DataFormat')">Parameter.DataFormat</a>:
            %             Used to check if raw data is passed to the function 
            %           - <a href="matlab:helpwin('MRparameterDoc.LabelLookupTable')">Parameter.LabelLookupTable</a>: 
            %             Defines the profiles which are currently stored in the Data array.
            %           - <a href="matlab:helpwin('EncodingPars.KxRange')">Parameter.Encoding.KxRange</a>: 
            %             If no noise samples are present in the raw file, this parameter specifies
            %             where the outer k-space (noise like) samples are located.
            %
            % Recon Flag: <a href="matlab:helpwin('ReconFlagParsDoc.isdcoffsetcorr')">Parameter.ReconFlags.isdcoffsetcorr</a>
            %
            % Location:   k-space (before the partial fourier reconstruction)
            %
            % Formats:    Raw
            %
            % Description/Algorithm: Acquired raw samples can sometimes exhibit a signal offset
            %             originating from hardware inacuracies of the receiver. If not corrected
            %             this offset can cause a artifact which will appear as bright signal peak
            %             in the middle of the image. Since noise in the MR signal is normally
            %             distributed with a mean of zero, the offset can be calculated by
            %             calculating the mean of the noise samples. Therefore if the raw data
            %             contains noise samples (from a noise acquisition prior to the scan), these
            %             samples are read and the mean is calculated. If the data does not contain
            %             any noise, the offset is calculated from the noise like outer k-space
            %             positions. After calculating the offset it is subtracted from the data. 
            %                                   
            % Notes:    - The offset is calculated seperately for every channel.             
        end
        function PDACorrection( )
            % PDACorrection: Corrects the profile dependent amplification (PDA)
            %
            % Syntax:     r.PDACorrection;            
            %           
            % Parameters used: 
            %           - <a href="matlab:helpwin('ReconParsDoc.PDACorrection')">Parameter.Recon.PDACorrection</a>: {'yes'} | 'no'
            %             Enables/disables the PDA correction. 
            %           - <a href="matlab:helpwin('MRparameterDoc.DataFormat')">Parameter.DataFormat</a>:
            %             Used to check if raw data is passed to the function 
            %           - <a href="matlab:helpwin('MRparameterDoc.LabelLookupTable')">Parameter.LabelLookupTable</a>: 
            %             Defines the profiles which are currently stored in the Data array.
            %           - <a href="matlab:helpwin('MRparameterDoc.Labels')">MR.Parameter.Labels.PDAFactors</a>: 
            %             Holds the PDA correction factors.
            %           - <a href="matlab:helpwin('MRparameterDoc.Labels')">MR.Parameter.Labels.Index.pda_index</a>: 
            %             Specifies which correction factor should be taken for a certain profile. 
            %
            % Recon Flag: <a href="matlab:helpwin('ReconFlagParsDoc.ispdacorr')">Parameter.ReconFlags.ispdacorr</a>
            %
            % Location:   k-space
            %
            % Formats:    Raw
            %
            % Description/Algorithm: In some cases the receiver weights certain k-space profiles
            %             differently than others. In 3D imaging for example the outer k-space lines
            %             are amplified compared to the central ones, to ensure a sufficiant signal
            %             range. Of course the amplifacation has to be corrected in
            %             reconstruction, if not the edges in the image would be enhanced. The
            %             amplification factors are provided by the scanner and this function simply
            %             divides the profiles by them. 
        end
        function EPIPhaseCorrection( )
            % EPIPhaseCorrection: Performes the EPI correction to correct for the FOV/2 ghost
            % originating from eddy current effects.
            %
            % Syntax:     r.EPIPhaseCorrection;            
            %           
            % Parameters used: 
            %           - <a href="matlab:helpwin('ReconParsDoc.EPIPhaseCorrection')">Parameter.Recon.EPIPhaseCorrection</a>: {'yes'} | 'no'
            %             Enables/disables the EPI correction. 
            %           - <a href="matlab:helpwin('MRparameterDoc.DataFormat')">Parameter.DataFormat</a>:
            %             Used to check if the right data format is passed to the function             
            %           - <a href="matlab:helpwin('MRparameterDoc.EPICorrData')">Parameter.EPICorrData</a>:
            %             The linear/nonlinear phase used in the EPI correction. If a linear
            %             correction is used (default) then the phase is described by a slope and
            %             offset value. For the nonlinear phase correction the full correction
            %             profile is given. If this parameter is empty these values are calculated
            %             in the function itself. The parameter can also be filled with user defined
            %             slopes and offsets prior to the correction. Please see the example below
            %             on how to do that.
            %           - <a href="matlab:helpwin('ReconFlagParsDoc.iszerofilled')">Parameter.ReconFlags.iszerofilled</a>, <a href="matlab:helpwin('ReconFlagParsDoc.isoversampled')">Parameter.ReconFlags.isoversampled</a> and <a href="matlab:helpwin('ReconFlagParsDoc.isgridded')">Parameter.ReconFlags.isgridded</a>:
            %             Used to check in what reconstruction state the data currently is. The
            %             correction profiles have to be brought into the same state to match the
            %             imaging data.
            %           - <a href="matlab:helpwin('ReconParsDoc.Recon.EPICorrectionMethod')">Parameter.Recon.EPICorrectionMethod</a>: {linear} | nonlin
            %             Enables/disables the non-linear EPI correction (see below).
            %           - <a href="matlab:helpwin('ReconParsDoc.Recon.EPI2DCorr')">Parameter.Recon.EPI2DCorr</a>: yes | {no}
            %             Enables/disables the image based EPI correction (see below).
            %           - <a href="matlab:helpwin('EncodingPars')">Encoding Parameter</a>:
            %             Used to read and format the correction profiles approprately. 
            %
            % Recon Flag: <a href="matlab:helpwin('ReconFlagParsDoc.isdepicorr')">Parameter.ReconFlags.isdepicorr</a>
            %
            % Location:   Between FFT in readout and phase encoding direction.
            %
            % Formats:    Raw | ExportedRaw | Bruker
            %
            % Description/Algorithm: In EPI imaging multiple k-space lines are acquired after a
            %             single excitation of the imaging volume. This is achieved by inverting the
            %             readout gradient after every acquired profile and thus sampling the
            %             k-space in a forward-backward fashion. Due to eddy current effects
            %             however, the positiv readout gradients (forward sampling) is not exactly
            %             the same as the negativ gradient (backward sampling), which results in a
            %             temporal shift between the forward and backward sampled profiles. After
            %             fourier transformation this shift results in a ghost like artifact located
            %             at half of the FOV.
            %             
            %             To correct for this effect EPI correction profiles are acquired prior to
            %             every scan. The correction profiles consist of a full EPI shot, but
            %             acquired without phase encoding blips, therefore sampling the central
            %             k-space line multiple times. Since these profiles should be identical
            %             (apart from relaxation effects), the temporal shift, caused by eddy current
            %             effects of the readout gradients, can be calculated. A temporal shift in
            %             k-space corresponds to a linear phase in image space. Therefore the
            %             correction profiles are first transfered into image space and the phase
            %             difference between two subsequent profiles is calculated. The phase
            %             difference is then linearly fitted and the linear phase is added to every
            %             odd (or even) profile, thus realigning them in k-space. 
            %
            %             Optionally a nonlinear correction can be enabled via <a href="matlab:helpwin('ReconParsDoc.Recon.EPICorrectionMethod')">Parameter.Recon.EPICorrectionMethod</a>.
            %             In the nonlinear correction the calculated linear phase is subtracted from
            %             the original phase difference. The remaining part is then smoothed and
            %             added to the linear phase. 
            %
            %             Optionally an image based correction can be enabled via <a href="matlab:helpwin('ReconParsDoc.Recon.EPI2DCorr')">Parameter.Recon.EPI2DCorr</a>.
            %             This correction tries to improve the images further by minimizing the
            %             amount of ghosts in the image. Thereby the offsets found by the regular
            %             EPI crrection are slighly modified and the amount of ghosts in the
            %             resulting images is quantified, to find the optimal correction value.
            %
            % Notes:    - Every coil has its own EPI correction parameters.  
            %           - The x-axis for the linear fit is given by: 
            %                  x = -floor(n/2):ceil(n/2)-1;
            %             where n is the number of samples in the correction profiles. 
            %           - The linear fit is weighted by the magnitude of the correction profiles
            %             (points with a high magnitude value are weighted higher in the fit)
            %           - The EPI correction profiles are labeled as data type 3 and can be read by
            %             setting: r.Parameter.Parameter2Read.typ = 3, followed by r.ReadData. 
            %
            % Examples:   The user has the possibility to specify own correction parameters and pass
            %             them to the function. To do that <a href="matlab:helpwin('MRparameterDoc.EPICorrData')">Parameter.EPICorrData</a> must be filled:
            %
            %             Every coil has its own slope and offset. To identify the coil we must
            %             label them in the correction parameter: 
            %
            %                  r.Parameter.EPICorrData.coil = r.Parameter.Parameter2Read.chan;
            %           
            %             Assign the same slope for all the coils:
            %
            %                  r.Parameter.EPICorrData.slope = 0.1;
            %
            %             Assign a different offset for every coil (4 coils in this example):
            %                  
            %                  r.Parameter.EPICorrData.offset = [0, 0.2, 0.4, 0.6];
            %
            %             Call the EPI correction:
            %
            %                  r.EPIPhaseCorrection;
        end
        function RingingFilter( )
            % RingingFilter: Removes ringing artifacts by applying a hamming filter on the k-space
            % data
            %
            % Syntax:     r.RingingFilter;            
            %           
            % Parameters used: 
            %           - <a href="matlab:helpwin('ReconParsDoc.RingingFilter')">Parameter.Recon.RingingFilter</a>: {'yes'} | 'no'
            %             Enables/disables the ringing filter. 
            %           - <a href="matlab:helpwin('ReconParsDoc.RingingFilterStrength')">Parameter.Recon.RingingFilterStrength</a>:
            %             A value between 0 and 1 which specifies the strength of the ringing
            %             filter. 0 means no filter is applied and 1 is the maximum filter strength.
            %             The filter strength can be specified in every direction (Measurement,
            %             Phase Encoding, Slice Encoding).
            %
            % Location:   k-space
            %
            % Formats:    Raw | ExportedRaw
            %
            % Description/Algorithm: Sharp edges in k-space can result in ringing artifacts in
            %             image-space. Such edges are introduced by zero-filling or by sampling a
            %             low resultion image. The ringing filter tries the soften the edges by
            %             applying a hamming filter on the k-space data, lowering the values on the
            %             edge. The amount by which the edge-values are lowered is specified by the
            %             filter strength. A filter strength of 0.5 for example will bring down the
            %             edge value by 50%. A strength of brings the value down to 0 and therefore
            %             removing the edges completely. However a large filter strength might cause
            %             image blurring. Therefore it is important to find an optimal compromise
            %             between artifact removal and image blurring. The default filter strength
            %             is set to 0.25.
            %
            % Notes:      The ringing filter should be applied before k-space zero filling to work
            %             effectively.
        end    
        function ConcomitantFieldCorrection( )
            % ConcomitantFieldCorrection: Performes a concomitant field correction on the current data.            
            %
            % Syntax:     r.ConcomitantFieldCorrection;            
            %           
            % Parameters used: 
            %           - <a href="matlab:helpwin('ReconParsDoc.ConcomitantFieldCorrection')">Parameter.Recon.ConcomitantFieldCorrection</a>: {'yes'} | 'no'
            %             Enables/disables the concomitant field correction. 
            %           - <a href="matlab:helpwin('MRparameterDoc.Labels')">Parameter.Labels.ConcomFactors</a>: holds the correction factors. 
            %           - Geometry parameters: The correction has to be performed in the scanner fixed 
            %             xyz-coordinate-system. Therefore all necessary geometry parameters for the
            %             coordinate transformation (Transform function) have to be available.
            %
            % Recon Flag: <a href="matlab:helpwin('ReconFlagParsDoc.isconcomcorrected')">Parameter.ReconFlags.isconcomcorrected</a>
            %
            % Location:   Image-space.
            %
            % Formats:    Raw
            %
            % Description/Algorithm: Maxwell’s equations imply that imaging gradients are accompanied by
            %             higher order spatially varying fields (concomitant fields) that can cause
            %             artifacts in MR imaging. The lowest order concomitant fields depend
            %             quadratically on the imaging gradient amplitude and inversely on the
            %             static field strength. 
            %             On the scanner these extra magnetic fields are expressed along the
            %             directions of the physical gradients (scanner fixed xyz-coordinate system).
            %             Therefore the images have to be transformed into that system before the
            %             correction. The correction itself adds a quadratic phase to the images
            %             defined by the correction parameters.
            %                                   
            % Notes:    - The concomitant field correction will not work on data measured without the 
            %             ReconFrame patch   
            %           - The concomitant field correction is only executed for phase contrast flow scans. 
            %             Only then correction parameters are provided by the scanner. 
        end
        function GeometryCorrection( )
            % GeometryCorrection: Corrects for gradient non-linearities over large FOV's             
            %
            % Syntax:     r.GeometryCorrection;            
            %           
            % Parameters used: 
            %           - <a href="matlab:helpwin('ReconParsDoc.GeometryCorrection')">Parameter.Recon.GeometryCorrection</a>: {'yes'} | 'no'
            %             Enables/disables the geometry correction. 
            %           - <a href="matlab:helpwin('MRparameterDoc.Labels')">Parameter.Labels.GeoCorrPars</a>: 
            %             Holds the correction factors. 
            %           - Geometry parameters: The correction has to be performed in the scanner fixed 
            %             xyz-coordinate-system. Therefore all necessary geometry parameters for the
            %             coordinate transformation (Transform function) have to be available.
            %
            % Recon Flag: <a href="matlab:helpwin('ReconFlagParsDoc.isgeocorrected')">Parameter.ReconFlags.isgeocorrected</a>
            %
            % Location:   Image-space.
            %
            % Formats:    Raw
            %
            % Description/Algorithm: Imaging gradients are not perfectly linear over the whole
            %             possible FOV. The further away we are from the isocentre the stronger the
            %             non-linear effects become, which will result in a slight distortion of the
            %             resulting image. This effect is corrected with the correction parameters
            %             provided by the scanner.
            %                                   
            % Notes:    - The correction parameters are scanner specific and vary with the gradient
            %             system.            
        end        
        
        % ---------------------------------------------------------------%
        % Data Gridding
        % ---------------------------------------------------------------%
        function GridData
            % GridData: Grids k-space data on a predefined trajectory.        
            %
            % Syntax:     r.GridData;            
            %           
            % Parameters used: 
            %           - <a href="matlab:helpwin('ReconParsDoc.Gridding')">Parameter.Recon.Gridding</a>: {'yes'} | 'no'
            %             Enables/disables the gridding. 
            %           - <a href="matlab:helpwin('GridderParsDoc')">Parameter.Gridder</a>: 
            %             The gridder parameter.  
            %           - <a href="matlab:helpwin('MRparameterDoc.Labels')">Parameter.Labels.NusEncNrs</a>: 
            %             The non-uniform sample position for EPI scans. In EPI acquisitions the
            %             samples in readout direction are not uniformly spread due to the sampling
            %             during gradient ramp up. Therefore EPI scans are usually gridded in
            %             readout direction using the k-space positions specified here. 
            %                  
            % Recon Flag: <a href="matlab:helpwin('ReconFlagParsDoc.isgridded')">Parameter.ReconFlags.isgridded</a>
            %
            % Location:   k-space after SortData.
            %
            % Formats:    Raw | ExportedRaw
            %
            % Description/Algorithm: The fast fourier transform (FFT) requires the data to be on a
            %             regular cartesian grid. Therefore in order to use the FFT on non-cartesian
            %             data such as radial or spiral acquistions, we have to grid the k-space
            %             data from the nominal trajectory to a cartesian grid. There are several
            %             predefined trajectories already built-in into MRecon, including:
            %             2D-radial, 3D-stack of radials, 3D-kooshball, 2D/3D spiral, EPI ramp
            %             sampling. On the other side, user defined trajectories can easily be
            %             defined by setting the <a href="matlab:helpwin('GridderParsDoc')">Gridder Parameters</a>. Please see the example below 
            %             on how to to that.
            %             If the <a href="matlab:helpwin('GridderParsDoc')">Gridder Parameters</a> are not set manually MRecon automatically detects 
            %             the type of the scan and decides if it should be gridded or not. 
            %                                   
            % Notes:    - For non-cartesian scans the zero-filling process in k-space and
            %             oversampling removal is automatically performed during gridding, by
            %             chosing the grid appropriately. See example 3)
            %           - The Gridder parameter can also be filled using the
            %             <a href="matlab:helpwin('MRecon.GridderCalculateTrajectory')">GridderCalculateTrajectory</a> function.
            %
            % Examples:   1) Reconstruct a golden angle radial acquisition by changing the radial
            %                angles in the gridder parameters:
            %
            %                Golden angle scans exhibit a radial angle increment of 111.246°, while
            %                the rest is exactly the same as a "normal" radial trajectory. Therefore
            %                all we have to do to reconstruct a golden angle scan is to change the
            %                radial angles in the gridder parameter: 
            %                
            %                Create a new reconstruction object with a golden angle scan:
            %
            %                   r = MRecon('golden_angle_scan.raw');
            % 
            %                Calculate the total number of phase encoding profiles: 
            %
            %                   nr_profs = r.Parameter.Scan.Samples(2)*r.Parameter.Scan.Samples(3)
            %
            %                Set the radial angles to an increment of 111.246°
            %
            %                   r.Parameter.Gridder.RadialAngles = 0:pi/180*111.246:(nr_profs-1)*pi/180*111.246;
            %
            %                Perform the recon
            %
            %                   r.Perform;
            % 
            %             2) Define a completely new trajectory and weights. 
            %
            %                In this example we mirror the final image in readout direction by
            %                gridding a cartesian scan to a inverted kx trajectory. To do that we
            %                define a completely new trajectory and pass it to the gridder
            %                parameters:
            %
            %                Create a new reconstruction object using a cartesian scan:
            %
            %                   r = MRecon('cartesian.raw');
            %
            %                Obtain the number of samples in every direction:
            %
            %                   no_kx_samples = r.Parameter.Scan.Samples(1);
            %                   no_ky_samples = r.Parameter.Scan.Samples(2);
            %                   no_kz_samples = r.Parameter.Scan.Samples(3);
            %
            %                Create a regular cartesian grid. These are the sampled k-space
            %                coordinates of a cartesian scan. By definition the k-space coordinates
            %                of a sampled trajectory are in the range of -floor(n/2):ceil(n/2)-1,
            %                where n is the number of samples:
            %
            %                   [kx,ky,kz] = ndgrid( -floor(no_kx_samples / 2):ceil( no_kx_samples /2)-1, ...
            %                       -floor(no_ky_samples / 2):ceil( no_ky_samples /2)-1, ...
            %                       -floor(no_kz_samples / 2):ceil( no_kz_samples /2)-1 );
            %
            %                Modify the k-space grid by inverting the readout direction:
            %
            %                   kx_inverted = -kx;
            %
            %                Create the modified k-space. These are the coordinates we grid on. By
            %                definition the coordinates must be of dimension: no_samples x
            %                no_y_profiles x no_z_profiles x 3 (See <a href="matlab:helpwin('GridderParsDoc')">Gridder Parameters</a> for more
            %                information):
            %
            %                   k = cat( 4, kx_inverted, ky, kz );
            %
            %                Assign the new trajectory to the Gridder:
            %
            %                   r.Parameter.Gridder.Kpos = k;
            %
            %                Assign gridder weights (sampling density). In this example the samples
            %                are uniformly distributed on the whoe k-space (all weights are set to 1):
            %
            %                   r.Parameter.Gridder.Weights = ones(no_kx_samples, no_ky_samples, no_kz_samples);
            %
            %                Perform the reconstruction:
            %
            %                   r.Perform;
            %
            %                Show the data. Observe that the image is flipped in readout direction
            %                compared to the ungridded reconstruction (a flip in k-space corresponds
            %                to a flip in image-space):
            %
            %                   r.ShowData;
            %
            %             3) Gridder and matrix sizes:
            %
            %                Oversampling: 
            %
            %                During the gridding process we have the possibility to sample on an
            %                arbitrary grid. This means that we can for example sample on a finer or
            %                coarser grid than the acquired one, which corresponds to add or remove
            %                oversampling and therefore changing the FOV in the reconstructed image. The
            %                parameter which specifies the amount of oversampling introduced by the
            %                gridder is <a href="matlab:helpwin('GridderParsDoc.GridOvsFactor')">Parameter.Gridder.GridOvsFactor</a>.
            %                For example if we set:
            %
            %                   r.Parameter.Gridder.GridOvsFactor = 2;
            %                   
            %                then we grid to half the sampled k-space distance and therefore to
            %                twice the FOV. A value smaller than 1 corresponds to a coarser grid
            %                than acquired and therefore a smaller FOV.
            %
            %                In radial scans the acquired oversampling factor in readout direction
            %                is always 2 (hardcoded in the pulse programming enviroment). However If
            %                we check the oversampling factor in r.Parameter.Encoding.KxOversampling
            %                we ca usually find a value like 1.25. This is the oversampling factor
            %                AFTER gridder, which means that we should set: 
            %
            %                   r.Parameter.Gridder.GridOvsFactor = r.Parameter.Encoding.KxOversampling / 2;
            %
            %                This is done automatically done for radial scans, and means that we
            %                grid to a coarser grid leaving an oversampling factor of 1.25. 
            %
            %                Zero Filling:             
            %                Apart from gridding on a finer grid we also have the possibility to
            %                grid on a larger/smaller k-space and therefore changing the resolution
            %                of the scan. Gridding to a larger k-space means that we perform zero
            %                filling whlie gridding to a smaller one is reducing the resolution of
            %                the scan. The parameter which specifies the size of the k-space to be
            %                gridded on is: <a href="matlab:helpwin('GridderParsDoc.OutputMatrixSize')">Parameter.Gridder.OutputMatrixSize</a>.
            %
            %                The output size is the matrix size after gridding. Lets assume we have
            %                a radial scan with 256 acquired samples. If we set: 
            %
            %                   r.Parameter.Gridder.GridOvsFactor = 1;
            %                   r.Parameter.Gridder.OutputMatrixSize = [512,512,1];
            %
            %                The the output matrix has the size 512x512 which means that we have
            %                zero filled the 256x256 sampled k-space to that value. However if we
            %                set: 
            %
            %                   r.Parameter.Gridder.GridOvsFactor = 2;
            %                   r.Parameter.Gridder.OutputMatrixSize = [512,512,1];
            %
            %                Then we have gridded it to a grid twice as fine but NOT zero-filled. To
            %                zero-fill and oversample we have to set: 
            %
            %                   r.Parameter.Gridder.GridOvsFactor = 2;
            %                   r.Parameter.Gridder.OutputMatrixSize = [1024,1024,1];
            %
            %                Summary:      
            %                For radial scans the zero filling and oversampling removal usually
            %                takes place directly in the gridder. Below is an example from a real
            %                radial experiment: 
            %
            %                   Number of acquired samples: 464 (oversampling factor = 2)
            %                   r.Parameter.Encoding.KxOversampling = 1.25
            %                   r.Parameter.Encoding.XRes = 240
            %
            %                   --> Matrix size after gridding = 240 * 1.25 = 300
            %                   --> Gridding oversampling = 1.25 / 2 = 0.625
            %
            %               --> Set gridder parameters to:
            %
            %                   r.Parameter.Gridder.GridOvsFactor = 0.625;
            %                   r.Parameter.Gridder.OutputMatrixSize = [300,300,1];                                                            
            
        end
        function GridderCalculateTrajectory( )
            % GridderCalculateTrajectory: Calculated the gridder trajectory for the current scan and
            % fills the <a href="matlab:helpwin('GridderParsDoc')">gridder parameter</a>
            %
            % Syntax:     r.GridderCalculateTrajectory;            
            %           
            % Parameters used:             
            %           - <a href="matlab:helpwin('GridderParsDoc')">Parameter.Gridder</a>: 
            %             The gridder parameter.  
            %           - <a href="matlab:helpwin('MRparameterDoc.Labels')">Parameter.Labels.NusEncNrs</a>: 
            %             The non-uniform sample position for EPI scans. In EPI acquisitions the
            %             samples in readout direction are not uniformly spread due to the sampling
            %             during gradient ramp up. Therefore EPI scans are usually gridded in
            %             readout direction using the k-space positions specified here. 
            %                  
            % Location:   k-space after SortData.
            %
            % Formats:    Raw | ExportedRaw
            %
            % Description/Algorithm: When the gridder parameter are not defined by the user, they
            %             are calculated internally and will not be visible or changable. If one
            %             wants to observe or change the gridding parameter, this function can be
            %             called which calculates the trajectory for the gridding process and fills
            %             the gridder parameter accordingly. The function can be called for any
            %             preset scan (radial, spiral, EPI), before calling the GridData function.
            %             This is useful if the user wants to modify a preset trajectory without
            %             calculating it by himself. To do so one would call this function,
            %             modify the gridder parameter followed by the call of <a href="matlab:helpwin('MRecon.GridData')">GridData</a>.                         
        end
        function GridderNormalization( )
            % GridderNormalization: Corrects for the signal weighting in image-space originating
            % from the convolution with a bessel kernel in the gridding process.
            %
            % Syntax:     r.GridderNormalization;            
            %           
            % Parameters used:             
            %           - <a href="matlab:helpwin('GridderParsDoc')">Parameter.Gridder</a>: 
            %             The gridder parameter.
            %           - <a href="matlab:helpwin('ReconFlags.isgridded')">Parameter.ReconFlags.isgridded</a>: 
            %             Used to check if the data was gridded. 
            %           - <a href="matlab:helpwin('EncodingPars.WorkEncoding.KxOversampling')">Parameter.Encoding.WorkEncoding.KxOversampling</a>: 
            %             The resulting oversampling after gridding, needed in the normalization.              
            %                  
            % Location:   Image-space.
            %
            % Formats:    Raw | ExportedRaw
            %
            % Description/Algorithm: Gridding is essentially a convolution with a bessel kernel in
            %             k-space. In image-space this corresponds to a multiplication with the
            %             fourier transform of the bessel-kernel leaving a signal weighing on the
            %             reconstructed image. This function corrects for that by dividing the image
            %             by the fourier-transform of the bessel kernel. 
        end
        
        % ---------------------------------------------------------------%
        % k-space / image-space Transformation
        % ---------------------------------------------------------------%
        function K2I( )
            % K2I: Performs a fourier transformation from k-space to image-space
            %
            % Syntax:     r.K2I;            
            %           
            % Parameters used: 
            %           - <a href="matlab:helpwin('EncodingPars.FFTDims')">Parameter.Encoding.FFTDims</a>:
            %             Specifies in which dimension the fourier transformation should be
            %             executed. This is a 3 elements vector specifying the dimension in matrix
            %             notation. 
            %           - <a href="matlab:helpwin('ReconFlags.isimspace')">Parameter.ReconFlags.isimspace</a>: 
            %             Used to check which dimensions are still in k-space    
            %           - <a href="matlab:helpwin('EncodingPars.FFTShift')">Parameter.Encoding.FFTShift</a>:
            %             Specifies in which dimension the image should be shifted after the fourier
            %             transform. This is a 3 elements vector specifying the shift in matrix
            %             notation.
            %           - <a href="matlab:helpwin('EncodingPars.XRange')">Parameter.Encoding.XRange</a>, <a href="matlab:helpwin('EncodingPars.YRange')">Parameter.Encoding.YRange</a>, <a href="matlab:helpwin('EncodingPars.ZRange')">Parameter.Encoding.ZRange</a>:            
            %             Define the shifts of the image after the fourier transform, for every
            %             dimension.
            %                  
            % Recon Flag: <a href="matlab:helpwin('ReconFlags.isimspace')">Parameter.ReconFlags.isimspace</a>
            %
            % Location:   k-space
            %
            % Formats:    Raw | ExportedRaw | Cpx | Rec | Bruker
            %
            % Description/Algorithm: K2I first checks which dimensions should be transformed,
            %             defined in <a href="matlab:helpwin('EncodingPars.FFTDims')">Parameter.Encoding.FFTDims</a>. Afterwards it checks which of             
            %             these dimensions are in k-space and then only transforms these ones. The
            %             fourier transformation along one dimension is given by:
            %
            %                   img = sqrt(n).* fftshift( ifft(ifftshift(kspace ,dim),[],dim), dim);
            %
            %             where n are the number of samples along the specific dimension. 
            %
            %             After the fourier transform from k- to image-space, the images are shifted
            %             in image-space as defined in Parameter.Encoding.X/Y/ZRange. Thereby the
            %             images are shifted by the amount which leads to a symmetric range around 0.
            %             E.g. if the range is given as [-42, 21] then the image is shifted by 10
            %             pixel to the right. ( [-42, 21] + 10 = [-32, 31] )            
        end
        function K2IM( )
            % K2IM: Performs a fourier transformation from k-space to image-space in measurement
            % direction
            %
            % Syntax:     r.K2IM;            
            %           
            % Parameters used: 
            %           - <a href="matlab:helpwin('EncodingPars.FFTDims')">Parameter.Encoding.FFTDims</a>:
            %             Specifies if the FFT in measurement direction should be executed. This is 
            %             a 3 elements vector specifying the dimension in matrix notation. 
            %           - <a href="matlab:helpwin('ReconFlags.isimspace')">Parameter.ReconFlags.isimspace</a>: 
            %             Used to check if the measurement direction is still in k-space    
            %           - <a href="matlab:helpwin('EncodingPars.FFTShift')">Parameter.Encoding.FFTShift</a>:            
            %             Specifies if the image should be shifted in measurement direction after
            %             the fourier transform. This is a 3 elements vector specifying the
            %             shift in matrix notation.
            %           - <a href="matlab:helpwin('EncodingPars.XRange')">Parameter.Encoding.XRange</a>:            
            %             Define the shifts of the image after the fourier transform in measurement
            %             direction.
            %                  
            % Recon Flag: <a href="matlab:helpwin('ReconFlags.isimspace')">Parameter.ReconFlags.isimspace</a>
            %
            % Location:   k-space
            %
            % Formats:    Raw | ExportedRaw | Cpx | Rec | Bruker
            %
            % Description/Algorithm: K2IM first checks if the measurement direction should be             
            %             transformed, defined in <a href="matlab:helpwin('EncodingPars.FFTDims')">Parameter.Encoding.FFTDims</a>. Afterwards it                
            %             checks if the measurement direction is still in k-space and if yes
            %             transforms it. The fourier transformation along one dimension is given by:
            %
            %                   img = sqrt(n).* fftshift( ifft(ifftshift(kspace ,dim),[],dim), dim);
            %
            %             where n are the number of samples along the specific dimension. 
            %
            %             After the fourier transform from k- to image-space, the image is shifted
            %             in measurement direction as defined in Parameter.Encoding.XRange.
            %             Thereby the images are shifted by the amount which makes the range symmetric
            %             around 0. E.g. if the range is given as [-42, 21] then the image is
            %             shifted by 10 pixel to the right. ( [-42, 21] + 10 = [-32, 31] )            
        end
        function K2IP( )
            % K2IP: Performs a fourier transformation from k-space to image-space in phase encoding
            % directions
            %
            % Syntax:     r.K2IP;            
            %           
            % Parameters used: 
            %           - <a href="matlab:helpwin('EncodingPars.FFTDims')">Parameter.Encoding.FFTDims</a>:            
            %             Specifies if the FFT in phase encoding directions should be executed. This
            %             is a 3 elements vector specifying the dimension in matrix notation.
            %           - <a href="matlab:helpwin('ReconFlags.isimspace')">Parameter.ReconFlags.isimspace</a>: 
            %             Used to check if the phase encoding directions are still in k-space    
            %           - <a href="matlab:helpwin('EncodingPars.FFTShift')">Parameter.Encoding.FFTShift</a>:            
            %             Specifies if the image should be shifted in phase encoding directions after
            %             the fourier transform. This is a 3 elements vector specifying the
            %             shift in matrix notation.
            %           - <a href="matlab:helpwin('EncodingPars.XRange')">Parameter.Encoding.YRange</a>, <a href="matlab:helpwin('EncodingPars.ZRange')">Parameter.Encoding.ZRange</a>:                        
            %             Define the shifts of the image after the fourier transform in phase
            %             encoding directions.
            %                  
            % Recon Flag: <a href="matlab:helpwin('ReconFlags.isimspace')">Parameter.ReconFlags.isimspace</a>
            %
            % Location:   k-space
            %
            % Formats:    Raw | ExportedRaw | Cpx | Rec | Bruker
            %
            % Description/Algorithm: K2IP first checks if the phase encoding directions should be ,            
            %             transformed, defined in <a href="matlab:helpwin('EncodingPars.FFTDims')">Parameter.Encoding.FFTDims</a>. Afterwards it                          
            %             checks if the phase encoding directions are still in k-space and if yes
            %             transforms them. The fourier transformation along one dimension is given by:
            %
            %                   img = sqrt(n).* fftshift( ifft(ifftshift(kspace ,dim),[],dim), dim);
            %
            %             where n are the number of samples along the specific dimension. 
            %
            %             After the fourier transform from k- to image-space, the images are shifted
            %             in phase encoding directions as defined in Parameter.Encoding.Y/ZRange.
            %             Thereby the images are shifted by the amount which results in a symmetric
            %             range around 0. E.g. if the range is given as [-42, 21] then the image is
            %             shifted by 10 pixel to the right. ( [-42, 21] + 10 = [-32, 31] )            
        end
        function I2K( )
            % I2K: Performs a fourier transformation from image-space to k-space    
            %
            % Syntax:     r.I2K;            
            %           
            % Parameters used: 
            %           - <a href="matlab:helpwin('EncodingPars.FFTDims')">Parameter.Encoding.FFTDims</a>:
            %             Specifies in which dimension the fourier transformation should be
            %             executed. This is a 3 elements vector specifying the dimension in matrix
            %             notation. 
            %           - <a href="matlab:helpwin('ReconFlags.isimspace')">Parameter.ReconFlags.isimspace</a>: 
            %             Used to check which dimensions are already in image space            
            %                  
            % Recon Flag: <a href="matlab:helpwin('ReconFlags.isimspace')">Parameter.ReconFlags.isimspace</a>
            %
            % Location:   Image-Space
            %
            % Formats:    Raw | ExportedRaw | Cpx | Rec | Bruker
            %
            % Description/Algorithm: I2K first checks which dimensions should be transformed,
            %             defined in <a href="matlab:helpwin('EncodingPars.FFTDims')">Parameter.Encoding.FFTDims</a>. Afterwards it checks which of             
            %             these dimensions are in image-space and then only transforms these ones.
            %             The fourier transformation along one dimension is given by:
            %
            %                   kspace = 1/sqrt(n)*fftshift(fft(ifftshift( img, dim ),[],dim),dim);
            %
            %             where n are the number of samples along the specific dimension.                                    
        end
        
        % ---------------------------------------------------------------%
        % Coil Combination
        % ---------------------------------------------------------------%
        function CombineCoils( )
        % CombineCoils: Combines the individual coil images into one single image. Several
        % combination methods have been implemented in MRecon (see below).
        %
        % Syntax:     r.CombineCoils;
        % 
        % Parameters used:
        %           - <a href="matlab:helpwin('ReconParsDoc.CoilCombination')">Parameter.Recon.CoilCombination</a>: {'sos'} | 'pc' | 'svd' | 'snr_weight'
        %             When set on 'sos' a sum-of-squares combination is performed. Note that the image
        %             phase is lost with this method. 'pc' is used in phase contrast flow
        %             reconstructions where the magnitude is a sum-of-squares combination and the
        %             phase is a magnitude weighted combination of the individual phase images. 'svd' and 'snr_weight'
		%             are intended for spectroscopy data. For spectro 'svd' is the default because it works
		%             without prior phasing the individual coil signals. For 'snr_weight' the individual channels
		%             should already be correctly phased either by external phase correction or by the 
		%             implemented eddy current correction procedure.                
        %          
        % Recon Flag: <a href="matlab:helpwin('ReconFlagParsDoc.iscombined')">Parameter.ReconFlags.iscombined</a>
        %
        % Location:   Image-space.
        %
        % Formats:    Raw | ExportedRaw | Cpx | Bruker
        %
        % Notes:    - For a non-phase-contrast scan the image phase is lost after CombineCoils. If
        %             you want to preserve the phase please perform a SENSE/CLEAR reconstruction see
        %             the SENSEUnfold function. This does not apply to spectroscopy data where the phase 
		%             is always retained.
        %           - The CombineCoils function destroys the label lookup
        %             table (Parameter.LabelLookupTable) since the profiles cannot be related to the
        %             labels after combining the coils.
        %           - The coils have to be in the 4th dimension of the Data
        %             array to be combined.            
        end
        
        % ---------------------------------------------------------------%
        % SENSE / Partial Fourier
        % ---------------------------------------------------------------%
        function PartialFourier( )
            % PartialFourier: Performs a partial fourier reconstruction (homodyne method). 
            %
            % Syntax:     r.PartialFourier;            
            %           
            % Parameters used: 
            %           - <a href="matlab:helpwin('ReconParsDoc.PartialFourier')">Parameter.Recon.PartialFourier</a>: {'yes'} | 'no'
            %             Enables/disables the partial fourier reconstruction. 
            %           - <a href="matlab:helpwin('MRparameterDoc.DataFormat')">Parameter.DataFormat</a>:
            %             Used to check if the right data format is passed to the function             
            %           - <a href="matlab:helpwin('ReconFlagParsDoc.isimspace')">Parameter.ReconFlags.isimspace</a>:
            %             Used to check if the data is in k- or image-space. 
            %           - <a href="matlab:helpwin('EncodingPars.KxRange')">Parameter.Encoding.KxRange</a>, <a href="matlab:helpwin('EncodingPars.KyRange')">Parameter.Encoding.KyRange</a>, <a href="matlab:helpwin('EncodingPars.KzRange')">Parameter.Encoding.KzRange</a>:
            %             Specifies the sampling ranges in k-space. These parameters are used to
            %             check if the scan is acquired using partial fourier and define the fully
            %             sampled k-space center. 
            %           - <a href="matlab:helpwin('ScanPars.SENSEFactor')">Parameter.Scan.SENSEFactor</a>:
            %             The SENSE factor used to define the fully sampled k-space center.             
            %
            % Recon Flag: <a href="matlab:helpwin('ReconFlagParsDoc.ispartialfourier')">Parameter.ReconFlags.ispartialfourier</a>
            %
            % Location:   k-space | image-space
            %
            % Formats:    Raw | ExportedRaw | Bruker
            %
            % Description/Algorithm: In partial fourier imaging only a fraction of k-space is
            %             acquired for improved scan- or echo-time. If the k-space is partly sampled
            %             in readout direction we speak of partial echo and halfscan for a partly
            %             sampled space in phase encoding direction. In the first case the echo time
            %             is reduced while in the second one the scantime is shortened. Performing a
            %             standard imaging reconstruction on the partly sampled k-space however
            %             leads to image bluring and reduced SNR. Therefore a partial fourier
            %             reconstruction is performed which utilizes the k-space symmetry to
            %             reconstruct images of better quality. In MRecon a so called homodyne
            %             reconstruction is implemented: Noll, D.C.; Nishimura, D.G.; Macovski, A.;
            %             "Homodyne detection in magnetic resonance imaging" Medical Imaging,
            %             IEEE Transactions on, vol.10, no.2, pp.154-163, Jun 1991. 
            %
            % Notes:    - In principle the partial fourier reconstruction can either be performed in
            %             k- or image space. However if executed in k-space it is not possible to
            %             perform a SENSE or CLEAR reconstruction afterwards since the phase
            %             information will be lost. Therefore we suggest to execute it in image
            %             space after SENSEUnfold which works in any case.            
        end
        function PartialFourierFilter( )
             % PartialFourierFilter: Applies the homodyne filter in k-space
            %
            % Syntax:     r.PartialFourierFilter;            
            %           
            % Parameters used: 
            %           - <a href="matlab:helpwin('ReconParsDoc.PartialFourier')">Parameter.Recon.PartialFourier</a>: {'yes'} | 'no'
            %             Enables/disables the partial fourier reconstruction. 
            %           - <a href="matlab:helpwin('MRparameterDoc.DataFormat')">Parameter.DataFormat</a>:
            %             Used to check if the right data format is passed to the function             
            %           - <a href="matlab:helpwin('ReconFlagParsDoc.isimspace')">Parameter.ReconFlags.isimspace</a>:
            %             Used to check if the data is in k- or image-space. 
            %           - <a href="matlab:helpwin('EncodingPars.KxRange')">Parameter.Encoding.KxRange</a>, <a href="matlab:helpwin('EncodingPars.KyRange')">Parameter.Encoding.KyRange</a>, <a href="matlab:helpwin('EncodingPars.KzRange')">Parameter.Encoding.KzRange</a>:
            %             Specifies the sampling ranges in k-space. These parameters are used to
            %             check if the scan is acquired using partial fourier and define the fully
            %             sampled k-space center. 
            %           - <a href="matlab:helpwin('ScanPars.SENSEFactor')">Parameter.Scan.SENSEFactor</a>:
            %             The SENSE factor used to define the fully sampled k-space center.             
            %
            % Recon Flag: <a href="matlab:helpwin('ReconFlagParsDoc.ispartialfourier')">Parameter.ReconFlags.ispartialfourier</a>
            %
            % Location:   k-space 
            %
            % Formats:    Raw | ExportedRaw | Bruker
            %
            % Description/Algorithm: This function applies the homodyne filter in k-space, used for
            %             the partial fourier reconstruction. If this function is called in k-space
            %             before K2I it saves the need for two extra FFT's when PartialFourier is
            %             executed and thus increases the performance of the recon. Calling this
            %             function is optional. If it has not been called the filter will be applied
            %             during PartialFourier. For more information about the partial fourier
            %             reconstruction refer to the documentation of PartialFourier.
        end
        function SENSEUnfold( )
            % SENSEUnfold: Performs a SENSE reconstruction using the coil sensitivity information
            % provided by the user. 
            %
            % Syntax:     r.SENSEUnfold;            
            %           
            % Parameters used: 
            %           - <a href="matlab:helpwin('ReconParsDoc.SENSE')">Parameter.Recon.SENSE</a>: {'yes'} | 'no'
            %             Enables/disables the SENSE unfolding. 
            %           - <a href="matlab:helpwin('ReconParsDoc.Sensitivities')">Parameter.Recon.Sensitivities</a>:
            %             The sensitivity object (MRsense) used in the unfolding process. The
            %             sensitivity object holds the coil sensitivities, the noise covariance
            %             matrix as well as regularisation images.
            %           - <a href="matlab:helpwin('ReconParsDoc.SENSERegStrength')">Parameter.Recon.SENSERegStrength</a>:
            %             The regularization strength used during the SENSE unfolding. A higher
            %             regularizazion results in a stronger suppression of low signal values in
            %             the unfolded images.
            %           - <a href="matlab:helpwin('ScanParsDoc.SENSEFactor')">Parameter.Scan.SENSEFactor</a>:
            %             The SENSE reduction factor.
            %
            % Recon Flag: <a href="matlab:helpwin('ReconFlagParsDoc.isunfolded')">Parameter.ReconFlags.isunfolded</a>            
            %           
            % Location:   image-space
            %
            % Formats:    Raw | ExportedRaw
            %
            % Description/Algorithm: Please see the <a href="matlab:open('MRsense quickstart.pdf')">MRsense manual</a> for more infomation on the
            % implemented algorithms and examples.
        end
        
        % ---------------------------------------------------------------%
        % Image Production
        % ---------------------------------------------------------------%
        function ZeroFill( )  
            % ZeroFill: Zero pads the data either in k-space or image-space
            %
            % Syntax:     r.ZeroFill;            
            %           
            % Parameters used: 
            %           - <a href="matlab:helpwin('ReconParsDoc.kSpaceZeroFill')">Parameter.Recon.kSpaceZeroFill</a>: {'yes'} | 'no'
            %             Enables/disables the k-space zero filling.          
            %           - <a href="matlab:helpwin('ReconParsDoc.ImageSpaceZeroFill')">Parameter.Recon.ImageSpaceZeroFill</a>: {'yes'} | 'no'
            %             Enables/disables the image-space zero filling.                      
            %           - <a href="matlab:helpwin('ReconFlagParsDoc.isimspace')">Parameters.ReconFlags.isimspace</a>: 
            %             Used to check if the data is in k- or image-space. 
            %           - <a href="matlab:helpwin('ReconFlagParsDoc.isoversampled')">Parameters.ReconFlags.isoversampled</a>: 
            %             Used to check if and in which directions the data is oversampled. 
            %           - <a href="matlab:helpwin('EncodingParsDoc.XRes')">Parameter.Encoding.XRes</a>, <a href="matlab:helpwin('EncodingParsDoc.YRes')">Parameter.Encoding.YRes</a>, <a href="matlab:helpwin('EncodingParsDoc.ZRes')">Parameter.Encoding.ZRes</a>:            
            %             The data is zero filled to these dimension in k-space (times the remaining oversampling factor). 
            %           - <a href="matlab:helpwin('EncodingParsDoc.XReconRes')">Parameter.Encoding.XReconRes</a>, <a href="matlab:helpwin('EncodingParsDoc.YReconRes')">Parameter.Encoding.YReconRes</a>, <a href="matlab:helpwin('EncodingParsDoc.ZReconRes')">Parameter.Encoding.ZReconRes</a>:            
            %             The data is zero filled to these dimension in image-space (times the remaining oversampling factor). 
            %           - <a href="matlab:helpwin('EncodingParsDoc.KxOversampling')">Parameter.Encoding.KxOversampling</a>, <a href="matlab:helpwin('EncodingParsDoc.KyOversampling')">Parameter.Encoding.KyOversampling</a>, <a href="matlab:helpwin('EncodingParsDoc.KzOversampling')">Parameter.Encoding.KzOversampling</a>:            
            %             The oversamping factors in x/y/z-directions.
            %           - <a href="matlab:helpwin('ReconFlagParsDoc.issorted')">Parameters.ReconFlags.issorted</a>: 
            %             Used to check if the data is already sorted.                       
            %
            % Recon Flag: <a href="matlab:helpwin('ReconFlagParsDoc.iszerofilled')">Parameter.ReconFlags.iszerofilled</a>
            %
            % Location:   k-space | Image-space.
            %
            % Formats:    Raw | ExportedRaw | Cpx | Bruker
            %
            % Description/Algorithm: The ZeroFill function zero-pads the current data to the
            %             dimensions specified in the Encoding parameters (see above). Thereby we
            %             have a different dimension depending whether we are in k-space or
            %             image-space. For example the dimension in y-direction after zero filling
            %             in k-space is given by: 
            %
            %               yres = r.Parameter.Encoding.YRes * cur_ovs
            %
            %             where the current oversampling cur_ovs is given by:
            %
            %               cur_ovs = r.Parameter.Encoding.KyOversampling  (if oversampling is not removed) 
            %             or
            %               cur_ovs = 1                                    (if oversampling is removed) 
            %
            %             Whether and in which directions the data is oversampled is defined by the
            %             oversampling ReconFlag (<a href="matlab:helpwin('ReconFlagParsDoc.isoversampled')">Parameters.ReconFlags.isoversampled</a>).
            %
            %             Zero filling in k-space is used to correct for anisotropic voxel sizes and
            %             the artificially increase image resolution. Zero filling in k-space is
            %             used to correct for a rectangular field-of-view and to produce quadratic
            %             images. 
        end
        function RemoveOversampling( )
            % RemoveOversampling: Removes the oversampling from the image by cropping the data in
            % image-space. For spectroscopy an additional algorithm based on Linear Prediction (LP) is available
			% for the readout direction. It is performed in the time domain and leads to much reduced truncation 
			% artifacts at the beginning and the end of the FID [Fuchs A et al., ISMRM 2012].
            %
            % Syntax:     r.RemoveOversampling;            
            %           
            % Parameters used: 
            %           - <a href="matlab:helpwin('ReconParsDoc.RemoveMOversampling')">Parameter.Recon.RemoveMOversampling</a>: {'yes'} | 'no'
            %             Enables/disables the oversampling removal in readout (measurement)
            %             direction
            %           - <a href="matlab:helpwin('ReconParsDoc.RemovePOversampling')">Parameter.Recon.RemovePOversampling</a>: {'yes'} | 'no'
            %             Enables/disables the oversampling removal in phase-encoding direction(s)
            %           - <a href="matlab:helpwin('ReconFlagParsDoc.isimspace')">Parameters.ReconFlags.isimspace</a>: 
            %             Used to check if the data is in k- or image-space. 
            %           - <a href="matlab:helpwin('EncodingParsDoc.KxOversampling')">Parameter.Encoding.KxOversampling</a>, <a href="matlab:helpwin('EncodingParsDoc.KyOversampling')">Parameter.Encoding.KyOversampling</a>, <a href="matlab:helpwin('EncodingParsDoc.KzOversampling')">Parameter.Encoding.KzOversampling</a>:            
            %             The oversamping factors in x/y/z-directions. After calling the
            %             RemoveOversampling function the Data matrix is smaller by these factors.
            %           - <a href="matlab:helpwin('ReconFlagParsDoc.issorted')">Parameters.ReconFlags.issorted</a>: 
            %             Used to check if the data is already sorted.                       
			%           - <a href="matlab:helpwin('SpectroPars.Downsample')">Parameter.Spectro.Downsample</a>:
			%             Enable/disable the LP based algorithm for spectroscopy.                       
            %
            % Recon Flag: <a href="matlab:helpwin('ReconFlagParsDoc.isoversampled')">Parameter.ReconFlags.isoversampled</a>
            %
            % Location:   k-space | Image-space.
            %
            % Formats:    Raw | ExportedRaw | Cpx | Bruker
            %
            % Description/Algorithm: Generally the receiver samples data denser in readout direction
            %             than specified in the user interface. The denser sampling produces a
            %             larger field-of view (FOV) and prevents fold-over artifacts in readout
            %             direction. Oversampling in readout direction does not increase the scan
            %             time as the receiver can sample at a much higher frequency than desired.
            %             In 3D acquisitions the data is usually oversampled in slice encoding
            %             direction as well to correct for improper slice excitation of the outer
            %             slices. Oversamlling in slice encoding direction does affect the scan time
            %             however.             
            %             Since the denser sampling basically results in the acquisiton of a larger
            %             FOV we have to remove the oversampling by cropping the image in
            %             image-space and thereby preserving the signal-to-noise ratio (SNR).
            %             Removing the oversampling in k-space would not be beneficial as we
            %             would lose SNR.            
			%             The Linear prediction (LP) based algorithm [Fuchs A et al., ISMRM 2012] 
			%             can be used for spectroscopy data to downsample the readout direction. It
			%             operates in the time domain without losing SNR and leads to much less pronounced
			%             truncation artifacts.
            %             In MRecon the RemoveOversampling can be called at three different
            %             locations: 
            %             
            %             1) Before SortData: The oversampling is only removed in readout direction
            %                                 by fourier transforming the data in that direction and
            %                                 cropping it. This is usually done to reduce the amount
            %                                 of data and save memory.
            %             2) After SortData:  The oversampling is removed in all directions
            %                                 by fourier transforming the data in every oversampled
            %                                 direction and cropping it in image space.
            %             3) In image-space:  The oversampling is removed in all directions by
            %                                 cropping the data.
            %
			%             For spectroscopy data using the LP based algorithm should be in k-space and
			% 			  preferable before SortData. Only the readout direction will be downsampled with
			% 			  that method.
			%
            % Notes:    - The oversampling is not removed for data which has to be gridded when
            %             called before SortData (radial, spiral, EPI).
			%           - The implementation of the LP based algorithm is at the moment much slower and it
			%             requires Matlab's Signal Processing Toolbox to be installed.
        end
        function ScaleData( )
            % ScaleData: Clips the data such that 98% of its histogram is preserved
            %
            % Syntax:     r.ScaleData;            
            %           
            % Parameters used: None             
            %           
            % Location:   Image-space
            %
            % Formats:    Raw | ExportedRaw | Cpx | Rec | Bruker
            %
            % Description/Algorithm: A histogram is calculated over all values in the Data array and
            %             the value is found which includes 98% of the histograms integral. The data
            %             is then clipped at that value. This function is usefull to remove unwanted
            %             signal peaks.                         
        end
        function RotateImage( )
            % RotateImage: Rotates the images such that they are oriented in the same way as on the
            % scanner console.
            %
            % Syntax:     r.RotateImage;            
            %           
            % Parameters used: 
            %           - <a href="matlab:helpwin('ReconParsDoc.RotateImage')">Parameter.Recon.RotateImage</a>: {'yes'} | 'no'
            %             Enables/disables the image rotation. 
            %           - <a href="matlab:helpwin('ScanParsDoc.ijk')">Parameter.Scan.ijk</a>:
            %             Specifies the coordinate system of the images before the rotation (current
            %             coordinate system).
            %           - <a href="matlab:helpwin('ScanParsDoc.REC')">Parameter.Scan.REC</a>:
            %             Specifies the coordinate system of the images after the rotation
            %             (coordinate system of the Rec images).       
            %
            % Recon Flag: <a href="matlab:helpwin('ReconFlagParsDoc.isrotated')">Parameter.ReconFlags.isrotated</a>
            %
            % Location:   Image-space
            %
            % Formats:    Raw
            %
            % Description/Algorithm: After reading the raw data it is oriented in The MPS system,
            %             meaning that the rows in the Data matrix are aligned along the measurement
            %             direction and the columns along the phase encoding direction. The MPS
            %             system however heavily depends on the chosen scan parameters, such as
            %             orientation, fold-over direction, fat shift direction etc. The
            %             reconstructed images, displayed on the scanner console on the other hand
            %             are oriented in a well defined fashion expressed in the patient coordinate
            %             system (right-left (RL), anterior-posterior (AP), feet-head (FH) ). The
            %             RotateImage function transforms the Data from the current coordinate
            %             system (usually MPS) the the final orientation displayed on the scanner
            %             console. 
            %
            % Examples:   The Rotate Image basically performes a transformation between the system
            %             specified in r.Parameter.Scan.ijk and r.Parameter.Scan.REC. These
            %             coordinates systems are always expressed in the patient system (RL, AP,
            %             FH). Lets assume these values are given as:
            %
            %                   r.Parameter.Scan.ijk = [RL, FH, AP]
            %                   r.Parameter.Scan.REC = [HF, RL, AP]    
            %
            %             To transform the ijk system to the REC system, we have to switch the first
            %             and the secons axis of the Data matrix (permute it):
            %
            %                   [RL, FH, AP]  -->  [FH, RL, AP]
            %
            %             and then flip the first axis (flipdim): 
            %
            %                   [FH, RL, AP]  -->  [HF, RL, AP]            
        end
        function DivideFlowSegments( )
            % DivideFlowSegments: Calculates the phase image proportional to the flow, by dividing
            % the two flow segments.
            %
            % Syntax:     r.DivideFlowSegments;            
            %           
            % Parameters used: 
            %           - <a href="matlab:helpwin('ScanPars.Venc')">Parameter.Scan.Venc</a>:
            %             Used to check if the current scan is a flow acquisition. Has to be unequal
            %             to zero. 
            %           - <a href="matlab:helpwin('ReconParsDoc.CoilCombination')">Parameter.Recon.CoilCombination</a>:
            %             Used to check if the phase was preserved during the coil combination. Has
            %             to be set to 'pc'.            
            %
            % Location:   image-space
            %
            % Formats:    Raw, ExportedRaw
            %
            % Description/Algorithm: In flow acquisitions two flow segments are acquired, eigher
            %             with negativ and positiv flow encoding (symmetric) or with flow and no
            %             flow encoding (asymmetric). To obtain the quantitative flow values a phase
            %             image proportional to the flow is calculated, by dividing the two
            %             segments. The phase values in the divided image reach from -pi-pi
            %             corresponding to flow values from 0-venc.
            %                                   
            % Notes:    - The two segments are stored in the 10th dimension of the Data array.                                           
        end
        function Average( MR )
            % Average: 	  Averages the data in the 12th dimension of the data array. For spectroscopy the
			%  			  averaging scheme can be customized and can be extended to include also the 5th
			%  			  dimension of the data array. 
            %
            % Syntax:     r.Average;            
            %           
            % Parameters used: 
            %           - <a href="matlab:helpwin('ScanParsDoc.Diffusion')">Parameter.Scan.Diffusion</a>:
            %             Used to check if it is a diffusion scan. Only the magnitude is averaged
            %             for diffusion scans since phase cancelations can occur otherwise. 
			%           - <a href="matlab:helpwin('AveragingParsDoc')">Parameter.Spectro.Averaging</a>:
			%             Used to configure customized averaging schemes for spectroscopy.
            %
            % Location:   k-space | image-space
            %
            % Formats:    Raw | ExportedRaw 
            %
            % Description/Algorithm: This function averages the data in the 12th dimension of the
            %             data array (where the different averages are stored). This function only has
            %             an effect if immediate averaging is disabled (r.Parameter.Recon.ImmediateAveraging).             
            %             If immediate averaging is enabled, then the data is averaged in the
            %             SortData function already. Some data, however should not be averaged in
            %             k-space (e.g. diffusion scans). That is why this function is called in
            %             image space to average the remaining averages which have not been
            %             processed yet.
			%             For spectroscopy more complex averaging schemes can be configured for different
			%             situations. Block wise averaging can be set up and could be useful to increase 
			%             SNR in intermediate post processing steps. Furthermore add/subtract schemes for 
			%             FIDs and dynamics can be customized to be used for example in spectral editing
			%             experiments. 
            %
            % Notes:    - For diffusion scans only the magnitude is averaged.           
        end
        
        % ---------------------------------------------------------------%
        % Operations on REC Data
        % ---------------------------------------------------------------%
        function RescaleREC( )
            % RescaleREC: Rescales REC data to the original floating point value
            %
            % Syntax:     r.RescaleREC;            
            %           
            % Parameters used: 
            %           - <a href="matlab:helpwin('InfoPars.RescaleSlope')">Parameter.ImageInformation.RescaleSlope</a>:
            %             The rescale factor.
            %           - <a href="matlab:helpwin('InfoPars.RescaleIntercept')">Parameter.ImageInformation.RescaleIntercept</a>:
            %             The Rescale offset.                       
            %           
            % Location:   image-space
            %
            % Formats:    Rec
            %
            % Description/Algorithm: The data type in Rec data is 16bit unsigned integer. However it
            %             is possible to restore the original floating point values with the rescale
            %             factor/offset which is stored in the parfile. The floating point value is
            %             given by:
            %
            %             floating_point_value = value_in_recfile * rescale_slope + rescale_intercept
                                       
        end
        function CreateComplexREC( )
            % CreateComplexREC: Creates complex images from Philips REC data.
            %
            % Syntax:     r.CreateComplexREC;            
            %           
            % Parameters used: 
            %           - <a href="matlab:helpwin('MRparameterDoc.DataFormat')">MR.Parameter.DataFormat</a>:
            %             Is used to check if REC data is passed to the function            
            %            
            % Location:   Image-space.
            %
            % Formats:    Rec
            %
            % Description/Algorithm: Magnitude and phase are stored as seperate images in Philips
            %             REC files. This means that they are also stored as seprate images in the
            %             MRecon Data array when the file is read. This function creates complex
            %             data from the seperate magnitude and phase images and stores it in the Data
            %             array. The complex image is calculated as: 
            %
            %                        complex_image = magnitude_image * exp( i*phase_image)  
            %
            % Notes:    - Not all REC files contain magnitude or phase images. The stored image
            %             types are selected on the scanner user interface. If the REC data does not
            %             contain both types this function has no effect.             
        end
        
        % ---------------------------------------------------------------%
        % Image Viewing
        % ---------------------------------------------------------------%
        function ShowData( )
            % ShowData: Displays the Data array using MRecon's built-in 3D image viewer.
            %
            % Syntax:     r.ShowData;            
            %           
            % Parameters used: None             
            %           
            % Location:   k-space | Image-space
            %
            % Formats:    Raw | ExportedRaw | Cpx | Rec | Bruker
            %
            % Description/Algorithm: Opens the built-in 3D image viewer of MRecon and displays the
            %             Data array. 
            %
            % Notes:    - The MRecon image viewer is a standalone tool and can be used to visualize
            %             any Matlab matrix. It can be called as: 
            % 
            %                   image_slide( Matrix )
            %
            %             r.ShowData therefore is aequivalent to:
            %
            %                   image_slide( r.Data )
        end
        function CreateVideo(Dimension, Filename, Framerate, OutputFormat, StartFrame, EndFrame )
            % CreateVideo: Creates a video from reconstructed images stored in the MRecon object
            %
            % Syntax:     CreateVideo(Dimension, Filename, Framerate, OutputFormat, StartFrame, EndFrame );
            %
            % Inputs:
            %   Dimension       Dimension of the Data array over which the the video is generated.
            %                   Default = 5 (dynamics)      
            %   Filename        Name of the output video file. Default = generated from parameters
            %   Framerate       Desired framerate of the output video (frames/s). Default = 15
            %   OutputFormat    the output format('avi' or 'gif'). Default = 'avi' 
            %   StartFrame      First frame of the video. Default = 1
            %   EndFrame        Last frame of the video. Default = nr_images
            %                        
            %
            % Important Notes:  Animated .gifs with framerates higher than approx. 15 fps are not 
            %                   played at the right speed with some video player (e.g. Microsoft Power Point) 
            %                   Use .avi format for higher framerates.                        
        end
       
        
        % ---------------------------------------------------------------%
        % Coordinate System Transformations
        % ---------------------------------------------------------------%
        function varargout = Transform( varargin )
            % Transform: Transforms coordinates from one scanner coordinate system to another
            %
            % Syntax:     [xyz_transformed, A] = r.Transform( xyz, from_system, to_system, stack_nr);            
            %               or
            %             A = r.Transform( from_system, to_system, stack_nr);            
            %
            %           
            % Parameters used: 
            %           - <a href="matlab:helpwin('ScanParsDoc.ijk')">Parameter.Scan.ijk</a>, <a href="matlab:helpwin('ScanParsDoc.MPS')">Parameter.Scan.MPS</a>, <a href="matlab:helpwin('ScanParsDoc.xyz')">Parameter.Scan.xyz</a>, <a href="matlab:helpwin('ScanParsDoc.REC')">Parameter.Scan.REC</a>
            %             The different scanner coordinates system expressed in the patient
            %             coordinate system.
            %           - <a href="matlab:helpwin('ScanParsDoc.Angulation')">Parameter.Scan.Angulation</a>, <a href="matlab:helpwin('ScanParsDoc.Offcentre')">Parameter.Scan.Offcentre</a>:
            %             Angulation and offcentre of the scan. 
            %           - <a href="matlab:helpwin('ScanParsDoc.curFOV')">Parameter.Scan.curFOV</a>:            
            %             The current field of view of the scan. curFOV corresponds to the FOV of 
            %             the current data and does change during the reconstruction process.
            %             Removing the oversampling for example reduces the FOV.             
            %           - <a href="matlab:helpwin('ScanParsDoc.SliceGap')">Parameter.Scan.SliceGap</a>:
            %             The slice gap of the scan.
            %
            %           - <a href="matlab:helpwin('EncodingParsDoc.XRes')">Parameter.Encoding.XRes</a>, <a href="matlab:helpwin('EncodingParsDoc.YRes')">Parameter.Encoding.YRes</a>, <a href="matlab:helpwin('EncodingParsDoc.ZRes')">Parameter.Encoding.ZRes</a>
            %             <a href="matlab:helpwin('EncodingParsDoc.KyOversampling')">Parameter.Encoding.KyOversampling</a>, <a href="matlab:helpwin('EncodingParsDoc.KzOversampling')">Parameter.Encoding.KyOversampling</a>:                                    
            %             These parameters are only used if the Data matrix is empty. The default
            %             matrix size used in the Transform function, when no data is present, is the
            %             one which we would obtain after the SENSE unfolding (which has to be used
            %             for calculating the coil sensitivities). It is given by:
            %                   [XRes, YRes*KyOversampling, ZRes*KzOversampling]
            %
            % Location:   k-space | image-space
            %
            % Formats:    Raw | Rec
            %
            % Description/Algorithm: Please see the <a href="matlab:open('CoordinateTransformations.pdf')">transformation manual</a> for more infomation on the
            %             different coordinate systems and examples.
            %
            %             To transform a coordinate from one coordinate system to another the
            %             following parameters have to be known: 
            %                   
            %             - Patient Position     (defines coordinate system)
            %             - Patient Orientation  (defines coordinate system)
            %             - Image Orientation    (defines coordinate system)
            %             - Fold Over Direction  (defines coordinate system)
            %             - Fat Shift Direction  (defines coordinate system)
            %
            %             - Angulation           (fixed, used in Transform)
            %             - Offcentre            (fixed, used in Transform)  
            %             - Slice Gap            (fixed, used in Transform)  
            %             - Resolution           (variable, used in Transform: Resolution = curFOV / size(Data) )
            %             - Image Matrix         (variable, used in Transform for ijk, REC systems)
            %
            %             The first 5 parameters are used to define the different coordinate systems
            %             (ijk, MPS, RAF, xyz, REC), which are stored in Parameter.Scan and used in
            %             the Transform function. Therefore the parameters itself are not needed in
            %             the Transform function anymore.                  
            %             Basically the parameters which are used in the Transform function can be
            %             divided into 2 groups: fixed and variable parameters. The fixed ones, such
            %             as the image angulation, do not change during the reconstruction process
            %             whereas the variable ones can change. The image resolution for example
            %             changes if we perform a k-space zero filling. In transform the current
            %             image resolution is calculated by dividing the current FOV by the current
            %             matrix size. Therefore if you are performing your own reconstruction and
            %             are not using the built-in MRecon functions (e.g. RemoveOversampling)
            %             always make sure that Parameter.Scan.curFOV corresponds to the current FOV
            %             of your data when calling the Transform function.            
        end

		% spectro begin ----------------------------
        % ---------------------------------------------------------------%
        % Spectroscopy
        % ---------------------------------------------------------------%
		function EddyCurrentCorrection( MR )
			% EddyCurrentCorrection: Applies Klose [see Klose U, MRM 1990;14(1)] eddy current correction to spectroscopy data.
			%
			% Syntax: 	  r.EddyCurrentCorrection;
			%
			% Parameters used:
			% 			  None.
			%
			% Location:   k-space | image-space.
			%
			% Formats: 	  Raw (Spectro)
			%
			% Description/Algorithm:
			% 			  Applies Klose [see Klose U, MRM 1990;14(1)] eddy current correction to spectroscopy data.
			% 			  This is only possible if during the spectroscopy exam the spectral correction parameter
			% 			  was turned on in the Examcards. This leads to an additional data set of unsuppressed water
			% 			  that is saved together with the water suppressed raw data. This signal in mix 2 is
			% 			  then used to revert the time dependent phase distortions that arise due to eddy currents.
			% 			  Additionally to the time dependent phase component also any zero or linear order phase is 
			% 			  removed and no further phase correction to the data is necessary.
		end
		% spectro end ------------------------------
        
        % ---------------------------------------------------------------%
        % Deep Copy of Class
        % ---------------------------------------------------------------%
        function new = Copy(this)
            % Copy: Deep copy of the MRecon class                                    
            %
            % Syntax:     r_new = r.Copy;
            %           
            % Parameters used: None                                    
            %
            % Formats:    All
            %
            % Description/Algorithm: The MRecon class is a handle class which means that assigning it to another
            %             variable is just a pointer operation and does not copy the object.
            %             Therefore the syntax:
            %                                           r_new = r;
            %
            %             does not create a copy of r. Instead r_new does point to the same object
            %             which means that when we change r_new we also change r. To create a deep
            %             copy of our object we have to call the Copy function:
            %
            %                                           r_new = r.Copy;                        
        end    
        
        % ---------------------------------------------------------------%
        % Search for parameter name
        % ---------------------------------------------------------------%
        function Search(this, search_text)    
            % Search: Search for a parameter or a parameter value within the MRecon class                                    
            %
            % Syntax:     r.Search( search_string );
            %           
            % Parameters used: All                                    
            %
            % Formats:    All
            %
            % Description/Algorithm: The search function iterates through all the parameters
            %             and values of the MRecon class and checks if it contains the search string
            %
            % Notes:      For performance reasons the search function does not check values in arrays 
            %             with length > 100000
            %
            % Examples:   To search for the field-of-view (FOV) call:
            %
            %                   >> r.Search('FOV')
            %
            %             which results in:
            %
            %                   Parameter.Scan.FOV = 120 63  240
            %                   Parameter.Scan.curFOV = 240  258   63
            %                   Parameter.Labels.FOV = 240 120 63
            %
            %             In the same way you can also search for values. For example
            %
            %                   >> r.Search('120')
            %
            %             results in:
            %
            %                   Parameter.Scan.FOV = 120 63  240
            %                   Parameter.Labels.FOV = 240 120 63
            %
        end
        
        % ---------------------------------------------------------------%
        % Compare the parameters of 2 objects
        % ---------------------------------------------------------------%
        function Compare(this, other)
            % Compare: Compares to MRecon classes and displays the differences                                    
            %
            % Syntax:     r.Compare( r_other );
            %           
            % Parameters used: All                                    
            %
            % Formats:    All
            %
            % Description/Algorithm: The compare function iterates through all the parameters values 
            %             of the MRecon class and compares them with the values of another reconstruction 
            %             object.
            %            
            % Examples:   To compare the current reconstruction object (r) with another one (r1) call:
            %
            %                   >> r.Compare(r1);                        
        end
    end                
end
