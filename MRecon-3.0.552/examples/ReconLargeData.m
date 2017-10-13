classdef ReconLargeData < MRecon
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function MR = ReconLargeData( filename )
            MR = MR@MRecon(filename);
        end
        function Perform( MR ) 
            %Reconstruct only standard (imaging) data
            MR.Parameter.Parameter2Read.typ = 1;
            
            %Switch to chunk reading
            MR.Parameter.Chunk.Def = {'kx', 'ky', 'kz' };                                           
                       
            % Define new counter   
            counter = Counter( 'Performing Recon: Step 1 --> Chunk %d/%d');
            
            % Loop over all chunks
            for cur_loop = 1:MR.Parameter.Chunk.NrLoops             
                
                % Update Counter
                counter.Update( {cur_loop ,MR.Parameter.Chunk.NrLoops} );
                
                MR.Parameter.Chunk.CurLoop = cur_loop;                
                
                % --------------------------------------------------------
                % Perform the Reconstruction for the Current Chunk (Start)
                % --------------------------------------------------------                
                MR.ReadData;
                MR.RemoveOversampling;
                MR.DcOffsetCorrection;
                MR.PDACorrection;
                MR.RandomPhaseCorrection;
                MR.MeasPhaseCorrection;
                MR.SortData;
                MR.PartialFourier;
                MR.GridData;
                MR.ZeroFill;
                MR.K2IM;
                MR.EPIPhaseCorrection;
                MR.K2IP;
                MR.RemoveOversampling;
                MR.CombineCoils;
                MR.ZeroFill;
                MR.RotateImage;
                [exported_datafile, exported_listfile] = MR.WriteExportedRaw( [MR.Parameter.Filename.Data, '_temp.data'], MR.Parameter.Parameter2Read );
                % --------------------------------------------------------
                % Perform the Reconstruction for the Current Chunk (End)
                % --------------------------------------------------------
                
            end
            
           % Define new counter   
           fprintf('\n');
           counter = Counter( 'Performing Recon: Step 2 --> Chunk %d/%d');
                                
           MR = MRecon( exported_datafile );           
           MR.Parameter.Chunk.Def = {'kx', 'ky', 'chan'};            
            
            % Loop over all chunks
            for cur_loop = 1:MR.Parameter.Chunk.NrLoops                
                
                % Update Counter
                counter.Update( {cur_loop ,MR.Parameter.Chunk.NrLoops} );
                
                MR.Parameter.Chunk.CurLoop = cur_loop;
                
                % --------------------------------------------------------
                % Perform the Reconstruction for the Current Chunk (Start)
                % --------------------------------------------------------
                MR.ReadData;
                MR.SortData;      
                MR.Parameter.ReconFlags.isimspace = 1;
                MR.CombineCoils;                        
                [exported_datafile2, exported_listfile2] = MR.WriteExportedRaw( [MR.Parameter.Filename.Data, '_temp2.data'], MR.Parameter.Parameter2Read );
                % --------------------------------------------------------
                % Perform the Reconstruction for the Current Chunk (End)
                % --------------------------------------------------------
                
            end 
            
            r_temp = MRecon(exported_datafile2);
            r_temp.ReadData;
            r_temp.SortData;
            MR.Data = r_temp.Data;
            fclose all;
            delete(exported_datafile);
            delete(exported_listfile);
            delete(exported_datafile2);
            delete(exported_listfile2);
            clear r_temp;
            fprintf('\n');
            MR.Parameter.Reset;
        end
    end
end

