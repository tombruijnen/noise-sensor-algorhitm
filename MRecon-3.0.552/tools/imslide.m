function varargout = imslide(varargin)
% IMSLIDE M-file for imslide.fig
%      IMSLIDE, by itself, creates a new IMSLIDE or raises the existing
%      singleton*.
%
%      H = IMSLIDE returns the handle to a new IMSLIDE or the handle to
%      the existing singleton*.
%
%      IMSLIDE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMSLIDE.M with the given input arguments.
%
%      IMSLIDE('Property','Value',...) creates a new IMSLIDE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before imslide_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to imslide_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help imslide

% Last Modified by GUIDE v2.5 05-Apr-2012 09:46:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
if length( varargin ) > 1
    gui_Singleton = varargin{2};
end
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @imslide_OpeningFcn, ...
                   'gui_OutputFcn',  @imslide_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% ---------------------------------------------------------------%
% Opening function and Gui initializing
% ---------------------------------------------------------------%
function imslide_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to imslide (see VARARGIN)

% Choose default command line output for imslide
handles.output = hObject;

handles.ontop = 0;
if length( varargin ) > 2
    handles.ontop = varargin{3};
end

handles.taskbar_height      = 30;
handles.bottom_bar_height   = 25;
handles.pause_dur           = 0.02;

handles.image = varargin{1};
handles = init_gui( handles );

% Update handles structure
guidata(hObject, handles);

function handles = init_gui( handles )

handles.isplot1 = 0;
handles.zoom_state = [];

tbh = findall(gcf,'Type','uitoolbar');
tool_handles = findall( tbh );
for i = 1:length(tool_handles)
    if ishandle(tool_handles(i))
        tool_tag = get( tool_handles(i), 'tag' );
        if strcmpi( tool_tag, 'Standard.SaveFigure')
            delete( tool_handles(i) );
        end
    end
end

set( handles.sidebar, 'Visible', 'off')

handles.cm = gray;
handles.cm_orig = handles.cm;

box( handles.axes1, 'on' );

set( handles.axes1, 'xtick',[] );
set( handles.axes1, 'ytick',[] );

handles = get_colormap( handles );

if size(handles.image(:,:,:),3) > 1
    set( handles.slider1, 'Enable', 'on' );
    set( handles.slider1, 'Value', 0.0 );
    set(handles.slider1, 'SliderStep', [1/( size( handles.image(:,:,:), 3)-1), 4/( size( handles.image(:,:,:), 3)-1)] );
else
    set( handles.slider1, 'Enable', 'off' );
    set( handles.dimension_slider, 'Enable', 'off' );
end

handles.max_img_value = max( handles.image(:));
handles.min_img_value = min( handles.image(:));

handles.range_img_value = handles.max_img_value-handles.min_img_value;
handles.max_scaling = handles.max_img_value;
handles.min_scaling = handles.min_img_value;
if handles.max_scaling == handles.min_scaling
    handles.max_scaling = handles.max_scaling + 0.01*handles.max_scaling;
end
if handles.max_scaling == 0 && handles.min_scaling == 0
    handles.max_scaling = 1;
end
    
if get(handles.auto_contrast, 'Value')
    set( handles.min_clipping, 'Enable', 'off');
    set( handles.max_clipping, 'Enable', 'off');
end

set( handles.max_clipping, 'Visible', 'on')
set( handles.min_clipping, 'Visible', 'off')

if ndims( handles.image ) < 3
    set( handles.composition, 'Enable', 'off');
else
    set( handles.composition, 'Enable', 'on');               
end
handles = get_image2show( handles );
[siz, change_size] = determine_optimal_size( handles );
handles = set_gui_size( handles, siz );

set( handles.imslide, 'UserData', 0);
try
    hcmenu = uicontextmenu(get(handles.axes1,'parent'));
catch
    hcmenu = uicontextmenu();
end
item1 = uimenu(hcmenu, 'Label', 'Interpolate on Resize/Zoom', 'Callback', @contextmenu_callback, 'Checked', 'off');
set(handles.axes1,'uicontextmenu',hcmenu);

h = zoom;
set(h,'ActionPostCallback',@zoom_post_callback);

handles = show_images( handles );
slider1_Callback(handles.slider1, [], handles);

% ---------------------------------------------------------------%
% Resize Function
% ---------------------------------------------------------------%
function imslide_ResizeFcn(hObject, eventdata, handles)
if isfield( handles, 'taskbar_height') && isfield( handles, 'bottom_bar_height')

y_offset = 0;
x_offset = 2;
% 
% % guipos = get( hObject, 'Position' );
% % set(hObject, 'Position', [guipos(1), guipos(2), gui_width, gui_height] );
guipos = get( hObject, 'Position' );
pause(handles.pause_dur);

% % set taskbar position
set( handles.taskbar, 'Position', ...
    [-2, guipos(4)-handles.taskbar_height, guipos(3)+4, handles.taskbar_height+20] );

%set bottom bar position
set( handles.bottom_bar, 'Position', ...
    [0, y_offset, guipos(3), handles.bottom_bar_height] );

%set axes position
max_axes_height = guipos(4) - handles.taskbar_height - handles.bottom_bar_height;
sidebarpos = get( handles.sidebar, 'Position' );
if get(handles.composition, 'Value')
    max_axes_width  = guipos(3)-sidebarpos(3);
else
    max_axes_width  = guipos(3);
end

test_height = max_axes_height;
test_width  = size( handles.image2show,2 )/size( handles.image2show,1 )*test_height;
if test_width <= max_axes_width
    axes_width = test_width;
    axes_height = test_height;
    y  = handles.bottom_bar_height+1;
    x = (max_axes_width-axes_width)/2;
else
    axes_width = max_axes_width;
    axes_height  = size( handles.image2show,1 )/size( handles.image2show,2 )*axes_width;    
    y  = handles.bottom_bar_height+1+(max_axes_height-axes_height)/2;
    x = 0;
end
set( handles.axes1, 'Position', ...
    [x, y, axes_width, axes_height] );
if axes_width ~= size( handles.image2show,2 ) || axes_height ~= size( handles.image2show,1 )
    set( handles.original_size, 'Value', 0 )
else
    set( handles.original_size, 'Value', 1 )
end

%set save button position
h = handles.save;
savepos = get( h, 'Position' );
empty_space_height = (handles.taskbar_height - savepos(4))/2+1;
y_save = empty_space_height;
x_save = x_offset +4;
set( h, 'Position', ...
    [x_save, y_save, savepos(3), savepos(4)] );

%set original size checkbox positions
h = handles.original_size;
sizcheckpos = get( h, 'Position' );
y_size = empty_space_height;
x_size = x_save + savepos(3) + x_offset;
set( h, 'Position', ...
    [x_size, y_size, sizcheckpos(3), sizcheckpos(4)] );

%set composition checkbox positions
h = handles.composition;
compcheckpos = get( h, 'Position' );
y_comp = empty_space_height;
x_comp = x_size + sizcheckpos(3) + x_offset;
set( h, 'Position', ...
    [x_comp, y_comp, compcheckpos(3), compcheckpos(4)] );

%set equal scaling checkbox positions
h = handles.auto_contrast;
equalcheckpos = get(h , 'Position' );
y_equal = empty_space_height;
x_equal = x_comp + compcheckpos(3) + x_offset;
set( h, 'Position', ...
    [x_equal, y_equal, equalcheckpos(3), equalcheckpos(4)] );

%set equal scaling checkbox positions
h = handles.dimension_slider;
dimpos = get(h , 'Position' );
y_dim = empty_space_height;
x_dim = x_equal + equalcheckpos(3) + x_offset;
set( h, 'Position', ...
    [x_dim, y_dim, dimpos(3), dimpos(4)] );

%set scaling expand button position
h = handles.expand_scaling;
expcheckpos = get(h , 'Position' );
y_exp = empty_space_height+8;
x_exp = x_dim + equalcheckpos(3) + x_offset;
set( h, 'Position', ...
    [x_exp, y_exp, expcheckpos(3), expcheckpos(4)] );

if get( handles.expand_scaling, 'Value' )
    set( handles.colormap, 'Visible', 'on');
    set( handles.slider_switch, 'Visible', 'on');
    if strcmpi( get( handles.slider_switch, 'String' ), 'Max' )
        set( handles.max_clipping, 'Visible', 'on');
    else
        set( handles.min_clipping, 'Visible', 'on');
    end
    
%set slider switch positions
h = handles.slider_switch;
switchpos = get(h , 'Position' );
y_text = empty_space_height;
x_text = x_exp + equalcheckpos(3) + x_offset;
set( h, 'Position', ...
    [x_text, y_text, switchpos(3), switchpos(4)] );

%set max_clipping slider positions
h = handles.max_clipping;
sliderpos = get(h , 'Position' );
y_slider = empty_space_height+ (equalcheckpos(4)-sliderpos(4))/2;
x_slider = x_text + switchpos(3)+x_offset;
set( h, 'Position', ...
    [x_slider, y_slider, sliderpos(3), sliderpos(4)] );
h = handles.min_clipping;
sliderpos = get(h , 'Position' );
y_slider = empty_space_height+ (equalcheckpos(4)-sliderpos(4))/2;;
x_slider = x_text + switchpos(3)+x_offset;
set( h, 'Position', ...
    [x_slider, y_slider, sliderpos(3), sliderpos(4)] );

%set colormap positions
h = handles.colormap;
colorpos = get(h , 'Position' );
y_color = empty_space_height+4;
x_color = x_slider + sliderpos(3) + 2*x_offset;
set( h, 'Position', ...
    [x_color, y_color, colorpos(3), colorpos(4)] );
max_x = x_color + colorpos(3) + x_offset;
else
    set( handles.colormap, 'Visible', 'off');
    set( handles.max_clipping, 'Visible', 'off');
    set( handles.min_clipping, 'Visible', 'off');
    set( handles.slider_switch, 'Visible', 'off');
    max_x = x_exp + expcheckpos(3) + x_offset;
end

%set xyv text position
textpos1 = get(handles.xyv_text , 'Position' );
textpos2 = get(handles.image_text , 'Position' );
min_x = guipos(3) - max([textpos1(3), textpos2(3)]) ;
if min_x > max_x
    h = handles.xyv_text;
    set(h, 'Visible', 'on');
    y_text = 2;
    x_text = guipos(3) - textpos1(3) ;
    set( h, 'Position', ...
        [x_text, y_text, textpos1(3), textpos1(4)] );
    %set image text position
    h = handles.image_text;
    set(h, 'Visible', 'on');
    y_text = textpos2(4)+2;
    x_text = guipos(3) - textpos2(3) ;
    set( h, 'Position', ...
        [x_text, y_text, textpos2(3), textpos2(4)] );
else
    % if the text doesn't fit set its position outside the gui
    set( handles.xyv_text, 'Position', ...
        [guipos(3)+20, guipos(4) + 20, textpos1(3), textpos1(4)] );
    set( handles.image_text, 'Position', ...
        [guipos(3)+20, guipos(4) + 20, textpos2(3), textpos2(4)] );
end

%set slider1 positions
sliderpos = get( handles.slider1, 'Position' );
y_slider = (handles.bottom_bar_height - sliderpos(4))/2;
set( handles.slider1, 'Position', ...
    [5, y_slider+1, max(guipos(3)-10,1), sliderpos(4)] );

%set sidebar positions
sidebarpos = get( handles.sidebar, 'Position' );
y_sidebar = handles.bottom_bar_height+1;
x_sidebar = guipos(3)-sidebarpos(3)-1;
set( handles.sidebar, 'Position', ...
    [x_sidebar, y_sidebar, sidebarpos(3), guipos(4)+10] );

%set slider2 positions
sliderpos = get( handles.slider2, 'Position' );
y_slider = handles.bottom_bar_height+5;
set( handles.slider2, 'Position', ...
    [5, y_slider+1, sliderpos(3), max( 1, axes_height-10)] );

handles = show_images( handles );
end

guidata(hObject, handles);

% ---------------------------------------------------------------%
% Callbacks
% ---------------------------------------------------------------%
function save_Callback(hObject, eventdata, handles)
imsave( handles.axes1, handles );

function original_size_Callback(hObject, eventdata, handles)
checked = get(hObject, 'Value');
if checked 
    siz(1) = size(handles.image2show,1);
    siz(2) = size(handles.image2show,2);
else
    [siz, change_size] = determine_optimal_size( handles, 1 );  
end
handles = set_gui_size( handles, siz );
guidata(hObject, handles);

function composition_Callback(hObject, eventdata, handles)
set( handles.slider2, 'Value', 1);
handles = set_slider_step(handles);
handles = get_image2show( handles );
if get( handles.composition, 'Value' ) 
    set( handles.dimension_slider, 'Enable', 'off' );    
    if strcmpi( get(handles.slider2, 'Enable'), 'on' )
        set( handles.sidebar, 'Visible', 'on' );    
    end
    force_resize = 0;
else
    set( handles.dimension_slider, 'Enable', 'on' );    
    set( handles.sidebar, 'Visible', 'off' );    
    if get(handles.original_size, 'Value')
        force_resize = 0;
    else
        force_resize = 1;
    end
end
[siz, change_size] = determine_optimal_size( handles, force_resize );
pause(handles.pause_dur);
handles = set_gui_size( handles, siz );
handles.isplot1 = 0;
handles = show_images( handles );
slider1_Callback(handles.slider1, eventdata, handles);
guidata(hObject, handles);

function auto_contrast_Callback(hObject, eventdata, handles)
if get(handles.auto_contrast, 'Value')
    set( handles.min_clipping, 'Enable', 'off');
    set( handles.max_clipping, 'Enable', 'off');
       
    step = ceil( length(handles.image(:)) / 4e6 );
    handles.max_scaling = mean(handles.image(1:step:end))+3*std(handles.image(1:step:end));
    handles.min_scaling = min(handles.image(:));    
    if handles.max_scaling == handles.min_scaling
        handles.max_scaling = handles.max_scaling + 0.01*handles.max_scaling;
    end
    if handles.max_scaling == 0 && handles.min_scaling == 0
        handles.max_scaling = 1;
    end
else
    set( handles.min_clipping, 'Enable', 'on');
    set( handles.max_clipping, 'Enable', 'on');
    handles = set_brightness_contrast( handles );
end
handles = show_images( handles );
guidata(hObject, handles);

function dimension_slider_Callback(hObject, eventdata, handles)
axespos = get( handles.axes1, 'Position');
set( handles.slider2, 'Value', 1);
handles = get_dim2hold( handles );
handles = set_slider_step(handles);
handles = get_image2show( handles );
if get( hObject, 'Value' )      
    set( handles.composition, 'Enable', 'off' ); 
    if strcmpi( get(handles.slider2, 'Enable'), 'on' )
        set( handles.sidebar, 'Visible', 'on' );    
    end
    force_resize = 0;
else
    set( handles.composition, 'Enable', 'on' );    
    set( handles.sidebar, 'Visible', 'off' );    
    if get(handles.original_size, 'Value')
        force_resize = 0;
    else
        force_resize = 1;
    end
end
handles = set_gui_size( handles, [axespos(4), axespos(3)] );
handles = show_images( handles );
guidata(hObject, handles);

function expand_scaling_Callback(hObject, eventdata, handles)
if get( hObject, 'Value' )
    set( hObject, 'String', '<');
else
    set( hObject, 'String', '>');
end
imslide_ResizeFcn(handles.imslide, eventdata, handles);

function slider_switch_Callback(hObject, eventdata, handles)
str = get( hObject, 'String' );
switch str
    case 'Max'
        set( hObject, 'String', 'Min');
        set( handles.max_clipping, 'Visible', 'off')
        set( handles.min_clipping, 'Visible', 'on')
    case 'Min'
        set( hObject, 'String', 'Max');
        set( handles.max_clipping, 'Visible', 'on')
        set( handles.min_clipping, 'Visible', 'off')
end

function max_clipping_Callback(hObject, eventdata, handles)
handles = set_brightness_contrast( handles );
handles = show_images( handles );
guidata(hObject, handles);

function min_clipping_Callback(hObject, eventdata, handles)
handles = set_brightness_contrast( handles );
handles = show_images( handles );
guidata(hObject, handles);

function colormap_Callback(hObject, eventdata, handles)
handles = get_colormap( handles );
handles = show_images( handles );
guidata(hObject, handles);

function slider1_Callback(hObject, eventdata, handles)
handles.cur_axes = 1;
handles = get_image2show( handles );
handles = show_images( handles );
guidata(hObject, handles);

function slider2_Callback(hObject, eventdata, handles)
handles = get_dim2hold( handles );
handles = set_slider_step(handles);
handles = get_image2show( handles );
if get( handles.composition, 'Value' )     
    force_resize = 0;
    [siz, change_size] = determine_optimal_size( handles, force_resize );
    handles = set_gui_size( handles, siz );
    handles.isplot1 = 0;
else    
    if get(handles.original_size, 'Value')
        force_resize = 0;
    else
        force_resize = 1;
    end
end
handles = show_images( handles );
guidata(hObject, handles);

function imslide_WindowButtonMotionFcn(hObject, eventdata, handles)
currentPoint = get( handles.axes1, 'CurrentPoint' );
currentPoint = currentPoint(1,1:2);
is_inside = 0;
current_axes = handles.axes1;
xres = get(current_axes, 'xlim');
yres = get(current_axes, 'ylim');
if( currentPoint( 1, 1) < xres(1) || currentPoint( 1, 1 ) > xres(2) ||...
        currentPoint( 1, 2 ) < yres(1) || currentPoint( 1, 2 ) > yres(2) )
    is_inside = 0;
else
    is_inside = 1;
end
if is_inside
    guipos = get(hObject, 'Position');
    x_str = num2str(round(currentPoint(1,1)), '%4d');
    y_str = num2str(round(currentPoint(1,2)), '%4d');
    v_str = num2str(handles.image2show(round(currentPoint(1,2)), round(currentPoint(1,1))),'%5.3g');
    str = ['x: ',x_str,' y: ', y_str, ' v: ',v_str ];
    
    set( handles.xyv_text, 'Units', 'Characters' )
    textpos = get(handles.xyv_text, 'Position');
    textpos(3) = length(str);
    set( handles.xyv_text, 'Position', textpos );
    set( handles.xyv_text, 'Units', 'pixels' )
    textpos = get(handles.xyv_text, 'Position');
    textpos(1) = guipos(3) - textpos(3);
    set( handles.xyv_text, 'Position', textpos );
    set( handles.xyv_text, 'String', str );    
end

function varargout = imslide_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

% ---------------------------------------------------------------%
% Plotting
% ---------------------------------------------------------------%
function handles = show_images( handles )
if handles.isplot1
    x_axes_lim1 = get(handles.axes1, 'Xlim');
    y_axes_lim1 = get(handles.axes1, 'Ylim');
else
    handles.x1  = 1:size(handles.image2show,2 );
    handles.y1  = 1:size(handles.image2show,1 );
    x_axes_lim1 = [1,size(handles.image2show,2 )];
    y_axes_lim1 = [1,size(handles.image2show,1 )];
end

current_axes = handles.axes1;
if get( handles.imslide, 'UserData' )
    [handles, x_axes_lim1, y_axes_lim1] = interpolate_cur_img( handles, x_axes_lim1, y_axes_lim1 );
else
    handles.image2showI = handles.image2show;
end

handles.plot1 = imagesc(handles.x1, handles.y1, handles.image2showI, 'Parent' ,current_axes, 'hittest','off');
set( current_axes, 'CLim', [handles.min_scaling,handles.max_scaling]);
if x_axes_lim1(1) == x_axes_lim1(2)
    if x_axes_lim1(1) == 0
        x_axes_lim1(2) = 1;
    else
        x_axes_lim1(2) = 1.1 * x_axes_lim1(2);
    end
end
if y_axes_lim1(1) == y_axes_lim1(2)
    if y_axes_lim1(1) == 0
        y_axes_lim1(2) = 1;
    else
        y_axes_lim1(2) = 1.1 * y_axes_lim1(2);
    end
end
xlim(current_axes, [x_axes_lim1(1), x_axes_lim1(2)]);
ylim(current_axes, [y_axes_lim1(1), y_axes_lim1(2)]);
colormap( current_axes, handles.cm );

set( handles.axes1, 'xtick',[] );
set( handles.axes1, 'ytick',[] );

if handles.ontop
    try
    setAlwaysOnTop(gcf,1);
    end
end

handles.isplot1 = 1;

function handles = get_image2show( handles )
handles = get_cur_img_ind(handles);

if get( handles.composition, 'Value' )
    s = size(handles.image);
    s = find( s~= 1 );
    s = s(s>2);        
    slider_pos = 1-get( handles.slider2, 'Value');
    slider_step = get( handles.slider2, 'SliderStep');    
    comp_dim = s( round( slider_pos / slider_step(1) + 1) );                        
    
    s = size(handles.image);
    nr_images = s(comp_dim);
    
    str = ['handles.image2show = squeeze( handles.image(:,:,' , handles.cur_img_ind_str, '));'];
    eval(str);
    
    x_subfigures = ceil(nr_images /floor(sqrt(nr_images)));
    y_subfigures = floor(sqrt(nr_images));
    
    if x_subfigures * y_subfigures ~= nr_images
        nr_zero_imgs = x_subfigures * y_subfigures - nr_images;
        handles.image2show = cat( 3, handles.image2show, zeros( s(1), s(2), nr_zero_imgs ) );
    end    
    handles.image2show = reshape( handles.image2show , s(1), s(2)*x_subfigures, y_subfigures );
    handles.image2show = permute( handles.image2show, [2,1,3]);
    handles.image2show = reshape( handles.image2show , size(handles.image2show, 1), [] );
    handles.image2show = permute( handles.image2show, [2,1]);
elseif get( handles.dimension_slider, 'Value' )    
    str = ['handles.image2show = squeeze( handles.image(:,:,' , handles.cur_img_ind_str, '));'];    
    eval(str);
else       
    str = ['handles.image2show = squeeze( handles.image(:,:,' , handles.cur_img_ind_str, '));'];    
    eval(str);
end
handles = update_image_index_text(handles);

function [handles, x_lim, y_lim] = interpolate_cur_img( handles, x_lim, y_lim )
axespos = get( handles.axes1, 'Position' );
axes_height = axespos(4);
axes_width = axespos(3);
handles.image2showI = handles.image2show;

x_range = x_lim(2)-x_lim(1);
y_range = y_lim(2)-y_lim(1);
    
if ~isempty( handles.zoom_state )    
    img_ratio = size( handles.image2show, 1) / size( handles.image2show, 2);
    zoombox_ratio = y_range / x_range;
    if img_ratio > zoombox_ratio
        % expand in first (y) direction
        y_range = img_ratio * x_range;
        y_lim(2) = min( [ size(handles.image2show,1), y_lim(1) + y_range ]);
    elseif img_ratio < zoombox_ratio
        % expand in second (x) direction
        x_range = y_range / img_ratio;
        x_lim(2) = min( [ size(handles.image2show,2), x_lim(1) + x_range ]);
    end
end

max_range = max( [x_range, y_range]);
if ~isempty( handles.zoom_state ) || axes_width ~= size( handles.image2show, 2) || axes_height ~= size( handles.image2show, 1)
    if strcmpi( handles.zoom_state, 'out' )
        x_range = 2*x_range;
        y_range = 2*y_range;
        
        x_lim = [ max( [1, x_lim(1)-x_range/2] ), min( [size(handles.image2show,2), x_lim(2)+x_range/2] )];
        y_lim = [ max( [1, y_lim(1)-y_range/2] ), min( [size(handles.image2show,1), y_lim(2)+y_range/2] )];
    end
    
    x_lim_pix = [ floor( x_lim(1) ), ceil(x_lim(2)) ];
    y_lim_pix = [ floor( y_lim(1) ), ceil(y_lim(2)) ];
    [x, y] = meshgrid( x_lim_pix(1):x_lim_pix(2), y_lim_pix(1):y_lim_pix(2) );
    [xi, yi] = meshgrid( linspace( x_lim(1), x_lim(2), axes_width ), linspace( y_lim(1), y_lim(2), axes_height ) );
    if all( size(x) == [ length( y_lim_pix(1):y_lim_pix(2)), length( x_lim_pix(1):x_lim_pix(2))] ) && ...
        all( size(y) == [ length( y_lim_pix(1):y_lim_pix(2)), length( x_lim_pix(1):x_lim_pix(2))] )
        handles.image2showI = interp2( x,y, handles.image2show( y_lim_pix(1):y_lim_pix(2), x_lim_pix(1):x_lim_pix(2) ), xi, yi );
        handles.x1 = x_lim_pix(1):x_lim_pix(2);
        handles.y1 = y_lim_pix(1):y_lim_pix(2);
    end
end
handles.zoom_state = [];

function handles = get_cur_img_ind(handles)
slider_pos = get( handles.slider1, 'Value');
slider_step = get( handles.slider1, 'SliderStep');

slider_pos2 = 1-get( handles.slider2, 'Value');
slider_step2 = get( handles.slider2, 'SliderStep'); 

handles.slider2_ind = round( slider_pos2 / slider_step2(1) + 1);
handles.slider1_ind  = slider_pos / slider_step(1) + 1;

s = size(handles.image);

if get( handles.composition, 'Value' )   
    s1 = find( s~= 1 );
    s1 = s1(s1>2);            
    comp_dim = s1( handles.slider2_ind );  
    s(comp_dim) = 1 ;
elseif get( handles.dimension_slider, 'Value' )   
    s1 = find( s~= 1 );
    s1 = s1(s1>2);            
    comp_dim = s1( handles.slider2_ind );  
    s1 = ones(size(s));    
    s1(comp_dim) = s(comp_dim);
    s = s1;
else
    comp_dim = length(s)+1;
end

if size( handles.image(:,:,:), 3) > 1
    cur_slice = round(handles.slider1_ind );
    in = zeros( length(s(3:end)),1);
    str = '[';
    for i = 1:length(in)
        str = [str, 'in(', num2str(i), '),'];
    end
    str = str(1:end-1); str = [str, '] = ind2sub( s(3:end), cur_slice );'];
    eval(str);
    handles.dim_size = s(3:end);
else
    in = 1;
end
    
if get( handles.composition, 'Value' )  
    str = [];
    for i = 1:length(in)
        if i == comp_dim - 2
            str = [str, ':,'];            
        else
            str = [str, num2str(in(i)), ','];
        end
    end
    str = str(1:end-1);
    handles.cur_img_ind_str = str;
    handles.cur_img_ind = [];
elseif get( handles.dimension_slider, 'Value' )   
    str = [];
    for i = 1:length(in)
        if i ~= comp_dim - 2
            str = [str, num2str(handles.cur_img_ind(i)), ',' ];  
            
        else
            str = [str, num2str(in(i)), ','];    
            handles.cur_img_ind(i) = in(i);
        end
    end
    str = str(1:end-1);
    handles.cur_img_ind_str = str;      
else    
    str = [];
    for i = 1:length(in)
        str = [str, num2str(in(i)), ','];
    end
    str = str(1:end-1);
    handles.cur_img_ind_str = str;    
    handles.cur_img_ind = in;
end
handles.comp_dim = comp_dim;

function handles = get_dim2hold( handles )
slider_pos2 = 1-get( handles.slider2, 'Value');
slider_step2 = get( handles.slider2, 'SliderStep'); 

handles.slider2_ind = round( slider_pos2 / slider_step2(1) + 1);

s = size(handles.image);
s1 = find( s~= 1 );
s1 = s1(s1>2);
handles.dim2hold = s1( handles.slider2_ind );

function handles = set_slider_step(handles)
if get( handles.composition, 'Value' )    
    s = size(handles.image);
    s = find( s~= 1 );
    s = s(s>2);    
    nr_comp_dims = length(s);
    if nr_comp_dims > 1                
        set(handles.slider2, 'SliderStep', [1/( nr_comp_dims-1), 4/( nr_comp_dims-1)] );
    else
        set( handles.slider2, 'Enable', 'off' );
    end
    
    slider_pos = 1-get( handles.slider2, 'Value');
    slider_step = get( handles.slider2, 'SliderStep');
    comp_dim = s( round( slider_pos / slider_step(1) + 1));
        
    s = size(handles.image);
    s(comp_dim) = 1;
    if length(s) > 2
        nr_images = prod(s(3:end));
    else
        nr_images = 1;
    end
    if nr_images > 1
        set( handles.slider1, 'Value', 0.0 );
        set(handles.slider1, 'SliderStep', [1/( nr_images-1), 4/( nr_images-1)] );
    else
        set( handles.slider1, 'Enable', 'off' );
    end
elseif get( handles.dimension_slider, 'Value' )
    s = size(handles.image);
    s = find( s~= 1 );
    s = s(s>2);     
    nr_comp_dims = length(s);
    if nr_comp_dims > 1                
        set(handles.slider2, 'SliderStep', [1/( nr_comp_dims-1), 4/( nr_comp_dims-1)] );
    else
        set( handles.slider2, 'Enable', 'off' );
    end
    slider_pos = 1-get( handles.slider2, 'Value');
    slider_step = get( handles.slider2, 'SliderStep');    
    dim = s( round( slider_pos / slider_step(1) + 1) );        
    s = size(handles.image);
    nr_images = s(dim);
    if nr_images > 1  
        slider_step = [1/( nr_images-1), 4/( nr_images-1)];
        set(handles.slider1, 'SliderStep',  slider_step);
        cur_slice = handles.cur_img_ind( handles.dim2hold-2 );
        set( handles.slider1, 'Value', (cur_slice-1)*slider_step(1));
    else
        set( handles.slider1, 'Enable', 'off' );
    end
else
    if size(handles.image(:,:,:),3) > 1
        s = size(handles.image);
        set( handles.slider1, 'Enable', 'on' );
        slider_step = [1/( size( handles.image(:,:,:), 3)-1), 4/( size( handles.image(:,:,:), 3)-1)];        
        set(handles.slider1, 'SliderStep', slider_step );
        k = [1 cumprod(s(3:end-1))];
        cur_slice = 1;
        if ~isempty( handles.cur_img_ind )
        for i = 1:length(s(3:end))
            v = handles.cur_img_ind(i);
            cur_slice = cur_slice + (v-1)*k(i);
        end
        end
        set( handles.slider1, 'Value', (cur_slice-1)*slider_step(1));
    else
        set( handles.slider1, 'Enable', 'off' );
    end
end

function handles = update_image_index_text(handles)
str = ['Image: (', handles.cur_img_ind_str, ')'];
guipos = get(handles.imslide, 'Position');
set( handles.image_text, 'Units', 'Characters' )
textpos = get(handles.image_text, 'Position');
textpos(3) = length(str)+1;
set( handles.image_text, 'Position', textpos );
set( handles.image_text, 'Units', 'pixels' )
textpos = get(handles.image_text, 'Position');
textpos(1) = guipos(3) - textpos(3);
set( handles.image_text, 'Position', textpos );
set( handles.image_text, 'String', str );

function handles = get_colormap( handles )
cm_str = get(handles.colormap, 'Value' );
switch cm_str
    case 1 %'Gray'
        cm = gray;
    case 2 %'Jet'
        cm = jet;
    case 3 %'HSV'
        cm = hsv;
    case 4 %'Hot'
        cm = hot;
    case 5 %'Cool'
        cm = cool;
    case 6 %'Spring'
        cm = spring;
    case 7 %'Summer'
        cm = summer;
    case 8 %'Autumn'
        cm = autumn;
    case 9 %'Winter'
        cm = winter;
    case 10 %'Bone'
        cm = bone;
    case 11 %'Copper'
        cm = copper;
    case 12 %'Pink'
        cm = pink;
end
handles.cm = cm;
handles.cm_orig = handles.cm;

function handles = set_brightness_contrast( handles )
exponent = 2;

pos_Max = get(handles.max_clipping,'Value')^exponent;
pos_Min = get(handles.min_clipping,'Value')^exponent;

if pos_Max <= pos_Min
    sp = get(handles.max_clipping, 'SliderStep');
    pos_Max = pos_Min + sp(1)^exponent;
end    

handles.max_scaling = pos_Max*handles.max_img_value+handles.min_img_value;
handles.min_scaling = pos_Min*handles.range_img_value+handles.min_img_value;
if handles.max_scaling == handles.min_scaling
    handles.max_scaling = handles.max_scaling + 0.01*handles.max_scaling;
end
if handles.max_scaling == 0 && handles.min_scaling == 0
    handles.max_scaling = 1;
end

% ---------------------------------------------------------------%
% Gui appearance
% ---------------------------------------------------------------%
function [siz, change_size] = determine_optimal_size( handles, force_resize )
min_size = 192;

scrsz = get(0,'ScreenSize');
scrwidth = scrsz(3);
scrheight = scrsz(4);

if nargin == 1
    force_resize = 0;
end

siz(1) = size(handles.image2show,1);
siz(2) = size(handles.image2show,2);
change_size = 0;

if force_resize || (( siz(1) < min_size && siz(2) < min_size) || ...
        siz(1) > scrheight - 200 || siz(2) > scrwidth -200)
    change_size = 1;
    [ma, ind_ma] = max( [ size( handles.image2show,1 ) / scrheight, size( handles.image2show,2 ) / scrwidth ]);
    if ind_ma == 1
        siz(1) = round( scrheight / 2 );
        siz(2) = round( siz(1) * size( handles.image2show,2 ) / size( handles.image2show,1 ) );
    else
        siz(2) = round( scrwidth / 2 );
        siz(1) = round( siz(2) * size( handles.image2show,1 ) / size( handles.image2show,2 ) );
    end
end
siz = max( [ones(size(siz)); siz]);

function handles = set_gui_size( handles, siz )
scrsz = get(0,'ScreenSize');
scrwidth = scrsz(3);
scrheight = scrsz(4);

gui_width   = siz(2);
gui_height  = siz(1) + handles.taskbar_height + handles.bottom_bar_height;

guipos = get( handles.imslide, 'Position' );
% set(handles.imslide, 'Position', [guipos(1), guipos(2), gui_width, gui_height] );
% guipos = get( handles.imslide, 'Position' );

if guipos(2) + guipos(4) > scrheight
    guipos(2) = scrheight - guipos(4) - 100;    
end
if guipos(1) + guipos(1) > scrwidth
    guipos(1) = scrwidth - guipos(3) - 100;    
end
if guipos(2) < 0 
    guipos(2) = 100;    
end
if guipos(1) < 0
    guipos(1) = 100;    
end

if get( handles.composition, 'Value' ) || get( handles.dimension_slider, 'Value' )
    sidebarpos = get( handles.sidebar, 'Position' );
    gui_width   = gui_width + sidebarpos(3);      
else
%     gui_width = guipos(3);
end

set(handles.imslide, 'Position', [guipos(1), guipos(2), gui_width, gui_height] );
pause(handles.pause_dur);

%set axes position
guipos = get( handles.imslide, 'Position' );
axes_height = guipos(4) - handles.taskbar_height - handles.bottom_bar_height;
if get( handles.composition, 'Value' ) || get( handles.dimension_slider, 'Value' )
    axes_width  = guipos(3) - sidebarpos(3); 
    sliderpos = get(handles.slider2, 'Position');
    y_slider = 5;
    set( handles.slider2, 'Position', ...
        [5, y_slider+1, sliderpos(3), axes_height-10] );
elseif siz(2) < 116 % the minimum width for a matlab figure is 116
    axes_width = siz(2);
else
    axes_width  = guipos(3);
end

y  = handles.bottom_bar_height+1;
x = 0;
set( handles.axes1, 'Position', ...
    [x, y, axes_width, axes_height] );

if axes_width ~= size( handles.image2show,2 ) || axes_height ~= size( handles.image2show,1 )
    set( handles.original_size, 'Value', 0 )
else
    set( handles.original_size, 'Value', 1 )
end
pause(handles.pause_dur);

% ---------------------------------------------------------------%
% Various
% ---------------------------------------------------------------%
function varargout = imsave(h, handles)
%IMSAVE Save Image tool.
%   IMSAVE creates a Save Image tool in a separate figure that is
%   associated with the image in the current figure, called the target
%   image. The Save Image tool displays an interactive file chooser for the
%   user to select a path and filename, and saves the target image to a
%   file.  The file is saved using IMWRITE with the default options.
%
%   If an existing filename is specified or selected, a warning message is
%   displayed.  The user may select Yes to use the filename or No to return
%   to the dialog to select another filename.  If the user selects Yes, the
%   Save Image tool will attempt to overwrite the target file.
%
%   IMSAVE(H) creates a Save Image tool associated with the image specified
%   by the handle H.  H can be an image, axes, uipanel, or figure handle.
%   If H is an axes or figure handle, IMSAVE uses the first image returned
%   by FINDOBJ(H,'Type','image').
%
%   [FILENAME, USER_CANCELED] = IMSAVE(…) returns the full path to the file
%   selected in FILENAME.  If the user presses the Cancel button,
%   USER_CANCELED will be TRUE.  Otherwise, USER_CANCELED will be FALSE.
%
%   The Save Image tool is modal; it blocks the MATLAB command line until
%   the user responds.
%
%   Example
%   -------
%      imshow peppers.png
%      imsave
%
%   See also IMFORMATS, IMWRITE, IMPUTFILE, IMGETFILE.

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/11/24 14:58:23 $

% Get handles
if nargin < 1
  h_fig = get(0,'CurrentFigure');
  h_ax  = get(h_fig,'CurrentAxes');
  h_im  = findobj(h_ax,'Type','image');
else
  iptcheckhandle(h,{'image','axes','figure','uipanel'},mfilename,'h',1);
  h_im = imhandles(h);
  if numel(h_im) > 1
    h_im = h_im(1);
  end
  h_fig = ancestor(h_im,'figure');
end

if isempty(h_im)
  eid = sprintf('Images:%s:noImage',mfilename);
  msg = sprintf('%s expects a current figure containing an image.',...
                upper(mfilename));
  error(eid,'%s',msg);
end

% we expect either 0, 1, or 2 output arguments
if (nargout > 2)
    error('Images:imsave:tooManyOutputs', ...
        'Less than three output arguments expected.');
end

% We need to drawnow or else imputfile can block before previous IMSHOW
% commands have completed
drawnow;

% Display Save Image dialog
[filename, ext, user_canceled] = imputfile;

if ~user_canceled
    % Validate filename and extension
    filename = iptui.validateFileExtension(filename,ext);

    % Get image data
    F = getframe( handles.axes1 );
    data_args{1} = frame2im( F );
    
%     data_args{1} = gray2ind(mat2gray(get(h_im,'CData')));
%     data_args{2} = handles.cm;

    % Write the data
    imwrite(data_args{:},filename,ext);
end

% Assign optional output args if requested
if (nargout > 0)
    varargout{1} = filename;
end
if (nargout > 1)
    varargout{2} = user_canceled;
end

function contextmenu_callback(obj, src, event)

checked = strcmpi( get(obj, 'Checked'), 'on' );
if checked
    set(obj, 'Checked', 'off');
    set(gcf, 'UserData', 0);
else
    set(obj, 'Checked', 'on');
    set(gcf, 'UserData', 1);
end
handles = guidata(gcf);
handles = show_images( handles );

function zoom_post_callback( obj, event )
handles = guidata(gcf);
h = zoom( event.Axes);
handles.zoom_state = get(h, 'Direction');
guidata(gcf, handles);
handles = show_images( handles );

function setAlwaysOnTop(hFig,bool)
%SETALWAYSONTOP  Changes the always-on-top window state.
%   SETALWAYSONTOP(HFIG,TRUE) will make Matlab figure with handle HFIG to 
%   be on top of other windows in the OS even though it might not be in 
%   focus.
%   SETALWAYSONTOP(HFIG,FALSE) will put figure back to normal window state.
%   SETALWAYSONTOP(HFIG) is the same as SETALWAYSONTOP(HFIG,TRUE).
%   Second boolean argument TRUE/FALSE can also be exchanged to numerical
%   1/0.
%   
%   Restrictions:
%       HFIG must have property value: Visible = on.
%       HFIG must have property value: WindowStyle = normal.
%       Swing components must be available in the current Matlab session.
%   
%   Example:
%       hFig = figure;
%       setAlwaysOnTop(hFig,true); % figure is now on top of other windows
%
%   See also FIGURE.

%   Developed by Per-Anders Ekström, 2003-2007 Facilia AB.
warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
error(nargchk(1,2,nargin))
error(javachk('swing',mfilename)) % Swing components must be available.
if nargin==1
    bool = true;
end
if ~ishandle(hFig) || length(hFig)~=1 || ~strcmp('figure',get(hFig,'Type'))
    error('SETALWAYSONTOP:fighandle','First Arg. Must be a Figure-Handle')
end
if strcmp('off',get(hFig,'Visible'))
    error('SETALWAYSONTOP:figvisible','Figure Must be Visible')
end
if ~strcmp('normal',get(hFig,'WindowStyle'))
    error('SETALWAYSONTOP:figwindowstyle','WindowStyle Must be Normal')
end
if isnumeric(bool)
    warning off MATLAB:conversionToLogical
    bool = logical(bool);
    warning on MATLAB:conversionToLogical
end
if ~islogical(bool) || length(bool)~=1
    error('SETALWAYSONTOP:boolean','Second Arg. Must be a Boolean Scalar')
end

% Flush the Event Queue of Graphic Objects and Update the Figure Window.
drawnow expose

% Get JavaFrame of Figure.
fJFrame = get(hFig,'JavaFrame');

% Set JavaFrame Always-On-Top-Setting.
fJFrame.fFigureClient.getWindow.setAlwaysOnTop(bool);

% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function imslide_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to imslide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
