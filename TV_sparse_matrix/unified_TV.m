function tv = unified_TV(Id,TVdim,lambda)
% Create one sparse matrix to perform all the required TV operations

% If no TV use tychonov regularization
if nnz(TVdim)==0
    tv=lambda(1)*speye(prod(Id([1:3 5:end])));return;end

% Pre-allocate TV matrix
tv=sparse(prod(Id([1:3 5:end])),prod(Id([1:3 5:end])));

% Loop over all dimensions and compute sparse matrices
for n=1:numel(TVdim)
    if TVdim(n)>0
        tv=tv+lambda(n)*TV(n,Id,TVdim(n));
    end
end
        
% END
end