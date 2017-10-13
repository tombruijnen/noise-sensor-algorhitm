classdef AveragingParsDoc
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here

	properties
		
		FID_BlockSize = {}; 		% Specifies the number of FIDs that will be averaged together. The resulting data size is original number of FIDs divided by the block size.
		FID_Pattern   = {}; 		% Specifies the pattern in which the individual FIDs within a block are combined. The default [1 1] is just regular averaging. [1 -1] would represent a common add/subtract scheme. The values in the pattern represent scaling factors that are applied to the data prior to averaging.
		Dyn_Averaging = false; 		% Switch to include also dynamics in the averaging processing step.
		Dyn_BlockSize = {}; 		% Specifies the number of dynamics that will be averaged together. The resulting data size is original number of dynamics divided by the block size.
		Dyn_Pattern   = {};    		% Specifies the pattern in which the individual dynamics within a block are combined. The default [1 1] is just regular averaging. [1 -1] would represent a common add/subtract scheme. The values in the pattern represent scaling factors that are applied to the data prior to averaging.

	end

end


