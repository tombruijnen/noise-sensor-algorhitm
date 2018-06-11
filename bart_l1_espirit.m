%% 3D iterative sense reconstruction for Robins data
% Tom Bruijnen - t.bruijnen@umcutrecht.nl
% Version: 20171012

clear all;close all;clc
datapath1='/local_scratch2/tbruijne/NOISE_SENSOR_RECONSTRUCTIONS/rn_02052018_1705320_4_2_wip_t_t1_3d_tfe_motionV4.raw'; % Motion-corrupted
datapath2='/local_scratch2/tbruijne/NOISE_SENSOR_RECONSTRUCTIONS/rn_02052018_1656495_2_2_wip_t_t1_3d_tfeV4.raw'; % Motion-free
noisepath='/local_scratch2/tbruijne/NOISE_SENSOR_RECONSTRUCTIONS/rn_02052018_1705320_4_2_wip_t_t1_3d_tfe_motionV4_corrupt.mat'; 
cd('/nfs/rtsan02/userdata/home/tbruijne/Documents/Main_Recon_Library/')
setup;

% Save data or not 
savedata=0;

%% 1) Load data and estimate coils maps
% Motion-free for csm estimation
clear MR
MR=MRecon(datapath2);
MR.Parameter.Parameter2Read.typ=1;
MR.ReadData;
MR.RandomPhaseCorrection;
MR.RemoveOversampling;
MR.PDACorrection;
MR.DcOffsetCorrection;
MR.MeasPhaseCorrection;
MR.SortData;
%MR.RemoveOversampling;
MR.RingingFilter;

% Motion_corrupted
MR2=MRecon(datapath1);
MR2.Parameter.Parameter2Read.typ=1;
MR2.ReadData;
MR2.RandomPhaseCorrection;
MR2.RemoveOversampling;
MR2.PDACorrection;
MR2.DcOffsetCorrection;
MR2.MeasPhaseCorrection;

%% 2) Process Robins logical matrix to create my own mask
%Load the logical exclusion array
load(noisepath)

% Transform corrupted list to times NC
nc=numel(MR2.Parameter.Parameter2Read.chan)-1;
ncorr=zeros(nc*numel(corrup),1);
for n=1:numel(corrup);ncorr(1+(n-1)*nc:(n-1)*nc+nc)=corrup(n);end

% Make all the samples that need to be excluded exactly 1000005
cords=find(ncorr==1);
MR2.Data(:,cords)=1000005;

MR2.SortData;
r=size(MR2.Data,1);
X=size(MR2.Data,2);
Y=size(MR2.Data,3);
nc=size(MR2.Data,4);

% Create mask
x=linspace(-.5,.5,1+X);x(end)=[];
y=linspace(-.5,.5,1+Y);y(end)=[];
[KX,KY]=meshgrid(x,y);
k=(KY+1j*KX)';

% Create a k-space mask
mask=ones(X,Y);
for x=1:X
    for y=1:Y
        if abs(MR2.Data(1,x,y,1))>1000000 
            mask(x,y)=0;
        end
    end
end

% Apply mask to data
mot
MR2.Data=bsxfun(@times,MR2.Data,permute(mask,[3 1 2]));
%MR2.RemoveOversampling;
MR2.RingingFilter;

%% 3) BART reconstruction
% Save k-space data and do 1D fft in z
kdata_mf=fftshift(ifft(ifftshift(MR.Data,1),[],1),1);
kdata_mc=fftshift(ifft(ifftshift(MR2.Data,1),[],1),1);
par.wavelet=0.5;
par.mask=single(mask);
par.Niter=30;

for z=1:size(kdata_mc,1)
    par.kspace_data=permute(kdata_mc(z,:,:,:,:),[2 3 1 4]);
    kspace_data_mf=permute(kdata_mf(z,:,:,:,:),[2 3 1 4]);
    
    % Modulate data with k-space ramp
    kspace_data_mf=ifft2(fftshift(fftshift(fft2(kspace_data_mf),1),2));
    par.kspace_data=ifft2(fftshift(fftshift(fft2(par.kspace_data),1),2));
    kdim=c12d(size(par.kspace_data));

    mf=bart('fft -i 3 ',kspace_data_mf);
    mc=bart('fft -i 3 ',par.kspace_data);
    %par.csm=openadapt(lowres);
    par.csm=espirit(mf,'bart');
    
    % Iterative reconstructions
    %recon_rss(:,:,z)=bart('rss 8',mc);
    B1=SS(par.csm);
    recon_b1(:,:,z)=abs(B1*mc);
    cs(:,:,z)=abs(squeeze(configure_compressed_sense(par,'bart')));   
    %close all;imshow3(rot90(cat(3,demax(recon_rss(:,:,z)),demax(recon_b1(:,:,z)),demax(cs(:,:,z))),3),[],[1 3])
    
    disp(['>>>>>>>>>>>>>>>>>> Slice: ',num2str(z),'<<<<<<<<<<<<<<<<<<'])
end

MR2.Data=recon_b1;MR.Data=cs;
MR.Parameter.ReconFlags.isimspace=[1 1 1];MR2.Parameter.ReconFlags.isimspace=[1 1 1];
MR.GeometryCorrection;MR2.GeometryCorrection;

%% save motion-compensated recon
recon_sos_motion_excluded=rot90(flip(permute(demax(MR2.Data),[1 3 2]),3),3);slicer(recon_sos_motion_excluded)
recon_L1_espirit_motion_excluded=rot90(flip(permute(demax(MR.Data),[1 3 2]),3),3);slicer(recon_L1_espirit_motion_excluded)

save([get_data_dir(datapath1),'recons.mat'],'recon_sos_motion_excluded','recon_L1_espirit_motion_excluded','-v7.3')

%% Normal reconstruction
clear MR MR2
MR=MRecon(datapath1);
MR.Parameter.Parameter2Read.typ=1;
MR.ReadData;
MR.RandomPhaseCorrection;
MR.RemoveOversampling;
MR.PDACorrection;
MR.DcOffsetCorrection;
MR.MeasPhaseCorrection;
MR.SortData;
MR.RingingFilter;
kdata=fftshift(ifft(ifftshift(MR.Data,1),[],1),1);

for z=1:size(kdata,1)
    kdata_z=permute(kdata(z,:,:,:,:),[2 3 1 4]);
    
    % Modulate data with k-space ramp
    kdata_z=ifft2(fftshift(fftshift(fft2(kdata_z),1),2));
    recon_sos_motion_corrupted(:,:,z)=bart('rss 8',abs(bart('fft -i 3 ',kdata_z)));
    
    disp(['>>>>>>>>>>>>>>>>>> Slice: ',num2str(z),'<<<<<<<<<<<<<<<<<<'])
end

MR.Data=recon_sos_motion_corrupted;
MR.Parameter.ReconFlags.isimspace=[1 1 1];
MR.GeometryCorrection;

recon_sos_motion_corrupted=rot90(flip(permute(demax(MR.Data),[1 3 2]),3),3);
save([get_data_dir(datapath1),'recons.mat'],'recon_sos_motion_corrupted','-append','-v7.3')
