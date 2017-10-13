function [ im, cmap, wfull] = openadapt( im, doNorm, Rn, wfull, zf, messageString )
%  Adaptive recon based on Walsh et al.
%
% [ recon, cmap, wfull] = openadapt( im, doNorm, Rn, wfull, zf, messageString )
%
% === This is the combination, if you want to do it manually ====
% recon = squeeze(sum( conj(wfull) .* im, 1) );
% ===============================================================
%
% === Input ===
%
%   im:         multi-channel images to be reconstructed, 2D/3D     (#coils x Ny x Nx x Nz)
%
%   doNorm:     (optional) flag determining whether to normalize image intensity
%
%   Rn:         (optional) input noise covariance matrix    (#coils x #coils)
%                          or noise data (#coils x Np   or   Np x #coils)
%
%   wfull:      (optional) coil combination weights, if known from anywhere
%
%   zf:         (optional) factor describing how much the image was zerofilled
%                          May be set to increase speed.
%
%   messageString (optional) write 'noMessage' if you don't want to see an openadapt
%                          hint to open a matlabpool
%
%  The optional input parameters may be set as empty arrays to use defaults.
%
%  Example:
%
%    imCombined = openadapt( im, false, [], [], 2);
%
%      * Rn     is ignored (meaning Rn = eye(Ncoils))
%      * wfull  is calculated inside openadapt
%      * zf = 2 is used
%
%
% === Output ===
%
%   recon:      Reconstructed (combined) image     (Ny x Nx x Nz)
%
%   cmap:       "Coil maps"
%
%   wfull:      coil combination weights; can be reused later as input
%
%
% === On noise covariance input Rn ===
%
%   Very ugly reconstructions are typical if Rn can hardly be inverted.
%   We try to detect that and help out the reconstruction by regularizing Rn:
%
%       L  = <some small value>;
%       Rn = (Rn  +  L*norm(Rn)*eye(Ncoil)) ./ (1+L);
%
%   The smallest possible L is found for which Rn can be inverted suffiently accurate.
%   If this happens, you will see a helpful message. No message, no cry! :-)
%   -- MiVö
%
%
% Reference:
%
%   Walsh DO, Gmitro AF, Marcellin MW.
%   Adaptive reconstruction of phased array MR imagery.
%   Magn Reson Med. 2000 May;43(5):682-690.
%   http://dx.doi.org/10.1002/(SICI)1522-2594(200005)43:5<682::AID-MRM10>3.0.CO;2-G
%
%    and
%
%   Mark Griswold, David Walsh, Robin Heidemann, Axel Haase, Peter Jakob.
%   The Use of an Adaptive Reconstruction for Array Coil Sensitivity Mapping and Intensity Normalization,
%   Proceedings of the Tenth Scientific Meeting of the International Society for Magnetic Resonance in Medicine pg 2410 (2002)
%
%
%   This function will calculate adaptively estimated coil maps
%   based on the Walsh algorithm for use in either optimal combination of
%   array images, or for parallel imaging applications. The doNorm flag can be
%   used to include the normalization described in the abstract above. This is
%   only optimal for birdcage type arrays, but will work reasonably for many other geometries.
%   This normalization is only applied to the recon'd image, not the coil maps.
%
%
%   The default block size is 4x4. One can also use interpolation to speed
%   up the calculation (see code), but this could cause some phase errors in practice.
%   Just pay attention to what you are doing.
%
%
%   1) This code is strictly for non-commercial applications
%   2) This code is strictly for research purposes, and should not be used in any
%      diagnostic setting.
%

%   10/1/2001  Mark Griswold
%   22/10/2004  MG - Updated help and changed interpolation to be more stable.
%   2010       Michael Völker - improved computation speed
%                             - added zerofill factor "zf"
%                               ---> smoothed images need about the same time as non-zerofilled ones
%                             - if no Rn is specified, skip dispensable calculations
%   2011       Michael Völker - speed increase on multicore due to parfor-loops
%                               (some changes were necessary in order to make it work nicely)
%                               call 'matlabpool open' before running openadapt()
%                             - further speed increase by using mtimesx() if available (http://www.mathworks.com/matlabcentral/fileexchange/25977)
%                             - imresize() accepts "multi-2D" data of size Ny x Nx x Nc,
%                               so we don't need loops there. This is faster *and* more readable.
%
%   2012       Weick / Völker - 2D and 3D possible
%              Michael Völker - updated help text and improved error checking
%                             - added adaptive regularization of Rn so that
%                               inversion of Rn is possible
%                             - Rn input may be the pure noise data, now.
%                               The covariance is then computed here.
%                             - removed license text
%                             - reduced z-blocksize (z-voxel-size is almost *always* way bigger than inplane)
%                             - added Info in help-text how to apply the weights manually
%                             - To match the notation in the original paper, we compute the "right" weights, that
%                               have to be applied as conj(weights) .* im

% ----- basic input handling -------------------------------------------
if ndims(im) > 4 || ismatrix(im) || ~isnumeric(im)
    error( 'openadapt:MainInput', 'Expected input image must be...\n\t...numeric\n\t...2D or 3D\n\t...matrix size: [coils] x [Ny] x [Nx] x [Nz]' )
end
if ~exist( 'doNorm', 'var') || isempty(doNorm)
    doNorm = false;
end
if ~exist( 'Rn', 'var')     || isempty(Rn)
    bNoise = false;     % No noise correlation data were passed to the function.
    Rn = [];            % in the parfor loop, Matlab wants an existing Rn, even if it is not used...
else
    bNoise = true;
end
if exist( 'wfull' , 'var' ) && ~isempty(wfull)
    weights_present = true;
else
    weights_present = false;
end
if ~exist( 'zf', 'var')     || isempty(zf)
    zf = 1;
end
if exist ('messageString', 'var' ) && strcmpi( messageString, 'noMessage' )     % whether a "matlabpool open" reminder should be displayed if necessary
    bSuppressWarning = true;
else
    bSuppressWarning = false;
end
% ----------------------------------------------------------------------

st  = round( zf * 2 );          % increase to set interpolation step size
bsX = round( 2  * st);          % x-block size
bsY = round( 2  * st);          % y-block size
bsZ = ceil( bsX /(2*zf));       % z-block size

[nc, ny, nx, nz] = size(im);

is3D = (nz > 1);

% ----- more error checking --------------------------------------------
if      length( doNorm(:) ) ~= 1                    ...     % no scalar
        || ~( islogical(doNorm) || isnumeric(doNorm) )    ...     % no usable data type
        ||    isempty(intersect( doNorm, [0 1] ))                 % something different than true/false or 1/0
    error('openadapt:doNorm',   '2nd argument ''doNorm'' must be a simple Boolean (true/false).' )
end
if weights_present && ~isequal( size(wfull), size(im) )
    error('openadapt:wfull',    '4th argument ''wfull'' must have the same size as the input data.')
end
if      length(     zf(:) ) ~= 1                    ...     % no scalar
        ||   ~isnumeric(  zf    )                         ...     % no usable data type
        ||   ~isreal(     zf    )                         ...     %
        ||    zf < 1
    error('openadapt:zf',       '5th argument ''zf'' must be a scalar number >= 1' )
end
% ----------------------------------------------------------------------

% ----- noise handling -------------------------------------------------
if bNoise
    
    % Check if noise input is a covariance matrix
    % or the pure noise data.
    if isequal( size(Rn), [nc nc] )             % square matrix ncoil x ncoil
        % everything is fine
    elseif ismatrix(Rn) && size(Rn,1) == nc
        
        Rn = Rn * Rn' ./ size(Rn,2);            % correlation matrix (zero-mean noise)
        
    elseif ismatrix(Rn) && size(Rn,2) == nc
        
        Rn = conj(Rn' * Rn)  ./ size(Rn,1);     % correlation matrix (zero-mean noise)
    else
        error('openadapt:Rn', '3rd argument ''Rn'' must be a noise correlation matrix of size Ncoils x Ncoils or the direct noise data.' )
    end
    
    
    % Try to determine, how accurate inv(Rn) can be computed and
    % find an amount of regularization so that inversion is possible.
    R   = double(Rn);               % better accuracy is very helpful, here
    eieiei = eye( nc );
    res = norm( inv(R)*R - eieiei );    %#ok <-- tell matlab, that inv() is intended, here
    res(isnan(res)) = inf;
    L     =   0;
    n     = log2(eps('double'));        % eps('double') = 2^-52
    maxN  = log2(realmax('double'));    % realmax('double') = 2^1024
    normR = norm(R);
    
    while  res > 2*eps  &&  n < maxN
        n = n + 1;
        L = 2^n;
        Rtry = (R + L*normR*eieiei)./(1+L);
        res = norm( inv(Rtry)*Rtry - eieiei );      %#ok <-- tell matlab, that inv() is intended, here
        res(isnan(res)) = inf;
    end
    
    if L > 0
        L = max( L, max(eps(Rn(:))) );
        fprintf('Mixing %.3g %% of eye(N) to noise correlation matrix for regularization.\n', 100*L/(L+1) )
        Rn = (Rn + L*normR*eieiei)./(1+L);
    end
    
    clear  R  Rtry  eieiei  res  L  n  maxN  normR
    
end % of noise handling
% ----------------------------------------------------------------------

precis = class(im);                     % single or double precision?
wantCmaps = (doNorm || nargout > 1);    % are we interested in coil maps?

NstepX = 1 + fix((nx-st)/st);   % \
NstepY = 1 + fix((ny-st)/st);   %   search Matlab's Doc --> colon
NstepZ = 1 + fix((nz-st)/st);   % /

% We do not allow having only one step when there is more than one element.
% We then reduce the stepsize.
if (nx > 1 && NstepX==1)  ||  (ny > 1 && NstepY==1)  ||  (nz > 1 && NstepZ==1)
    st = ceil( min([nx ny nz])/4 );
    NstepX = 1 + fix((nx-st)/st);
    NstepY = 1 + fix((ny-st)/st);
    NstepZ = 1 + fix((nz-st)/st);
end


if wantCmaps && bNoise      % otherwise we just don't need it
    % preallocation
    % We let it be NC x NX x NY x NZ, because it allows for more
    % sequential memory access in the loops below.
    cmapsmall = complex(zeros( nc, NstepX, NstepY, NstepZ, precis ));
end


% calculation of coil weights
if ~weights_present || wantCmaps
    
    % find coil with maximum intensity for correcting the phase of all
    % of the other coils.
    [~, maxcoil] = max(sum(abs(im(:,:)),2));
    
    xmin = max( (st:st:nx) - floor(bsX/2),  1); % Edges are cropped so the results near the edges of the image could
    xmax = min( (st:st:nx) + floor(bsX/2), nx); % be in error. Not normally a problem. But watch out for aliased regions.
    ymin = max( (st:st:ny) - floor(bsY/2),  1);
    ymax = min( (st:st:ny) + floor(bsY/2), ny);
    zmin = max( (st:st:nz) - floor(bsZ/2),  1);
    zmax = min( (st:st:nz) + floor(bsZ/2), nz);
    
    if isempty(zmin) || isempty(zmax)
        zmin = 1;
        zmax = 1;
    end
    
    %     % If we have a parallel computing toolbox, remind us to open a matlabpool:
    %     if exist('matlabpool','file') >= 2   &&  ~matlabpool('size') && ~bSuppressWarning
    %         fprintf('No pool of MATLAB workers found. Consider calling\n\t matlabpool open\nonce in your session to enable parallel computation.\n')
    %     end
    
    % determine if we can use the incredibly fast mtimesx()
    % ---> http://www.mathworks.com/matlabcentral/fileexchange/25977
    bUseMtimesX = (exist('mtimesx','file') > 2);
    
    % preallocation:
    wsmall = complex(zeros( nc, NstepX, NstepY, NstepZ, precis ));   % low resolution weights
    
    %     parfor y = 1:NstepY      % different y-coordinates are treated simultaneously on several workers
    for y = 1:NstepY      % different y-coordinates are treated simultaneously on several workers
        
        % helper variables to make parfor-loop work (in Matlab-Babbel, we need "sliced" variables)
        WsmTmp = complex(zeros( nc, NstepX, NstepZ, precis ));    % temporary variable, holding a row of wsmall for one specific y-index
        ClmTmp = WsmTmp;                                          % temporary variable, holding a row of cmapsmall for one specific y-index
        
        % Work with a reduced image stripe with side length bsY in y-direction
        % Due to this we can work with sequential pieces of memory in the inner loops
        imBlockY = im(:,ymin(y):ymax(y),:,:);                                 %#ok <-- suppress a warning in matlab editor
        
        for x = 1:NstepX
            
            imBlockX = imBlockY(:,:,xmin(x):xmax(x),:);                       %#ok <-- suppress a warning in matlab editor
            
            for z = 1:NstepZ
                
                m = reshape( imBlockX(:,:,:,zmin(z):zmax(z)), nc, [] );         %#ok <-- suppress a warning in matlab editor
                
                % Calculate signal covariance
                if bUseMtimesX
                    m = mtimesx( m, m, 'C', 'SPEEDOMP' );  % 'C': conjugate transpose of preceding value
                else
                    m = m * m';
                end
                
                if bNoise
                    [eivec, eivals] = eig( Rn \ m);     % Eigenvector with max eigenval gives the correct combination coeffs.
                else
                    [eivec, eivals] = eig( m );
                end
                
                [~,ind] = max( diag(eivals) );
                
                normmf = eivec(:,ind);
                
                if bNoise
                    WsmTmp(:,x,z) = normmf / (normmf' * (Rn \ normmf));   % MiVö: Should the denomninator not be sqrt(normmf' * (Rn \ normmf)) ? --> Eq. (20) in the Walsh-Paper
                else
                    WsmTmp(:,x,z) = normmf;
                end
                
                if wantCmaps && bNoise          % if we are interested in coil maps and Rn exists...
                    ClmTmp(:,x,z) = normmf;
                end
                
            end   % for z = 1:NstepZ
            
            imBlockX = [];    %#ok free memory (no "clear" allowed in parfor-loops)
        end   % for x = 1:NstepX
        
        imBlockY = [];    %#ok free memory (no "clear" allowed in parfor-loops)
        
        wsmall(:,:,y,:) = WsmTmp;
        WsmTmp = [];      %#ok free memory
        
        if wantCmaps && bNoise
            cmapsmall(:,:,y,:) = ClmTmp;
        end
        
    end % parfor y = 1:NstepY
    
    clear  imBlockY  imBlockX   WsmTmp   ClmTmp   m   normmf   Rn   eivec   eivals
    
    wsmall = permute( wsmall, [3 2 4 1] );        % NY x NX x NZ x NC
    wsmall = bsxfun( @times, wsmall, exp( -1i .* angle(wsmall(:,:,:,maxcoil)) ) );
    
    if wantCmaps && bNoise
        cmapsmall = permute( cmapsmall, [3 2 4 1] );  % NY x NX x NZ x NC
    end
    
end     %  if ~weights_present

% Correct phases based on coil with max intensity:
if wantCmaps && bNoise
    cmapsmall = bsxfun( @times, cmapsmall, exp( -1i .* angle(cmapsmall(:,:,:,maxcoil)) ) );
end


if is3D && ( ~weights_present  ||  wantCmaps   )
    % When using matlab's "interp3", we need to manually specify *where* matlab
    % should calculate the interpolation.
    X = single(   1 + (NstepX-1)*(0:nx-1)./(nx-1)   );      % 3D datasets can be really large,
    Y = single(   1 + (NstepY-1)*(0:ny-1)./(ny-1)   );      % so we try to make that smaller
    Z = single(   1 + (NstepZ-1)*(0:nz-1)./(nz-1)   );      % and faster using single()
    [X, Y, Z] = meshgrid(X,Y,Z);
end


% coil-by-coil interpolation of weights so the arrays have the size of the input images.
if ~weights_present
    
    % call abs() and angle() once before the 3D-Loop for speed
    wsmallAbs = abs(wsmall);
    wsmallPhs = angle(wsmall);
    clear wsmall
    
    if is3D
        %         parfor C=1:nc
        for C=1:nc
            wfull(:,:,:,C) = interp3( wsmallAbs(:,:,:,C),X,Y,Z,'cubic',0) .* exp( 1i .* interp3( wsmallPhs(:,:,:,C) , X,Y,Z, 'nearest',0));
        end
    else
        % 2D (imresize does all channels at once)
        wfull = imresize( squeeze(wsmallAbs), [ny nx],'bicubic') .* exp( 1i .* imresize( squeeze(wsmallPhs), [ny nx], 'nearest'));
    end
    
    clear  wsmallAbs  wsmallPhs
    
    % Coils back to first dimension
    wfull = reshape( reshape(wfull,[],nc).', nc, ny, nx, nz );      % wfull = permute( wfull, [4 1 2 3] );
end

% coil-by-coil interpolation of coilmaps so the arrays have the size of the input images.
if wantCmaps && bNoise
    
    % call abs() and angle() once before the 3D-Loop for speed
    cmapsmallAbs = abs(cmapsmall);
    cmapsmallPhs = angle(cmapsmall);
    clear cmapsmall
    
    if is3D
        
        %         parfor C=1:nc
        for C=1:nc
            cmap(:,:,:,C) = interp3( cmapsmallAbs(:,:,:,C),X,Y,Z,'cubic',0) .* exp( 1i .* interp3( cmapsmallPhs(:,:,:,C), X,Y,Z, 'nearest',0));
        end
    else
        % 2D (imresize does all channels at once)
        cmap = imresize(squeeze(cmapsmallAbs), [ny nx],'bicubic') .* exp( 1i .* imresize(squeeze(cmapsmallPhs), [ny nx], 'nearest'));
    end
    
    clear  cmapsmallAbs  cmapsmallPhs
    
    % Coils back to first dimension
    cmap = reshape( reshape(cmap,[],nc).', nc, ny, nx, nz );      % cmap = permute( cmap, [4 1 2 3] );
end

clear X Y Z

if wantCmaps && ~bNoise             % we are interested in coil maps but don't know Rn
    cmap = wfull;                   % ---> then there is no difference between cmap and wfull
end

% Combine coil signals "in one step":
% im = squeeze( sum(conj(wfull).*im, 1) );

% combine coil signals and be more efficient with memory usage:
im = conj(wfull) .* im;
if nargout < 3
    clear wfull
end
im = sum( im, 1 );
im = reshape( im, ny, nx, nz );


if doNorm
    im = im .* squeeze(sum(abs(cmap),1).^2);    % This is the normalization proposed in the abstract
    % referenced in the header.
end


end % of function
