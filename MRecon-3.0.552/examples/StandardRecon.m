classdef StandardRecon < MRecon
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function MR = StandardRecon( filename )
            if nargin == 0
                filename = '';
            end
            MR = MR@MRecon(filename);
        end
        function Perform( MR )
            switch MR.Parameter.DataFormat
                case{'ExportedRaw', 'Raw', 'Bruker' }
                    
                    %Reconstruct only standard (imaging) data
                    MR.Parameter.Parameter2Read.typ = 1;
                    MR.Parameter.Parameter2Read.Update;
                    
                    % Check if enough memory is available to reconstruct
                    % the whole file at once. Otherwise reconstruct the
                    % data in chunks
                    if strcmpi(MR.Parameter.Recon.AutoChunkHandling, 'yes')
                        [MemoryNeeded, MemoryAvailable, MaxDataSize] = MR.GetMemoryInformation;
                        if MemoryNeeded > MemoryAvailable
                            if strcmpi( MR.Parameter.Recon.ImmediateAveraging, 'yes' ) || strcmpi( MR.Parameter.Recon.Average, 'yes' )
                                MR.Parameter.Chunk.Def = {'kx', 'ky', 'kz', 'chan', 'aver'};
                            else
                                MR.Parameter.Chunk.Def = {'kx', 'ky', 'kz', 'chan'};
                            end
                        end
                    end
                    
                    % Switch off for performance reasons (after recon it is
                    % switched back to original state again)
                    AutoUpdateStatus = MR.Parameter.Recon.AutoUpdateInfoPars;
                    MR.Parameter.Recon.AutoUpdateInfoPars = 'no';
                    
                    % Define new counter
                    counter = Counter( 'Performing Recon --> Chunk %d/%d\n');
                    
                    % Loop over all chunks
                    for cur_loop = 1:MR.Parameter.Chunk.NrLoops
                        
                        % Update Counter
                        if strcmpi( MR.Parameter.Recon.StatusMessage, 'yes')
                            counter.Update( {cur_loop ,MR.Parameter.Chunk.NrLoops} );
                        end
                        
                        % Set the chunk-loop which automatically determines the
                        % image parameter to read for the current chunk
                        MR.Parameter.Chunk.CurLoop = cur_loop;
                        
                        % --------------------------------------------------------
                        % Perform the Reconstruction for the Current Chunk (Start)
                        % --------------------------------------------------------
                        
                        % spectro begin ----------------------------
                        if MR.Parameter.Labels.Spectro
                            MR.ReadData;
                            MR.RandomPhaseCorrection;
                            MR.PDACorrection;
                            MR.DcOffsetCorrection;
                            MR.SortData;
                            MR.Average;
                            MR.RemoveOversampling;
                            MR.RingingFilter;
                            MR.ZeroFill;
                            MR.SENSEUnfold;
                            MR.EddyCurrentCorrection;
                            MR.CombineCoils;
                            MR.GeometryCorrection;
                            MR.K2I;
                            %MR.RotateImage;
                        else
                            % spectro end ------------------------------
                            MR.ReadData;
                            MR.RandomPhaseCorrection;
                            MR.RemoveOversampling;
                            MR.PDACorrection;
                            MR.DcOffsetCorrection;
                            MR.MeasPhaseCorrection;
                            MR.SortData;
                            MR.GridData;
                            MR.RingingFilter;
                            MR.ZeroFill;
                            MR.K2IM;
                            MR.EPIPhaseCorrection;
                            MR.K2IP;
                            MR.GridderNormalization;
                            MR.SENSEUnfold;
                            MR.PartialFourier;
                            MR.ConcomitantFieldCorrection;
                            MR.DivideFlowSegments;
                            MR.CombineCoils;
                            MR.Average;
                            MR.GeometryCorrection;
                            MR.RemoveOversampling;
                            MR.FlowPhaseCorrection;
                            MR.ReconTKE;
                            MR.ZeroFill;
                            MR.RotateImage;
                        end
                        
                        % The current chunk is now reconstructed. If the data is
                        % reconstructed in more than one chunk write the result to
                        % a temporary file on the disk.
                        if MR.Parameter.Chunk.NrLoops > 1
                            [exported_datafile, exported_listfile] = MR.WriteExportedRaw( [MR.Parameter.Filename.Data, '_temp.data'], MR.Parameter.Parameter2Read );
                        end
                        
                        % --------------------------------------------------------
                        % Perform the Reconstruction for the Current Chunk (End)
                        % --------------------------------------------------------
                    end
                    
                    % If data has been written to a temporary file read it
                    % again
                    if MR.Parameter.Chunk.NrLoops > 1
                        r_temp = MRecon(exported_datafile);
                        r_temp.ReadData;
                        r_temp.Parameter.Recon.ImmediateAveraging = 'no';
                        r_temp.SortData;
                        MR.Data = r_temp.Data;
                        fclose all;
                        delete(exported_datafile);
                        delete(exported_listfile);
                        clear r_temp;
                    end
                    if strcmpi( MR.Parameter.Recon.StatusMessage, 'yes')
                        fprintf('\n');
                    end
                    MR.Parameter.Recon.AutoUpdateInfoPars = AutoUpdateStatus;
                    MR.Parameter.Reset;
                case 'ExportedCpx'
                    MR.ReadData;
                    MR.SortData;
                    MR.CombineCoils;
                case 'Cpx'
                    MR.ReadData;
                    MR.CombineCoils;
                case 'Rec'
                    MR.ReadData;
                    MR.RescaleREC;
                    MR.CreateComplexREC;
                otherwise
                    error( 'Error in Perform: Unknown data format' );
            end
        end
    end
end

