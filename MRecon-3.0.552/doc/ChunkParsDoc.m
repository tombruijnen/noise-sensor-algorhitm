classdef ChunkParsDoc
    % When reconstruction large datasets, one often runs into memory problems which makes it
    % impossible to reconstruct whole data at once. In MRecon the data can be divided into several
    % smaller chunks which are reconstructed seperately.
    
    properties 
        Def;        % Defines the data chunk. This paramter has to be a cell of strings and possible values are: 'All', 'kx', 'ky', 'kz', 'chan', 'dyn', 'card', 'echo', 'loca, 'mix', 'extr1', 'extr2', 'aver'. If for example the acquired 3D volume of all coils should be reconstructed at once then set this parameter to: {'kx', 'ky', 'kz', 'chan'}             
        CurLoop;    % The current chunk to be reconstructed. Set this parameter in a loop over the chunks
        NrLoops;    % The number of chunks to be reconstructed. 
        Loops;      % Defines over which image valiables is looped during the chunk reconstruction. 
    end
    
    methods        
        % ---------------------------------------------------------------%
        % Reset all Chunk Parameter
        % ---------------------------------------------------------------%        
        function Reset( C )    
            % Reset all Chunk parameter            
        end                
        % ---------------------------------------------------------------%
        % Deep Copy of Class
        % ---------------------------------------------------------------%
        function new = Copy(this)
            % Creates a copy of the chunk object. 
        end
    end         
end

