function fiex_pars = fiex_config()

% This file specifies the parameters for the smoothing and extrapolation
% process of the coil sensitivities.

% Smoothing: 
fiex_pars.fi_type = 1;      % The smoothing algorithm used [ 1 = polynom fitting ]
fiex_pars.fi_order = 1;     % The order of the polynom to be fitted [ 1 = linear ]
fiex_pars.fi_nr = 4;        % The size of the neighbourhood which is considered around the pixel to be fitted
fiex_pars.fi_omega = 2;     % The weighting of the pixels in the above neighbourhood

% Extrapolation:
fiex_pars.ex_type = 1;      % The extrapolation algorithm used [ 1 = polynom fitting, 2= weighed average, 3 = a mix of both ]
fiex_pars.ex_order = 1;     % The order of the polynom to be fitted [ 1 = linear ]
fiex_pars.ex_nr = 16;       % The size of the neighbourhood which is considered around the pixel to be fitted
fiex_pars.ex_omega = 8;     % The weighting of the pixels in the above neighbourhood
fiex_pars.ex_runden = 8;    % The amount of extrapolation

% Masking:
fiex_pars.image2mask = 1;   % The image on which the mask is calculated [ 1 = Bodycoil, 2 = Coil images ]
fiex_pars.mask_thresh = 1;  % The mask threshold [ larger = higher threshold ]
fiex_pars.max_outer_ex = 2; % The amount of extrapolation outside the object