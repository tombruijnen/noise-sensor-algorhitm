function T = TV(dim,Id,order)
% Generalized first and second order TV operator

if numel(Id)<13
    Id(end+1:13)=1;
end

% Remove coil dimensions
Id(4)=1;

switch order
    case 1
        D = spdiags([-ones(Id(dim),1) ones(Id(dim),1)],[0 1],Id(dim),Id(dim));
        D(Id(dim),:) = 0;
    case 2
        D = spdiags([-2*ones(Id(dim),1) ones(Id(dim),1) ones(Id(dim),1)],[0 1 -1],Id(dim),Id(dim));
        D([1,Id(dim)],:) = 0;
    case 3
        D1 = spdiags([-ones(Id(dim),1) ones(Id(dim),1)],[0 1],Id(dim),Id(dim));
        D1(Id(dim),:) = 0;    
        D2 = spdiags([-2*ones(Id(dim),1) ones(Id(dim),1) ones(Id(dim),1)],[0 1 -1],Id(dim),Id(dim));
        D2([1,Id(dim)],:) = 0;
        D=0.23*D2+0.77*D1;
end

T=kron(speye(prod(Id(dim+1:end))),kron(D,speye(prod(Id(1:dim-1)))));

% END
end