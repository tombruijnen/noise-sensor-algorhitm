classdef My_Recon < MRecon   % Derive My_Recon from MRecon    
    properties
        % No additional properties needed
    end
    
    methods
        function MR = My_Recon( filename )
            % Create an MRecon object MR upon creation of an My_Recon
            % object
            MR = MR@MRecon(filename); 
        end
        
        % Overload (overwrite) the existing Perform function of MRecon    
        function Perform( MR )            
            %Reconstruct only standard (imaging) data
            MR.Parameter.Parameter2Read.typ = 1;                        
            % Produce k-space Data (using MRecon functions)            
            MR.ReadData;
            MR.DcOffsetCorrection;
            MR.PDACorrection;
            MR.RandomPhaseCorrection;
            MR.MeasPhaseCorrection;
            MR.SortData;
            MR.GridData;
            
            % Filter k-space data using an own function defined in My_Recon
            MR.HammingFilter;                        
        end
        
        % Definition of the Hamming-filter function
        function HammingFilter( MR )
            % Prerequisites: Check if the data has the right form
            if ~MR.Parameter.ReconFlags.isread
                error( 'Please read the data first' );
            end
            if ~MR.Parameter.ReconFlags.issorted
                error( 'Please sort the data first' );
            end            
            % MR.Data can be a cell or an array depending on the dataset. 
            % To make our function work with all kinds of data, we convert
            % MR.Data to a cell in any case and the let the hamming filter
            % work on every cell element (using cellfun)
            MR.Data = MR.Convert2Cell( MR.Data );
            MR.Data = cellfun( @(x)MR.filter_image( x ), MR.Data, 'UniformOutput', 0 );
            % Convert MR.Data back to oroginal state
            MR.Data = MR.UnconvertCell( MR.Data );
        end
    end
    
    % These functions are Hidden to the user
    methods (Static, Hidden)
        % Actual code for the Hamming filter (called by cellfun)
        function data = filter_image( data )
            if ~isempty( data )
                % Obtain the number of images in MR.Data
                data_size = size(data);
                nr_images = prod( data_size( 3:end) );
                % Define filter
                hfilter = (hamming(size(data,1))*hamming(size(data,2))');
                hfilter = hfilter/max(hfilter(:));
                % Filter every single image
                for i = 1:nr_images
                    data(:,:,i) = data( :,:,i) .* hfilter;
                end
            end
        end
    end
end


