%% Estimate csm from robins data
% Tom Bruijnen - t.bruijnen@umcutrecht.nl
% Version: 20171012
%


clear all;close all;clc
addpath(genpath('/home/tbruijne/Documents/Side_projects/Head_motion_noise_sensor'))
cd('/home/tbruijne/Documents/Side_projects/Head_motion_noise_sensor');

%% 1) Load data and estimate coils maps
clear MR
%loc='/nfs/bsc01/researchData/USER/tbruijne/Research_data/MR21/20171018_MPRage_noise_sensor/Scan3/20171019_173315_s_T1W_3D_TFE.raw';
%loc='/nfs/bsc01/researchData/USER/tbruijne/Research_data/MR21/20171018_MPRage_noise_sensor/Scan1/20171019_171307_t_T2_3D_TSE_FLAIR.raw';
%loc='/nfs/bsc01/researchData/USER/tbruijne/Research_data/MR21/20171018_MPRage_noise_sensor/Scan3/20171019_173315_s_T1W_3D_TFE.raw';
loc='/nfs/bsc01/researchData/USER/tbruijne/Research_data/MR21/20171018_MPRage_noise_sensor/Scan4/20171106_172204_s_T2_3D_TSE_FLAIR.raw';
%loc='/nfs/bsc01/researchData/USER/tbruijne/Research_data/MR21/20171012_NoiseSensor_HeadData/Scan2/20171012_084155_t_T1_3D_TFE_2.raw';
MR=MRecon(loc);
MR.Parameter.Parameter2Read.typ=1;
MR.ReadData;
MR.RandomPhaseCorrection;
MR.RemoveOversampling;
MR.PDACorrection;
MR.DcOffsetCorrection;
MR.MeasPhaseCorrection;
MR.SortData;

%% Create 2D K-spaces 
X=size(MR.Data,2);
Y=size(MR.Data,3);

x=linspace(-.5,.5,1+X);x(end)=[];
y=linspace(-.5,.5,1+Y);y(end)=[];
[KX,KY]=meshgrid(x,y);
k=(KY+1j*KX)';
params.k=reshape(k,numel(k),1);

%% From here on solve per slice (across readout direction)
% Save k-space data and do 1D fft in z
kdata=double(fftshift(ifft(ifftshift(MR.Data,1),[],1),1));
kdata=kdata/max(abs(kdata(:)));
for ro=1:size(kdata,1)
    
% 3) Estimate coil sensitivity maps
data=permute(kdata(ro,:,:,:),[2 3 1 4 ]);

params.N=NUFFT(params.k(:),1,1,[Y/2 X/2],[Y X],2);

% Loop over coils and do fft
data=params.N'*data;%slicer(data)

% Estimate sensitivity maps per slice
[~,precsm(:,:,1,:)]=openadapt(permute(data,[3 1 2 4]));

% Reshape to correct dimensions
csm(:,:,ro,:)=permute(precsm,[2 4 3 1]);

% Display
disp(['ro =',num2str(ro),'/',num2str(size(kdata,1))])

end

%% Save csm
cd('/nfs/bsc01/researchData/USER/tbruijne/Research_data/MR21/20171018_MPRage_noise_sensor/Scan4/')
save('csm.mat','csm','-v7.3')