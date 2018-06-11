function res = regularized_iterative_sense(x,params,transp_flag)

% Forward and backward operations
if strcmp(transp_flag,'transp') % Nonuniform k-space uncombined --> uniform image space combined  
    % Get image dimensions
    dims=num2cell(params.Idim);[nx,ny,nz,nc]=deal(dims{:});

    % Vector to matrix
    x1=vec_to_matrix(x(1:prod(params.Kdim)),params.Kdim);
    x2=x(prod(params.Kdim)+1:end);

    % Data fidelity
    res=zeros([nx ny nz nc]);
    for c=1:nc
        res(:,:,:,c)=params.N'*x1(:,:,:,c);
    end
    
    % Total variation part
    D=params.TV'*x2;

    % Coil sensitivity maps operator
    res=params.S*res;
    
    % Matrix to vector
    res=matrix_to_vec(res)+complex(x2);
    
elseif strcmp(transp_flag,'notransp') % uniform image combined --> nonuniform k-space uncombined
    % Get kspace dimensions
    dims=num2cell(params.Kdim);[ns,nl,nz,nc]=deal(dims{:});
    
    % Total variation part
    D=params.TV*matrix_to_vec(x);

    % Vector to matrix
    x=vec_to_matrix(x,[params.Idim(1:3) 1]);
    
    % S operator
    x=params.S'*x;
    
    % Preallocate output
    res=zeros([ns nl nz nc]);
    for c=1:nc
        res(:,:,:,c)=reshape(params.N*x(:,:,:,c),[ns nl nz]);
    end
    
    % Vectorize
    res=[matrix_to_vec(res); complex(D)];    
   
end

% END
end