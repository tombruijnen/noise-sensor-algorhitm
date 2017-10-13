function image_slide( data, varargin )

update = 0;
warning = 1;
ontop = 0;
if nargin > 1
    for i = 1:length( varargin )
        if strcmpi( varargin{i}, 'update' )
            update = 1;
        end
        if strcmpi( varargin{i}, 'NoWarning' )
            warning = 0;
        end
        if strcmpi( varargin{i}, 'ontop' )
            ontop = 1;
        end
    end
end
if iscell( data )
    for i = 1:size(data, 1);
        for j = 1:size(data, 2);
            if ~isempty(find(isnan( data{i,j} ) ))
                if warning
                    h = warndlg( 'Your image contains NaN''s. Setting them to 0', 'Warning', 'modal' );
                    uiwait(h);
                end
                data{i,j}( isnan(data{i,j}) ) = 0;
            end
            if isreal( data )
                imslide(data{i,j}, update, ontop)
            else
                imslide(angle(data{i,j}), update, ontop)
                imslide(abs(data{i,j}), update, ontop)
            end
        end
    end
else
    if ~isempty(find(isnan( data ) ))
        if warning
            h = warndlg( 'Your image contains NaN''s. Setting them to 0', 'Warning', 'modal' );
            uiwait(h);
        end
        data( isnan(data) ) = 0;
    end
    if isreal( data )
        imslide(data, update, ontop)
    else
        imslide(angle(data), update, ontop)
        imslide(abs(data), update, ontop)
    end
end