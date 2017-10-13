classdef BrukerPars < handle;
    %BrukerPars - Reads parameters from Bruker data.
    % Version by Patrick Wespi including modifications for IDEAL.
    
    properties
        Labels      = [];
        Parameters  = [];
        MethodFile  = [];
        AcqpFile    = [];
        SubjectFile = [];
    end
    
    methods
        function B = BrukerPars
        end
        function CreateLabels( B )
            if isempty( B.MethodFile ) || isempty( B.AcqpFile )
                error( 'Error in BrukerPars: Please fill out the filenames' );
            end
            
            method  = B.read_metafile(B.MethodFile);
            acqp    = B.read_metafile(B.AcqpFile);
            if ~isempty(B.SubjectFile)
                subject = B.read_metafile(B.SubjectFile);
            else
                subject = [];
            end
            
            [B.Labels, B.Parameters] = B.fill_labels( method, acqp, subject);
            
        end
    end
    
    methods (Hidden, Static)
        function [metafile] = read_metafile(data_name)
            % Reads meta files into text variables
            fid = fopen(data_name,'r');
            if (fid==-1)
                error( 'Fehler: fid bei method = -1');
            else
                metafile = fread(fid);
                metafile = char(metafile');
                fclose(fid);
            end
        end
        function [value] = ReadBrukerVar(metafile, variable_name, format)
            %   Reads metafile variable and returns it
            %
            %   INPUT:
            %   metafile: metafile file as string
            %   variable.name: name of metafile variable to be returned
            match = strfind(char(metafile), variable_name);
            file_size = max(size(metafile));
            variable_row = char(metafile(match:file_size));
            x = strtok(variable_row,'##');
            
            if strfind(char(x), '(')
                [~, y] = strtok(x, ')');
                y = strrep(y, ')','');
            else
                [~, y] = strtok(x, '=');
                y = strtok(strrep(y, '=',''));
            end
            
            if strfind(char(y), '<')
                % PW (check for '<par>' versus 'text <par>')
                if y(1)=='<'
                    y = strtok(y, '<');
                else
                    [~, y] = strtok(y, '<');
                end
                % end PW
                y = strrep(y, '>', '');
                y = strrep(y, '<', '');
            end
            
            value = sscanf(y, format);
            
        end
        
        % -----------------------------------------------------------------
        % Fill the labels
        % -----------------------------------------------------------------
        function [Labels, Bruker] = fill_labels( method, acqp, subject)
            % PW **********************************************************
            % List scan techniques where the IDEAL ordering of Index.ky and
            % Index.echo should be used:
              IdealScanTechnique        = {'as_EPI_ideal2','User:pwe_EPI_ideal2','User:lw_EPI_ideal2','User:pwe_EPI_ideal2o','User:pwe_EPI_ideal2o_sp','User:pwe_EPI_merge'};
            % IdealScanTechnique      = 'disable';
            % end PW ******************************************************
            
            % -------------------------------------------------------------
            % Special for Bruker
            % -------------------------------------------------------------            
            Bruker                    = BrukerPars.parse_parameter( strcat(method,acqp,subject) );                               
            Bruker.ParFiles           = strcat(method,acqp,subject);            
            Bruker.OjectOrder         = BrukerPars.ReadBrukerVar(Bruker.ParFiles, '$ACQ_obj_order=', '%f').';
            Bruker.WordType           = BrukerPars.ReadBrukerVar(Bruker.ParFiles, '$GO_raw_data_format=', '%s');
            Bruker.BlockSize          = BrukerPars.ReadBrukerVar(Bruker.ParFiles, '$GO_block_size=', '%s');
            Bruker.EchoPosition       = BrukerPars.ReadBrukerVar(Bruker.ParFiles, '$PVM_EchoPosition=', '%f')/100;
            if isempty(Bruker.EchoPosition)
                Bruker.EchoPosition   = 0.5;
            end
            Bruker.Stacks             = BrukerPars.ReadBrukerVar(Bruker.ParFiles, '$PVM_NSPacks=', '%f');
            Bruker.Slices             = BrukerPars.ReadBrukerVar(Bruker.ParFiles, '$PVM_SPackArrNSlices=', '%f');
            Bruker.EpiBlipBW          = 1000./BrukerPars.ReadBrukerVar(Bruker.ParFiles, '$PVM_EpiEchoSpacing=','%f');
            Bruker.EPIPhaseCorrection = BrukerPars.ReadBrukerVar(Bruker.ParFiles, '$PVM_EpiPhaseCorrection=', '%f');
            % PW **********************************************************
            Bruker.EchoTime1          = BrukerPars.ReadBrukerVar(Bruker.ParFiles, '$EchoTime=', '%f');
            Bruker.EchoTimeIncr       = BrukerPars.ReadBrukerVar(Bruker.ParFiles, '$EchoTimeIncr=', '%f');
            % effective spectral window
            Bruker.EffSWh             = BrukerPars.ReadBrukerVar(Bruker.ParFiles, '$PVM_EffSWh=', '%f');
            % pulse frequency list (SPSP)
            Bruker.PulseFreqList      = BrukerPars.ReadBrukerVar(Bruker.ParFiles, '$PulseFrequencyList=', '%f');
            Bruker.Nucleus            = BrukerPars.ReadBrukerVar(Bruker.ParFiles, '$PVM_Nucleus1Enum=', '%s');
            Bruker.FrqWork            = BrukerPars.ReadBrukerVar(Bruker.ParFiles, '$PVM_FrqWork=', '%f');
            Bruker.FrqWorkPpm         = BrukerPars.ReadBrukerVar(Bruker.ParFiles, '$PVM_FrqWorkPpm=', '%f');
            Bruker.FrqRef             = BrukerPars.ReadBrukerVar(Bruker.ParFiles, '$PVM_FrqRef=', '%f');
            Bruker.AcqTime            = BrukerPars.ReadBrukerVar(Bruker.ParFiles, '$ACQ_time=', '%s');
            Bruker.TR                 = BrukerPars.ReadBrukerVar(Bruker.ParFiles, '$RealRepTimeDelay=', '%f');
            % jst-mod: if TR is empty use TR of
            if isempty(Bruker.TR)
                Bruker.TR                 = BrukerPars.ReadBrukerVar(Bruker.ParFiles,'$ACQ_repetition_time=','%f');
            end
            Bruker.GradOrient         = reshape(BrukerPars.ReadBrukerVar(Bruker.ParFiles, '$PVM_SPackArrGradOrient=', '%f'),3,[]);
            % kt
            ktFlag                    = BrukerPars.ReadBrukerVar(Bruker.ParFiles, '$Kt_YesNo=', '%s');
            Bruker.KtFactor           = round(BrukerPars.ReadBrukerVar(Bruker.ParFiles, '$Kt_Factor=', '%f'));
            Bruker.KtNrTrainProfy     = BrukerPars.ReadBrukerVar(Bruker.ParFiles, '$Kt_NrTrainProfy=', '%f');
            Bruker.KtNrTrainProfz     = BrukerPars.ReadBrukerVar(Bruker.ParFiles, '$Kt_NrTrainProfz=', '%f');
            % kt end
            % end PW ******************************************************
            % -----------------------------------------------------------------------------
            % LW-130913: some info Parameters worth knowing
            % -----------------------------------------------------------------------------
            Bruker.RecGaindB          = BrukerPars.ReadBrukerVar(Bruker.ParFiles,   '$RG=', '%f');
            refpowwatt                = nonzeros( BrukerPars.ReadBrukerVar(Bruker.ParFiles, '$PVM_RefPowCh1=', '%f') );
            if ~isempty(refpowwatt)
                Bruker.RefPowWatt     = refpowwatt;
                Bruker.RefPowdB       = -10*log10(refpowwatt);  % minus sign: Bruker convention (it's an attenuation!)
            else
                Bruker.RefAttdB       = BrukerPars.ReadBrukerVar(Bruker.ParFiles, '$PVM_RefAttCh1=', '%f');
            end
            Bruker.PulsePowWatt       = nonzeros( BrukerPars.ReadBrukerVar(Bruker.ParFiles, '$SPW=', '%f') );
            if isempty(Bruker.EchoTime1)
                Bruker.EchoTime1      = BrukerPars.ReadBrukerVar(Bruker.ParFiles, '$PVM_EchoTime1=', '%f');
            end
            if isempty(Bruker.EchoTime1)
                Bruker.EchoTime1      = BrukerPars.ReadBrukerVar(Bruker.ParFiles, '$PVM_EchoTime=', '%f');
            elseif isempty(Bruker.EchoTimeIncr)
                Bruker.EchoTimeIncr   = BrukerPars.ReadBrukerVar(Bruker.ParFiles, '$PVM_EchoTime=', '%f');
            end
            % -----------------------------------------------------------------------------
            % LW-130913 (end)
            % -----------------------------------------------------------------------------
          
            
            % -------------------------------------------------------------
            % Local variables
            % -------------------------------------------------------------
            acq_mat                   = BrukerPars.ReadBrukerVar(Bruker.ParFiles, '$ACQ_size=', '%f');
            dyn                       = BrukerPars.ReadBrukerVar(Bruker.ParFiles, '$NR=', '%f');
            card                      = BrukerPars.ReadBrukerVar(Bruker.ParFiles, '$PVM_NMovieFrames=', '%f');
            if isempty(card)
                card                  = 1;
            end
            
            % PW **********************************************************
            %echo                     = BrukerPars.ReadBrukerVar(Bruker.ParFiles, '$PVM_NEchoImages=', '%f');
            echo                      = BrukerPars.ReadBrukerVar(Bruker.ParFiles, '$NECHOES=', '%f');
            % end PW ******************************************************
            loca                      = sum(Bruker.Slices);%BrukerPars.ReadBrukerVar(Bruker.ParFiles, '$NI=', '%f');
            chan                      = BrukerPars.ReadBrukerVar(Bruker.ParFiles, '$PVM_EncNReceivers=', '%f');
            if strcmpi(ktFlag,'Yes')
                ky                    = BrukerPars.ReadBrukerVar(Bruker.ParFiles, '$Kt_EncSteps=', '%f');
                Nky                   = size(ky,1)/Bruker.KtFactor;
            else
                ky                    = BrukerPars.ReadBrukerVar(Bruker.ParFiles, '$PVM_EncSteps1=', '%f');
                Nky                   = size(ky,1);
            end
            kz                        = BrukerPars.ReadBrukerVar(Bruker.ParFiles, '$PVM_EncSteps2=', '%f');
            % jst-mod
            jstoffset =0;
            if jstoffset == 1;
                kz                    = 0;
            end
            if isempty(kz)
                kz                    = 1;
            end
            Nkz                       = size(kz,1);

            
            % -------------------------------------------------------------
            %   Labels
            % -------------------------------------------------------------
            Labels.Echo                   = (0:echo-1);
            Labels.Mix                    = zeros(1,echo);
            Labels.ScanMode               =  BrukerPars.ReadBrukerVar(Bruker.ParFiles, '$PVM_SpatDimEnum=', '%s');
            Labels.AcquisitionMode        = 'Cartesian';
            Labels.FastImagingMode        = '';
            Labels.PatientPosition        = BrukerPars.ReadBrukerVar(Bruker.ParFiles, '$SUBJECT_entry=SUBJ_ENTRY_', '%s');
            Labels.PatientOrientation     = BrukerPars.ReadBrukerVar(Bruker.ParFiles, '$SUBJECT_position=SUBJ_POS_', '%s');
            % PW **********************************************************
            Labels.ScanTechnique          = BrukerPars.ReadBrukerVar(Bruker.ParFiles, '$Method=', '%s');
            if any(strcmp(Labels.ScanTechnique,IdealScanTechnique))
                Bruker.BinomRatio     = BrukerPars.ReadBrukerVar(Bruker.ParFiles, '$Binom_ratio=', '%f');
                Bruker.BinomDist     = BrukerPars.ReadBrukerVar(Bruker.ParFiles, '$Binom_dist=', '%f');
            end
            % end PW ******************************************************
            Labels.ZReconLength           = 0; % no idea what that is
            Labels.FlipAngle              = BrukerPars.ReadBrukerVar(acqp, '$ACQ_flip_angle=', '%f');
            Labels.RepetitionTime         = BrukerPars.ReadBrukerVar(Bruker.ParFiles, '$PVM_RepetitionTime=', '%f');
            Labels.Rotate                 = 'None'; %no idea
            Labels.SliceGaps              = BrukerPars.ReadBrukerVar(Bruker.ParFiles, '$PVM_SPackArrSliceGap=', '%f');
            Labels.UTE                    = 'no'; %for once
            Labels.KooshBall              = 'no'; %for once
            Labels.Offcentre              = [BrukerPars.ReadBrukerVar(Bruker.ParFiles, 'PVM_SPackArrReadOffset=', '%f').',...
                BrukerPars.ReadBrukerVar(Bruker.ParFiles, '$PVM_SPackArrPhase1Offset=', '%f').',...
                BrukerPars.ReadBrukerVar(Bruker.ParFiles, '$PVM_SPackArrPhase2Offset=', '%f').'];
            Labels.Angulation             = [0 0 0]; % to be done
            switch Labels.ScanMode
                case '2D'
                    Labels.FOV            = [BrukerPars.ReadBrukerVar(Bruker.ParFiles, '$PVM_Fov=', '%f').',...
                        BrukerPars.ReadBrukerVar(Bruker.ParFiles, '$PVM_SliceThick=', '%f')];
                    
                case '3D'
                    Labels.FOV            = BrukerPars.ReadBrukerVar(Bruker.ParFiles, '$PVM_Fov=', '%f').';
            end
            Labels.Orientation            = BrukerPars.ReadBrukerVar(Bruker.ParFiles, '$PVM_SPackArrSliceOrient=', '%s');
            %defines the readout direction -> Foldover is perpendicular
            Labels.FoldOverDir            = BrukerPars.ReadBrukerVar(Bruker.ParFiles, '$PVM_SPackArrReadOrient=', '%s');
            Labels.FatShiftDir            = ''; %get from FoldOverDir
            Labels.SENSEFactor            = BrukerPars.ReadBrukerVar(Bruker.ParFiles, '$PVM_EncPftAccel1=', '%f');
            Labels.TFEfactor              = 1; %for once
            switch Labels.ScanMode
                case '2D'
                    Labels.VoxelSizes     = [BrukerPars.ReadBrukerVar(Bruker.ParFiles, '$PVM_SpatResol=', '%f').',...
                        BrukerPars.ReadBrukerVar(Bruker.ParFiles, '$PVM_SliceThick=', '%f')];
                    
                case '3D'
                    Labels.VoxelSizes     = BrukerPars.ReadBrukerVar(Bruker.ParFiles, '$PVM_SpatResol=', '%f').';
            end
            
            Labels.NumberOfMixes          = 1; %difference locs/mix needs to clearified...
            Labels.NumberOfEncodingDimensions = size(BrukerPars.ReadBrukerVar(Bruker.ParFiles, '$PVM_Matrix=', '%f'),1);
            
            % PW **********************************************************
            %Labels.NumberOfEchoes        = BrukerPars.ReadBrukerVar(Bruker.ParFiles, '$PVM_NEchoImages', '%f');
            Labels.NumberOfEchoes         = BrukerPars.ReadBrukerVar(Bruker.ParFiles, '$NECHOES=', '%f');
            % end PW ******************************************************
            enc_mat                       = BrukerPars.ReadBrukerVar(Bruker.ParFiles, '$PVM_EncMatrix=', '%f');
            Bruker.EncMatrix              = enc_mat;
            % -----------------------------------------------------------------------------
            % LW-130826: spectro data has data size in SpecMatrix variable
            % -----------------------------------------------------------------------------
            
            %Labels.KxRange               = [-floor(enc_mat(1)*0.5), ceil((enc_mat(1))*(1-0.5))-1];
            Labels.KxRange                = [-floor(enc_mat(1)*Bruker.EchoPosition),...
                ceil((enc_mat(1))*(1-Bruker.EchoPosition))-1];
            Labels.KxRange                = repmat(Labels.KxRange,echo,1);
            if strcmpi(ktFlag,'Yes')
                Labels.KyRange                = [min(BrukerPars.ReadBrukerVar(Bruker.ParFiles, '$Kt_EncSteps=', '%f')),...
                    max(BrukerPars.ReadBrukerVar(Bruker.ParFiles, '$Kt_EncSteps=', '%f'))];
            else
                Labels.KyRange                = [min(BrukerPars.ReadBrukerVar(Bruker.ParFiles, '$PVM_EncSteps1=', '%f')),...
                    max(BrukerPars.ReadBrukerVar(Bruker.ParFiles, '$PVM_EncSteps1=', '%f'))];
            end
            Labels.KyRange                = repmat(Labels.KyRange,echo,1);
            %jst-mod offset correction
            if jstoffset == 1;
                if ~isempty( BrukerPars.ReadBrukerVar(Bruker.ParFiles, '$PVM_EncSteps2=', '%f') )
                    Labels.KzRange            = [min(BrukerPars.ReadBrukerVar(Bruker.ParFiles, '$PVM_EncSteps2=', '%f')),...
                        max(BrukerPars.ReadBrukerVar(Bruker.ParFiles, '$PVM_EncSteps2=', '%f'))];
                    Labels.KzRange            = repmat(Labels.KzRange,echo,1);
                end
            end
            
            tmp                           = BrukerPars.ReadBrukerVar(Bruker.ParFiles, '$PVM_AntiAlias=', '%f');
            Labels.KxOversampleFactor     = tmp(1);
            Labels.KxOversampleFactor     = repmat(Labels.KxOversampleFactor,echo,1);
            Labels.KyOversampleFactor     = tmp(2);
            Labels.KyOversampleFactor     = repmat(Labels.KyOversampleFactor,echo,1);
            if size(tmp) > 2
                Labels.KzOversampleFactor = tmp(3);
                Labels.KzOversampleFactor = repmat(Labels.KzOversampleFactor,echo,1);
            end
            
            clear tmp;
            rec_mat                       = BrukerPars.ReadBrukerVar(Bruker.ParFiles, '$PVM_Matrix=', '%f');
            %             tmp                           = abs(Labels.KxRange)+repmat([0 1],echo,1);
            %             Labels.XResolution            = max(tmp(:))*2;
            %             if rec_mat(1) > Labels.XResolution
            %                 Labels.XResolution        = rec_mat(1);
            %             end
            Labels.XResolution            = rec_mat(1);
            Labels.YResolution            = rec_mat(2);
            Labels.XRange                 = [-floor(Labels.XResolution/2), ceil((Labels.XResolution)/2)-1];
            Labels.XRange                 = repmat(Labels.XRange,echo,1);
            Labels.YRange                 = [-floor(rec_mat(2)/2), ceil((rec_mat(2))/2)-1];
            if(Labels.YRange(2) < Labels.KyRange(2))
                Labels.YRange(2)          = Labels.KyRange(2);
                Labels.YResolution        = abs(Labels.YRange(1))+abs(Labels.YRange(1))+1;
            end
            Labels.YRange                 = repmat(Labels.YRange,echo,1);
            if size(rec_mat) > 2
                Labels.ZResolution        = rec_mat(3);
                Labels.ZRange             = [-floor(rec_mat(3)/2), ceil((rec_mat(3))/2)-1];
                Labels.ZRange             = repmat(Labels.ZRange,echo,1);
            end
            switch Bruker.WordType
                case 'GO_32BIT_FLOAT'
                    sample_size_byte = 4;
                case 'GO_16BIT_SGN_INT'
                    sample_size_byte = 2;
                case 'GO_32BIT_SGN_INT'
                    sample_size_byte = 4;
                otherwise
                    sample_size_byte = 4;
            end
            switch Bruker.BlockSize
                case 'Standard_KBlock_Format'
                    block_size = 1024;
                    if mod(acq_mat(1),(block_size/sample_size_byte))
                        zfill = (block_size/sample_size_byte)-mod(acq_mat(1),(block_size/sample_size_byte));
                    else
                        zfill=0;
                    end
                    
                case 'continuous'
                    zfill = 0;
                    
            end
            
            
            %Labels.KxRange = [-floor((enc_mat(1)+zfill)/2), ceil((enc_mat(1)+zfill)/2)-1];
            
            % -------------------------------------------------------------
            % Labels.Index
            % -------------------------------------------------------------
            if strcmp(Labels.ScanTechnique,'Bruker:FLOWMAP') ||  strcmp(Labels.ScanTechnique,'User:jonassteFLOWMAP')
                FlowEncGradMatrix        = BrukerPars.ReadBrukerVar(Bruker.ParFiles, '$FlowEncLoop=', '%f');
                extr1 = sum(FlowEncGradMatrix~=0);
%                 MR.Parameter.Scan.Venc = MR.Parameter.Bruker.FlowRange; 
%                 MR.Parameter.Recon.CoilCombination = 'pc';
            else
                extr1 = 1;
            end
            
            
            
            % Bruker loop structur (inner to outer): [chan]; [echo];
            % [loca,card]; [NA]( averraged on spectrometer); [ky]; [kz]; [NAE](averaged on spectrometer); [dyn(NR)]
            NumProf = chan*echo*loca*card*Nky*Nkz*dyn*extr1;
            Labels.Index.typ = uint8(ones(NumProf,1)); % may be changed for self gated data
            Labels.Index.mix = uint16(zeros(NumProf,1)); % for once, no idea about different mixes with bruker
            
            for i = 1:dyn
                Labels.Index.dyn((i-1)*Nky*Nkz*chan*echo*loca*card*extr1+1:(i)*Nky*Nkz*chan*echo*loca*card*extr1,1) = uint16(i-1);
            end
            
            for i = 1:card
                Labels.Index.card((i-1)*chan*echo*loca+1:(i)*chan*echo*loca,1) = uint16(i-1);
            end
            Labels.Index.card = repmat(Labels.Index.card,Nky*Nkz*dyn*extr1,1);
            
            % PW **********************************************************
            % Index.echo
            if any(strcmp(Labels.ScanTechnique,IdealScanTechnique))
                for i = 1:echo
                    Labels.Index.echo((i-1)*loca*chan*Nky*extr1+1:(i)*loca*chan*Nky*extr1,1) = uint16(i-1);
                end
                Labels.Index.echo = repmat(Labels.Index.echo,card*Nkz*dyn,1);
            else
                for i = 1:echo
                    Labels.Index.echo((i-1)*loca*chan*extr1+1:(i)*loca*chan*extr1,1) = uint16(i-1);
                end
                Labels.Index.echo = repmat(Labels.Index.echo,card*Nky*Nkz*dyn,1);
            end
            % end PW ******************************************************
            
            % pw-mod-20150116; inverted 20150421
            for i = 1:loca
                Labels.Index.loca((i-1)*chan*echo*extr1+1:(i)*chan*echo*extr1,1) = uint16(Bruker.OjectOrder(i));
            end
            Labels.Index.loca = repmat(Labels.Index.loca,card*Nky*Nkz*dyn,1);
%             for i = 1:loca
%                 Labels.Index.loca((i-1)*chan*Nky*Nkz+1:(i)*chan*Nky*Nkz,1) = uint16(i);
%             end
%             Labels.Index.loca = repmat(Labels.Index.loca,card*dyn*echo,1);
            % pw-mod-end
            
            % -----------------------------------------------------------------------------------------------
            % LW-mod-130917 (begin): multi coil Bruker EPIideal data (add "if" part)
            % -----------------------------------------------------------------------------------------------
            if any(strcmp(Labels.ScanTechnique,IdealScanTechnique)) && chan>1 %multicoil EPIideal data
                for i = 1:chan
                    Labels.Index.chan((i-1)*Nky*extr1+1:(i)*Nky*extr1,1) = uint16((i-1).*ones(Nky,1));
                end
                Labels.Index.chan          = repmat(Labels.Index.chan,echo*loca*card*Nkz*dyn,1);
            else %single coil EPIideal data and all other data types (maybe not true for EPI?)
                for i = 1:chan
                    Labels.Index.chan((i-1)+1:(i),1) = uint16(i-1);
                end
                Labels.Index.chan          = repmat(Labels.Index.chan,echo*loca*card*Nky*Nkz*dyn*extr1,1);
            end
            % -----------------------------------------------------------------------------------------------
            % LW-mod-130917 (end)
            % -----------------------------------------------------------------------------------------------
            
            % Labels.Index.extr1         = uint16(zeros(NumProf,1));
            for i=1:extr1
                Labels.Index.extr1((i-1)*card*chan+1:(i)*card*chan,1)   = uint16((i-1));
            end
            Labels.Index.extr1 = repmat(Labels.Index.extr1,echo*loca*Nky*Nkz*dyn,1);
            
            Labels.Index.extr2         = uint16(zeros(NumProf,1));
            
            % Index.ky % pw-mod-20150116: move loca
            if any(strcmp(Labels.ScanTechnique,IdealScanTechnique))
                % -----------------------------------------------------------------------------------------------
                % LW-mod-130917 (begin): multi coil Bruker EPIideal data  (add "if" part)
                % -----------------------------------------------------------------------------------------------
                % pw-mod: kt: different ky for each dynamic
                if strcmpi(ktFlag,'Yes')
                    for kt = 1:Bruker.KtFactor
                        clear ky_tmp;
                        for i = 1:Nky
                            ky_tmp((i-1)*card+1:(i)*card,1) = int16(ky((kt-1)*Nky+i));
                        end
                        ky_tmp = repmat(ky_tmp,chan*echo*Nkz*loca*extr1,1);
                        n_tmp = length(ky_tmp);
                        Labels.Index.ky((kt-1)*n_tmp+1:kt*n_tmp,1) = ky_tmp;
                    end
                    Labels.Index.ky = repmat(Labels.Index.ky,dyn/Bruker.KtFactor,1);
                else
                    if chan > 1
                        for i = 1:Nky
                            Labels.Index.ky((i-1)*card+1:(i)*card,1) = int16(ky(i));
                        end
                        Labels.Index.ky = repmat(Labels.Index.ky,chan*dyn*echo*Nkz*loca*extr1,1);
                    else
                        for i = 1:Nky
                            Labels.Index.ky((i-1)*chan*card+1:(i)*chan*card,1) = int16(ky(i));
                        end
                        Labels.Index.ky = repmat(Labels.Index.ky,dyn*echo*Nkz*loca*extr1,1);
                    end
                end
                % -----------------------------------------------------------------------------------------------
                % LW-mod-130917 (end)
                % -----------------------------------------------------------------------------------------------
            else
                for i = 1:Nky
                    Labels.Index.ky((i-1)*chan*echo*card*loca*extr1+1:(i)*chan*echo*card*loca*extr1,1) = int16(ky(i));
                end
                Labels.Index.ky = repmat(Labels.Index.ky,dyn*Nkz,1);
            end
            % end PW ******************************************************
            
            if Nkz > 1
                for i = 1:Nkz
                    Labels.Index.kz((i-1)*Nky*chan*echo*card*extr1+1:(i)*enc_mat(2)*chan*echo*card*extr1,1) = int16(kz(i));
                end
                Labels.Index.kz = repmat(Labels.Index.kz,dyn*loca,1);
            else
                Labels.Index.kz = int16(zeros(NumProf,1));
            end
            
            Labels.Index.na            = uint16(zeros(NumProf,1));
            Labels.Index.aver          = uint16(zeros(NumProf,1));
            Labels.Index.sign          = int8(ones(NumProf,1));
            if ~isempty(Bruker.EpiBlipBW) % pw.mod-20150119
                if strcmpi(ktFlag,'Yes') % kt EPI
                    tmp = int8(ones(Nky,1));
                    tmp(1:2:end) = -1;
                    tmp = repmat(tmp,[NumProf/Nky 1]);
                    Labels.Index.sign = tmp;
                    Labels.FastImagingMode = 'EPI';
                else % normal EPI
                    Labels.Index.sign(find(mod(Labels.Index.ky(:)+1,2)))=-1;
                    Labels.FastImagingMode = 'EPI';
                end
            end
            Labels.Index.rf            = uint16(zeros(NumProf,1));
            Labels.Index.grad          = uint16(zeros(NumProf,1));
            Labels.Index.enc           = uint16(zeros(NumProf,1));
            % to be filled for cardiac triggering
            Labels.Index.rtop          = uint16(zeros(NumProf,1));
            Labels.Index.rr            = uint16(zeros(NumProf,1));
            %
            
            Labels.Index.size          = uint64(repmat(enc_mat(1)*2*sample_size_byte,NumProf,1));
            % -----------------------------------------------------------------------------------------------
            % LW-mod-130826 (begin): handle multi coil Bruker data
            % -----------------------------------------------------------------------------------------------
            if chan==1 || strcmpi( Bruker.BlockSize, 'continuous') % single coil or continuous multicoil raw data
                Labels.Index.offset        = uint64( 0:double(Labels.Index.size(1))+(zfill*sample_size_byte):...
                    (double(Labels.Index.size(1))+(zfill*sample_size_byte))*...
                    NumProf-double(Labels.Index.size(1))).';
            else
                % standard multicoil raw data (stored in blocks)
                % Bruker stores all coil fids sequentially in 1 block and increases block size if necessary.
                % E.g. for 4 coils and data size per coil = 384, eff. size = 4*384=1536 => zero-filling to 2*block_size if
                % block_size = 1024;
                eff_block_size = ceil(chan*double(Labels.Index.size(1))/block_size)*block_size;
                Labels.Index.offset = zeros(length(Labels.Index.size), 1);
                for k=0:length(Labels.Index.size)-1
                    if rem(k,chan) == 0
                        Labels.Index.offset(k+1) = k/chan*eff_block_size;
                    else
                        Labels.Index.offset(k+1) = Labels.Index.offset(k)+Labels.Index.size(k+1);
                    end
                end
            end
            % -----------------------------------------------------------------------------------------------
            % LW-mod-130826 (end): handle multi coil Bruker data
            % -----------------------------------------------------------------------------------------------
            
            % -----------------------------------------------------------------------------------------------
            % LW-2013-09-18 (begin): for EPIideal
            % Read last dynamic twice, as normal data (typ=1) and noise data (typ=5) for Noise Psi determination
            % -----------------------------------------------------------------------------------------------
            if any(strcmp(Labels.ScanTechnique,IdealScanTechnique))
                NumProf1 = NumProf;                                                 % store actual NumProf
                NumProf  = NumProf + chan*echo*loca*card*Nky*Nkz;                   % update NumProf to +1 dynamic
                Labels.Index.typ   (NumProf-chan*echo*loca*card*Nky*Nkz+1:NumProf) = uint8(5);    % noise data type
                Labels.Index.mix   (NumProf-chan*echo*loca*card*Nky*Nkz+1:NumProf) = Labels.Index.mix(NumProf1-chan*echo*loca*card*Nky*Nkz+1:NumProf1);
                Labels.Index.dyn   (NumProf-chan*echo*loca*card*Nky*Nkz+1:NumProf) = Labels.Index.dyn(NumProf1-chan*echo*loca*card*Nky*Nkz+1:NumProf1);
                Labels.Index.card  (NumProf-chan*echo*loca*card*Nky*Nkz+1:NumProf) = Labels.Index.card(NumProf1-chan*echo*loca*card*Nky*Nkz+1:NumProf1);
                Labels.Index.echo  (NumProf-chan*echo*loca*card*Nky*Nkz+1:NumProf) = Labels.Index.echo(NumProf1-chan*echo*loca*card*Nky*Nkz+1:NumProf1);
                Labels.Index.loca  (NumProf-chan*echo*loca*card*Nky*Nkz+1:NumProf) = Labels.Index.loca(NumProf1-chan*echo*loca*card*Nky*Nkz+1:NumProf1);
                Labels.Index.chan  (NumProf-chan*echo*loca*card*Nky*Nkz+1:NumProf) = Labels.Index.chan(NumProf1-chan*echo*loca*card*Nky*Nkz+1:NumProf1);
                Labels.Index.extr1 (NumProf-chan*echo*loca*card*Nky*Nkz+1:NumProf) = Labels.Index.extr1(NumProf1-chan*echo*loca*card*Nky*Nkz+1:NumProf1);
                Labels.Index.extr2 (NumProf-chan*echo*loca*card*Nky*Nkz+1:NumProf) = Labels.Index.extr2(NumProf1-chan*echo*loca*card*Nky*Nkz+1:NumProf1);
                Labels.Index.ky    (NumProf-chan*echo*loca*card*Nky*Nkz+1:NumProf) = Labels.Index.ky(NumProf1-chan*echo*loca*card*Nky*Nkz+1:NumProf1);
                Labels.Index.kz    (NumProf-chan*echo*loca*card*Nky*Nkz+1:NumProf) = Labels.Index.kz(NumProf1-chan*echo*loca*card*Nky*Nkz+1:NumProf1);
                Labels.Index.na    (NumProf-chan*echo*loca*card*Nky*Nkz+1:NumProf) = Labels.Index.na(NumProf1-chan*echo*loca*card*Nky*Nkz+1:NumProf1);
                Labels.Index.aver  (NumProf-chan*echo*loca*card*Nky*Nkz+1:NumProf) = Labels.Index.aver(NumProf1-chan*echo*loca*card*Nky*Nkz+1:NumProf1);
                Labels.Index.sign  (NumProf-chan*echo*loca*card*Nky*Nkz+1:NumProf) = Labels.Index.sign(NumProf1-chan*echo*loca*card*Nky*Nkz+1:NumProf1);
                Labels.Index.rf    (NumProf-chan*echo*loca*card*Nky*Nkz+1:NumProf) = Labels.Index.rf(NumProf1-chan*echo*loca*card*Nky*Nkz+1:NumProf1);
                Labels.Index.grad  (NumProf-chan*echo*loca*card*Nky*Nkz+1:NumProf) = Labels.Index.grad(NumProf1-chan*echo*loca*card*Nky*Nkz+1:NumProf1);
                Labels.Index.enc   (NumProf-chan*echo*loca*card*Nky*Nkz+1:NumProf) = Labels.Index.enc(NumProf1-chan*echo*loca*card*Nky*Nkz+1:NumProf1);
                Labels.Index.rtop  (NumProf-chan*echo*loca*card*Nky*Nkz+1:NumProf) = Labels.Index.rtop(NumProf1-chan*echo*loca*card*Nky*Nkz+1:NumProf1);
                Labels.Index.rr    (NumProf-chan*echo*loca*card*Nky*Nkz+1:NumProf) = Labels.Index.rr(NumProf1-chan*echo*loca*card*Nky*Nkz+1:NumProf1);
                Labels.Index.size  (NumProf-chan*echo*loca*card*Nky*Nkz+1:NumProf) = Labels.Index.size(NumProf1-chan*echo*loca*card*Nky*Nkz+1:NumProf1);
                Labels.Index.offset(NumProf-chan*echo*loca*card*Nky*Nkz+1:NumProf) = Labels.Index.offset(NumProf1-chan*echo*loca*card*Nky*Nkz+1:NumProf1);
            end
            % -----------------------------------------------------------------------------------------------
            % LW-2013-09-18 (end)
            % -----------------------------------------------------------------------------------------------
            
            % not used for Bruker
            Labels.Index.random_phase  = uint16(zeros(NumProf,1));
            Labels.Index.meas_phase    = uint16(zeros(NumProf,1));
            Labels.Index.pda_index     = uint16(zeros(NumProf,1));
            Labels.Index.pda_fac       = double(zeros(NumProf,1));
            
            %to be filled
            Labels.Index.dyn_time      = uint32(zeros(NumProf,1));
            
            % not used for Bruker
            Labels.Index.coded_size    = Labels.Index.size;
            Labels.Index.chan_grp      = uint32(zeros(NumProf,1));
            Labels.Index.format        = uint8(zeros(NumProf,1));
            
            %to be filled
            Labels.Index.ky_label      = int16(zeros(NumProf,1));
            Labels.Index.kz_label      = int16(zeros(NumProf,1));
            
            Bruker = rmfield(Bruker, 'ParFiles');  
        end % fill_labels
        
        function par_struct = parse_parameter( par_text )
            par_struct = struct;
            
            parameter_start_pos = strfind(par_text, '##');
            carriage_return = strfind(par_text, sprintf('\n'));
            dollar_start_pos = strfind(par_text, '$$');
            
            for i = 1:length(parameter_start_pos)
                parameter_group = [];
                parameter_name = [];
                parameter_value = [];
                
                regular_parameter = false;
                cur_start_pos = parameter_start_pos(i);
                % find the next carriage_return
                d_pos = carriage_return-cur_start_pos;
                d_pos( d_pos < 0 ) = inf;
                [mi, cur_carriage_ind] = min( d_pos );
                cur_carriage_return = carriage_return(cur_carriage_ind);
                cur_line = par_text( cur_start_pos:cur_carriage_return-1 );
                
                if isempty(cur_line) 
                    continue;
                end
                
                if( cur_line(3) == '$' )
                    regular_parameter = true;
                end
                
                equals = strfind( cur_line, '=' );
                if isempty( equals )
                    continue;
                end              
                if( regular_parameter )                    
                    underscores = strfind( cur_line, '_' );
                    if ~isempty( underscores ) && underscores(1) < equals(1) 
                        parameter_group = cur_line(4:underscores(1)-1);       
                        if( strcmp( upper(parameter_group), parameter_group) == 0 )
                            parameter_group = [];
                        end
                        parameter_name = cur_line(underscores(1)+1:equals(1)-1);
                    else
                        parameter_group = [];                                                
                        parameter_name = cur_line(4:equals(1)-1);
                    end
                else                                        
                    parameter_name = cur_line(3:equals(1)-1);
                end
                parameter_value = cur_line( equals(1)+1:end );
                
                if isempty( parameter_value )
                    continue;
                end
                
                % check if value is numeric
                if ~isnan( str2double(parameter_value) )
                    parameter_value = str2double(parameter_value);
                end
                
                % check if parameter is an array
                if parameter_value(1) == '('
                    is_array_length = false;
                    
                    % check if the value in the brackets specify the array size
                    if length(parameter_value) > 4 && isspace(parameter_value(2)) && isspace(parameter_value(end-1)) && parameter_value(end) == ')'
                        nr_elements = str2double( parameter_value(2:end-1) );
                        is_array_length = true;
                    end
                    
                    start_pos = cur_start_pos+equals(1)+1;
                    
                    if is_array_length
                        start_pos = cur_carriage_return+1;
                    end
                    d_pos = parameter_start_pos-cur_start_pos;
                    d_pos( d_pos <= 0 ) = inf;
                    [mi1, ind1] = min( d_pos );
                    d_pos = dollar_start_pos-cur_start_pos;
                    d_pos( d_pos <= 0 ) = inf;
                    [mi2, ind2] = min( d_pos );
                    if mi1 < mi2
                        end_pos = parameter_start_pos(ind1)-1;
                    else
                        end_pos = dollar_start_pos(ind2)-1;
                    end
                                                            
                    parameter_value = par_text(start_pos:end_pos);
                    parameter_value = strrep( parameter_value, ')', '');
                    parameter_value = strrep( parameter_value, '(', '');
                    parameter_value = strrep( parameter_value, sprintf('\n'), '');                    
                    if ~isempty( str2num( parameter_value ) )
                        parameter_value = str2num( parameter_value );
                    end                    
                end
                
                if isstr( parameter_value) 
                    parameter_value = strrep( parameter_value, '<', '');
                    parameter_value = strrep( parameter_value, '>', '');
                end
                

                
                if ~isempty( parameter_group ) && ~isfield(par_struct, parameter_group )
                    par_struct.(parameter_group) = struct;
                end
                
                if ~isempty( parameter_group )
                    par_struct.(parameter_group).(parameter_name) = parameter_value;
                else
                    par_struct.(parameter_name) = parameter_value;
                end                                
            end
            
            par_struct = orderfields(par_struct);
            fn = fieldnames(par_struct);
            for i = 1:length(fn)
                if isstruct( par_struct.(fn{i}) )
                    par_struct.(fn{i}) = orderfields(par_struct.(fn{i}));
                end
            end
        end
    end % methods (Hidden, Static)
    
end % classdef BrukerPars < handle

