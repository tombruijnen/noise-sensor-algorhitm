classdef MRdataDoc
    % The Data array holds MR data in the current reconstruction state and is updated everytime a
    % MRecon function is called.     
    % The data array has a fixed predefined form with a maximum of 12 different dimensions. Its form
    % might change slightly depending on the data type to be reconstructed:
    %
    % Raw-, Exported Raw- and Cpx-Data:
    %   
    %   r.Data = [x, y, z, coils, dynamics, heart phases, echoes, locations, mixes, extra1, extra2, averages]
    %
    % Rec Data: 
    %
    %   r.Data = [x, y, slices, echoes, dynamics, heart phases, image types, mixes, various]            
    properties
        Matrix; % The Data array
    end
    methods        
        function DAT = Clear( DAT )
            % Clears the Data array
        end        
        function new = Copy(this)
            % Creates a copy of the Data array
        end
    end          
end