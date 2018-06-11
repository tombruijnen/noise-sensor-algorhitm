%% Load test data - skip above steps
clear all;close all;clc;addpath(genpath(pwd))
load Single_slice_data.mat
kdata=data;

x=linspace(-.5,.5,201);x(end)=[];
y=linspace(-.5,.5,183);y(end)=[];
[KX,KY]=meshgrid(x,y);
k=(KY+1j*KX)';

% Create masks for k-space and data (undersampling)
mask=randi(size(k,2),25,1);
mask=[1:2:80 110:2:182]; 
mask=[1:40 41:2:140 141:182];
k(:,mask)=[];
kdata(:,:,mask,:)=[];

k=reshape(k,numel(k),1);
params.k=k; 

% Define fourier operator
params.N=NUFFT(params.k,1,1,[200/2 182/2],[200 182],2);
params.Idim=size(csm(:,:,1,:));
params.Kdim=[numel(params.k) 1 1 12];

load('csm290.mat')

% Standard iterative sense
for ro=1:size(kdata,1)

niter=50;
lambda=0.1;

% Create coil operator
params.S=S(csm(:,:,ro,:));
params.TV=unified_TV([200 182 1 12],[0 0],lambda);

% 4) Solve the inverse problem 
% cgsense
ops=optimset('Display','off');
func=@(x,tr) itSense_2D(x,params,tr);
y=matrix_to_vec(permute(kdata(ro,:,:,:),[2 3 1 4 ]));
[tmp,~,relres(ro)]=lsqr(func,y,1E-08,niter);
cgsense(:,:,ro)=abs(reshape(tmp,[params.Idim(1:2)]));

% Tychonov
func=@(x,tr) regularized_iterative_sense(x,params,tr);
y=[y ; zeros(prod(params.Idim(1:2)),1)];
[tmp,~,relres(ro)]=lsqr(func,double(y),1E-15,niter);
reg_cgsense(:,:,ro)=abs(reshape(tmp,[params.Idim(1:2)]));

% forward
sos_img(:,:,ro)=sos(params.N'*permute(kdata(ro,:,:,:),[2 3 1 4 ]));

% display
disp(['Recon = ',num2str(ro),'\',num2str(size(kdata,1))])
m=10*ones(size(sos_img(:,:,1)));m(:,mask)=0;
a1=sos_img(:,:,ro);
a2=cgsense(:,:,ro);
a3=reg_cgsense(:,:,ro);
m=m/max(m(:));
imshow3(cat(3,a1/max(a1(:)),a2/max(a2(:)),a3/max(a3(:)),m),[],[1 4])
end

