function res = itSense_2D(x,params,transp_flag)

% Forward and backward operations
if strcmp(transp_flag,'transp') % Nonuniform k-space uncombined --> uniform image space combined
    
    % Get image dimensions
    dims=num2cell(params.Idim);[nx,ny,nz,nc]=deal(dims{:});
    
    % Vector to matrix
    x=vec_to_matrix(x,params.Kdim);
    
    % Preallocate output
    res=zeros([nx ny nz nc]);
    for c=1:nc
        res(:,:,:,c)=params.N'*x(:,:,:,c);
    end
    
    % Coil sensitivity maps operator
    res=params.S*res;
    
    % Vectorize
    res=matrix_to_vec(res);

elseif strcmp(transp_flag,'notransp') % uniform image combined --> nonuniform k-space uncombined
    % Get kspace dimensions
    dims=num2cell(params.Kdim);[ns,nl,nz,nc]=deal(dims{:});
    
    % Vector to matrix
    x=vec_to_matrix(x,params.Idim(1:3));
    
    % S operator
    x=params.S'*x;
    
    % Preallocate output
    res=zeros([ns nl nz nc]);
    for c=1:nc
        res(:,:,:,c)=reshape(params.N*x(:,:,:,c),[ns nl nz]);
    end
    
    % Matrix to vector
    res=matrix_to_vec(res);
end
end