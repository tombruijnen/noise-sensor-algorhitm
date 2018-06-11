%% 3D iterative sense reconstruction for Robins data
% Tom Bruijnen - t.bruijnen@umcutrecht.nl
% Version: 20171012
%


clear all;close all;clc
addpath(genpath('/home/tbruijne/Documents/Side_projects/Head_motion_noise_sensor'))
cd('/home/tbruijne/Documents/Side_projects/Head_motion_noise_sensor');

%% 1) Load data and estimate coils maps
clear MR
%loc='/nfs/bsc01/researchData/USER/tbruijne/Research_data/MR21/20171012_NoiseSensor_HeadData/Scan1/20171012_083349_t_T1_3D_TFE_1.raw';
loc='/nfs/bsc01/researchData/USER/tbruijne/Research_data/MR21/20171018_MPRage_noise_sensor/Scan2/20171019_172810_s_T1W_3D_TFE.raw';
loc2='/nfs/bsc01/researchData/USER/tbruijne/Research_data/MR21/20171018_MPRage_noise_sensor/Scan2/';
MR=MRecon(loc);
MR.Parameter.Parameter2Read.typ=1;
MR.ReadData;
MR.RandomPhaseCorrection;
MR.RemoveOversampling;
MR.PDACorrection;
MR.DcOffsetCorrection;
MR.MeasPhaseCorrection;


%% 2) Process Robins logical matrix to create my own mask
% cgsense
cgsense_bool=0;

%Load the logical exclusion array
cd(loc2)
load('corrupted.mat')
cd('/home/tbruijne/Documents/Side_projects/Head_motion_noise_sensor');

% Transform corrupted list to times NC
nc=numel(MR.Parameter.Parameter2Read.chan)-1;
ncorr=zeros(nc*numel(corrupted),1);
for n=1:numel(corrupted);ncorr(1+(n-1)*nc:(n-1)*nc+nc)=corrupted(n);end

% TEMP 
ncorr=zeros(size(ncorr));
% TEMP

% Make all the samples that need to be excluded exactly 1000005
cords=find(ncorr==1);
MR.Data(:,cords)=1000005;

MR.SortData;
r=size(MR.Data,1);
X=size(MR.Data,2);
Y=size(MR.Data,3);
nc=size(MR.Data,4);

%% Create 2D K-spaces 
x=linspace(-.5,.5,1+X);x(end)=[];
y=linspace(-.5,.5,1+Y);y(end)=[];
[KX,KY]=meshgrid(x,y);
k=(KY+1j*KX)';

% Create a k-space mask
mask=ones(X,Y);
for x=1:X
    for y=1:Y
        if abs(MR.Data(1,x,y,1))>1000000 
            mask(x,y)=0;
        end
    end
end

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

% Reshape data and remove all entries that are 1000005
MR.Data=reshape(MR.Data,[r,X*Y*nc]);
cords=[];
for n=1:size(MR.Data,2)
    if abs(MR.Data(1,n))>1000000
        cords=[cords n];
    end
end
MR.Data(:,cords)=[];
MR.Data=permute(reshape(MR.Data,r,size(MR.Data,2)/nc,nc),[1 2 4 3]);

%% From here on solve per slice (across readout direction)
% Save k-space data and do 1D fft in z
kdata=fftshift(ifft(ifftshift(MR.Data,1),[],1),1);

% load csm
cd('/nfs/bsc01/researchData/USER/tbruijne/Research_data/MR21/20171018_MPRage_noise_sensor/Scan3/');load('csm.mat');cd('/home/tbruijne/Documents/Side_projects/Head_motion_noise_sensor');
%csm=ones(X,Y,r,nc);

% Define fourier operator
params.N=NUFFT(params.k,1,1,[Y/2 X/2],[Y X],2);
params.Idim=size(csm(:,:,1,:));
params.Kdim=[numel(params.k) 1 1 nc];

%% Iterative recon
figure('units','normalized','outerposition',[0 0 1 1]);
for ro=1:size(kdata,1)
    
if cgsense_bool==1
    niter=5;
    lambda=.6;
    
    % Create coil operator
    params.S=S(double(csm(:,:,ro,:)));
    params.TV=unified_TV([Y X 1 nc],[0 0],lambda);
    
    % 4) Solve the inverse problem
    % cgsense

     ops=optimset('Display','off');
%     func=@(x,tr) itSense_2D(x,params,tr);
     y=matrix_to_vec(permute(kdata(ro,:,:,:),[2 3 1 4 ]));
%     [tmp,~,relres(ro)]=lsqr(func,y,1E-10,niter);
%     cgsense(:,:,ro)=abs(reshape(tmp,[params.Idim(1:2)]));
    
    % Tychonov
    func=@(x,tr) regularized_iterative_sense(x,params,tr);
    y=[y ; zeros(prod(params.Idim(1:2)),1)];
    [tmp,~,relres(ro)]=lsqr(func,double(y),1E-10,niter);
    reg_cgsense(:,:,ro)=abs(reshape(tmp,[params.Idim(1:2)]));
end
% forward
sos_img(:,:,ro)=sos(single(params.N'*permute(kdata(ro,:,:,:),[2 3 1 4 ])));

% display
disp(['Recon = ',num2str(ro),'\',num2str(size(kdata,1))])
% m=zeros(size(sos_img(:,:,1)));m(find(mask==1))=1;
% a1=sos_img(:,:,ro);
% a2=cgsense(:,:,ro);
% a3=reg_cgsense(:,:,ro);
% m=m/max(m(:));
% imshow3(rot90(cat(3,a1/max(a1(:)),a2/max(a2(:)),a3/max(a3(:)),m),3),[0 0.7],[1 4]);
% set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);pause(0.1);

end

%% save
% sos_img=flip(permute(sos_img(:,:,r/4:3*r/4),[2 1 3]),3);
% reg_cgsense=reg_cgsense(:,:,r/4:3*r/4);
%cd('/nfs/bsc01/researchData/USER/tbruijne/Research_data/MR21/20171018_MPRage_noise_sensor/Scan2/')
%save('recons.mat','reg_cgsense','sos_img','-v7.3')
