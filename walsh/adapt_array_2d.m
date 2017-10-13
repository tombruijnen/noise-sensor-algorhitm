function [recon,cmap]=adapt_array_2d(yn,rn,norm)

% Reconstruction of array data and computation of coil sensitivities based
% on: a) Adaptive Reconstruction of MRI array data, Walsh et al. Magn Reson
% Med. 2000; 43(5):682-90 and b) Griswold et al. ISMRM 2002: 2410
%-------------------------------------------------------------------------
%	Input:
%	yn: array data to be combined [ny, nx, nc].
%	rn: data covariance matrix [nc, nc].
%	norm: =1, normalize image intensity
%
%	Output:
%	recon: reconstructed image [ny, nx].
%	cmap: estimated coil sensitivity maps [ny, nx, nc].
%--------------------------------------------------------------------------
% Ricardo Otazo
% CBI, New York University
%--------------------------------------------------------------------------
%

yn=permute(yn,[3,1,2]);
[nc,ny,nx]=size(yn);
if nargin<3, norm=0; end
if nargin<2, rn=eye(nc);end

% find coil with maximum intensity for phase correction
[mm,maxcoil]=max(sum(sum(permute(abs(yn),[3 2 1]))));

bs1=4;  %x-block size
bs2=4;  %y-block size
st=2;   %increase to set interpolation step size

wsmall=zeros(nc,round(ny./st),nx./st);
cmapsmall=zeros(nc,round(ny./st),nx./st);

invrn = inv(rn);

for x=st:st:nx
    for y=st:st:ny
        %Collect block for calculation of blockwise values
        ymin1=max([y-bs1./2 1]);
        xmin1=max([x-bs2./2 1]);
        % Cropping edges
        ymax1=min([y+bs1./2 ny]);
        xmax1=min([x+bs2./2 nx]);
        
        ly1=length(ymin1:ymax1);
        lx1=length(xmin1:xmax1);
        m1=reshape(yn(:,ymin1:ymax1,xmin1:xmax1),nc,lx1*ly1);
        
        m=m1*m1'; %signal covariance
        
        % eigenvector with max eigenvalue for optimal combination
        [e,v]=eig(invrn*m);
        
        v=diag(v);
        [mv,ind]=max(v);
        
        mf=e(:,ind);
        mf=mf/(mf'*invrn*mf);
        normmf=e(:,ind);
        
        % Phase correction based on coil with max intensity
        mf=mf.*exp(-1i*angle(mf(maxcoil)));
        normmf=normmf.*exp(-1i*angle(normmf(maxcoil)));
        
        wsmall(:,y./st,x./st)=mf;
        cmapsmall(:,y./st,x./st)=normmf;
    end
end

% Interpolation of weights upto the full resolution
% Done separately for magnitude and phase in order to avoid 0 magnitude
% pixels between +1 and -1 pixels.
wfull=zeros(nc,ny,nx);
cmap=zeros(nc,ny,nx);

for i=1:nc
    wfull(i,:,:)=conj(imresize(squeeze(abs(wsmall(i,:,:))),[ny nx],'bilinear').*exp(1i.*imresize(angle(squeeze(wsmall(i,:,:))),[ny nx],'nearest')));
    cmap(i,:,:)=imresize(squeeze(abs(cmapsmall(i,:,:))),[ny nx],'bilinear').*exp(1i.*imresize(squeeze(angle(cmapsmall(i,:,:))),[ny nx],'nearest'));
end
recon=squeeze(sum(wfull.*yn));   %Combine coil signals.
% normalization proposed in the abstract by Griswold et al.
if norm, recon=recon.*squeeze(sum(abs(cmap))).^2; end

cmap=permute(cmap,[2,3,1]);
