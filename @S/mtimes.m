function res = mtimes(s,data) 
% Perform 2D FT

if s.adjoint == 0 % Coil combination
    res=sum(data.*conj(s.S),4);
elseif s.adjoint == 1 % Coil splitting
     res=repmat(data,[1 1 1 size(s.S,4)]).*s.S;
end
    


% END  
end 