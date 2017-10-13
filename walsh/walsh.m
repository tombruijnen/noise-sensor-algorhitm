function walsh(MR)
%Routine to use Walsh et al. his method to compute the coil sensitivity
% maps for 2D/3D scans. This is by far the fastest way to generate the coil
% maps. 
%
% 20170717 - T.Bruijnen

%% Logic
if ~strcmpi(MR.UMCParameters.AdjointReconstruction.CoilSensitivityMaps,'walsh') 
    return;end

%% walsh
% Check whether its multi 2D or 3D data
if (strcmpi(MR.Parameter.Scan.ScanMode,'2D')) || (strcmpi(MR.UMCParameters.AdjointReconstruction.NufftType,'2D') && strcmpi(MR.Parameter.Scan.AcqMode,'Radial'))
    
    % Track progress
    parfor_progress(MR.UMCParameters.AdjointReconstruction.KspaceSize{1}(3)*MR.Parameter.Encoding.NrEchoes);

    % (m)2D cases
    for n=1:numel(MR.Data)
        for ech=1:MR.UMCParameters.AdjointReconstruction.KspaceSize{n}(7)
            for z=1:MR.UMCParameters.AdjointReconstruction.KspaceSize{n}(3)
                
                % Estimate csm
                [~,MR.Parameter.Recon.Sensitivities{n}(:,:,:,z,:,:,ech)]=openadapt(permute(MR.Data{n}(:,:,z,:,:,:,ech),[4 1 2 3 5 6 7]));
                
                % Track progress
                parfor_progress;
                
            end
        end
    end
    
    % Reset parfor
    parfor_progress(0);
    
elseif strcmpi(MR.Parameter.Scan.ScanMode,'3D')
    
    % 3D case    
    for n=1:numel(MR.Data)
        for ech=1:MR.UMCParameters.AdjointReconstruction.KspaceSize{eco}(7)
            % Estimate csm
            [~,MR.Parameter.Recon.Sensitivities{n}(:,:,:,:,:,:,ech)]=openadapt(permute(MR.Data{n}(:,:,:,:,:,:,ech),[4 1 2 3 5 6 7]));

            % Track progress
            parfor_progress;               
        end
    end            
end

% Reshape to [x,y,z,coil] dimension
for n=1:numel(MR.Data);MR.Parameter.Recon.Sensitivities{n}=permute(MR.Parameter.Recon.Sensitivities{n},[2 3 4 1 5 6 7]);end

% END
end