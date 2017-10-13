%% 3D iterative sense reconstruction for Robins data
% Tom Bruijnen - t.bruijnen@umcutrecht.nl
% Version: 20171012
%


clear all;close all;clc
addpath(genpath('/home/tbruijne/Documents/Side_projects/Head_motion_noise_sensor'))
cd('/home/tbruijne/Documents/Side_projects/Head_motion_noise_sensor');

%% 1) Load data and estimate coils maps
clear MR
loc='/nfs/bsc01/researchData/USER/tbruijne/Research_data/MR21/20171012_NoiseSensor_HeadData/Scan1/20171012_083349_t_T1_3D_TFE_1.raw';
%loc='/nfs/bsc01/researchData/USER/tbruijne/Research_data/MR21/20171012_NoiseSensor_HeadData/Scan2/20171012_084155_t_T1_3D_TFE_2.raw';
MR=MRecon(loc);
MR.Parameter.Parameter2Read.typ=1;
MR.ReadData;
MR.RandomPhaseCorrection;
MR.RemoveOversampling;
MR.PDACorrection;
MR.DcOffsetCorrection;
MR.MeasPhaseCorrection;

%% 2) Process Robins logical matrix to create my own mask
% Load the logical exclusion array
% load('corrupted.mat')
% 
% % Transform corrupted list to times NC
% nc=numel(MR.Parameter.Parameter2Read.chan)-1;
% ncorr=zeros(nc*numel(corrupted),1);
% for n=1:numel(corrupted);ncorr(1+(n-1)*nc:(n-1)*nc+nc)=corrupted(n);end
% 
% % TEMP 
% %ncorr=zeros(size(ncorr));
% % TEMP
% 
% % Make all the samples that need to be excluded exactly 1000005
% cords=find(ncorr==1);
% MR.Data(:,cords)=1000005;

MR.SortData;

%% Create 2D K-spaces 
x=linspace(-.5,.5,201);x(end)=[];
y=linspace(-.5,.5,183);y(end)=[];
[KX,KY]=meshgrid(x,y);
k=(KY+1j*KX)';

% Create a k-space mask
mask=ones(200,182);
for x=1:200
    for y=1:182
        if abs(MR.Data(1,x,y,1))>1000000 
            mask(x,y)=0;
        end
    end
end

% Create custom mask
mask(1:40,:)=0;

% Apply k-space mask
k=reshape(k,numel(k),1);
cnt=0;
for n=1:numel(mask)
    if mask(n)==0
        k(n-cnt)=[];
        cnt=cnt+1;
    end
end
params.k=k;      

% Reshape data and remove all entries that are .11578
MR.Data=reshape(MR.Data,[560,200*182*12]);
cords=[];
for n=1:size(MR.Data,2)
    if abs(MR.Data(1,n))>1000000
        cords=[cords n];
    end
end
MR.Data(:,cords)=[];
MR.Data=permute(reshape(MR.Data,560,size(MR.Data,2)/12,12),[1 2 4 3]);

%% From here on solve per slice (across readout direction)
% Save k-space data and do 1D fft in z
kdata=fftshift(ifft(ifftshift(MR.Data,1),[],1),1);

% load csm
load('csm.mat')

% Define fourier operator
params.N=NUFFT(params.k,1,1,[200/2 182/2],[200 182],2);
params.Idim=size(csm(:,:,1,:));
params.Kdim=[numel(params.k) 1 1 12];

for ro=1:size(kdata,1)

% Create coil operator
params.S=S(csm(:,:,ro,:));

% 4) Solve the inverse problem 
ops=optimset('Display','off');
func=@(x,tr) itSense_2D(x,params,tr);
[tmp,~,relres(ro)]=lsqr(func,matrix_to_vec(permute(kdata(ro,:,:,:),[2 3 1 4 ])),1E-08,2);
itSense_img(:,:,ro)=reshape(tmp,[params.Idim(1:2)]);
sos_img(:,:,ro)=sos(params.N'*permute(kdata(ro,:,:,:),[2 3 1 4 ]));
disp(['Recon = ',num2str(ro),'\',num2str(size(kdata,1))])
%imshow3(cat(3,abs(sos_img(:,:,ro)),abs(itSense_img(:,:,ro))),[],[1 2])
end

%% save
save('recons.mat','itSense_img','sos_img','-v7.3')
