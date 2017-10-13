function slicer(data,aspect)
%% Function for displaying 3D/4D data sets
%
% INPUT:    - data (either 3D or 4D, with time as 4th dimension)
%           - aspect ratio in vector format (eg: [1 1 3] if z is 3 times
%           larger than x and y.
%
% OUTPUT:   Currently no output is defined.
%
% Functionality
%   - Clicking activates current viewport/subplot
%   - Scrolling lets you skip through slices the active viewport
%   - Right clicking in the image creates a crosshair. The value at this
%   point is reported above the 4th viewport/subplot. In case of 4D data
%   this subplot will also show the signal evolution in the 4th dimension
%   (eg, the time series) of the point at the crosshair.
%   - Vertical dragging changes the display of the 4th dimension in the
%   image. The currently displayed data is indicated by an asterisk in the
%   plot of the 4th dimension. (4D data only)
%   - Arrow buttons scale the image (all viewports simultaneously)
% 
% v1.0 July 2014
% Tim Schakel, Frank Simonis, Bjorn Stemkens.
%
% v1.1 April 2015
% fixed for Matlab2014b & higher

%% Initialize
    if ~isreal(data)
        fprintf('The program will automatically use absolute data.\n');
        data = abs(data);
    end
    
    if nargin < 2
        aspect=[1,1,1];
        egg=0;
    elseif ischar(aspect) && aspect==[80,86]
        aspect=[1,1,1];
        egg=1;
    elseif length(aspect)<3
        aspect=[1,1,1];
        egg=0;
    end

    dim=size(data);
    ndim=length(size(data));

    %Check if datasizes are valid
    if ndim<3 || ndim>4
%plot(        error('Error: cannot handle this type of data. Only 3d or 4d data is allowed');
    end
    k=round(size(data)/2); % Default display are the center slices
    range=[min(data(:)),max(data(:))];
    step=abs(max(data(:))-min(data(:)))/100;
    lastPoint = [];
    whichView = 1;
    crossLoc=[k(1),k(2),k(3)];
    p = [k(2),k(1),k(3)
         k(2),k(1),k(3)];
    offsliceCoord = [3 1 2];
    titleLines = {'Transversal view: ', 'Coronal view: ', 'Sagittal view: '};

%% Make figure
scrsz = get(0,'ScreenSize');
    f1=figure('Position',scrsz,'Name',inputname(1),'Color',[1 1 1],...
        'WindowScrollWheelFcn', @scroller, ....
        'WindowKeyPressFcn',@scale, ...
        'WindowButtonDownFcn', @click);
    
    colormap('gray')
    if ndim==3
        k(4)=1;
        handle{1} = subplot(221);
        imHandles{1} = imagesc(squeeze(data(:,:,k(3))),range);
        set(gca,'DataAspectRatio',[aspect(1) aspect(2) 1])
        axis off
        titleHandles{1} = title(num2str(k(3)),'FontSize',12);

        handle{2} = subplot(222);
        imHandles{2} = imagesc(squeeze(data(k(1),:,:))',range);
        set(gca,'DataAspectRatio',[aspect(3) aspect(1) 1],'YDir','normal')
        axis off
        titleHandles{2} = title(num2str(k(1)),'FontSize',12);

        handle{3} = subplot(223);
        imHandles{3} = imagesc(squeeze(data(:,k(2),:))',range);
        set(gca,'DataAspectRatio',[aspect(3) aspect(2) 1],'YDir','normal')
        axis off
        titleHandles{3} = title(num2str(k(2)),'FontSize',12);

        for i = 1:3
            set(titleHandles{i}, 'String', [sprintf('%s%d', titleLines{i}, k(offsliceCoord(i))),' of ', num2str(dim(offsliceCoord(i)))]);
        end
        
        %Plot a fancy logo in the otherwise empty subplot
        handle{4} = subplot(224);
        patch([0,0,50,50],[0,50,50,0],'white');
        patch([0,50,65,15],[50,50,65,65],'white')
        patch([50,65,65,50],[0,15,65,50],'white')
        for m=[6,9,11,13,13.5,14,14.5,15];
            line([m,50+m],[50+m,50+m],'Color','k');
            line([50+m,50+m],[m,50+m],'Color','k');
        end; 
        axis image off
        if egg
            text(4,25,char([80,114,111,106,101,99,116,32,86]),'FontSize',32,'FontName','Arial')
        else
        text(4,25,'Slicer','FontSize',52,'FontName','Arial')
        end
        value = data(k(1),k(2),k(3)); if value>10^5;value=num2str(value,'%10.4e\n');else value=num2str(value);end
        titleHandles{4} = title({['Crosshair at point [',num2str(k(1)),' ',num2str(k(2)),' ',num2str(k(3)),']. Value: ',value],''}, 'FontSize', 12);
    else
        handle{1} = subplot(221);
        imHandles{1} = imagesc(squeeze(data(:,:,k(3),k(4))),range);
        set(gca,'DataAspectRatio',[aspect(1) aspect(2) 1])
        axis off
        titleHandles{1} = title(['Slice ',num2str(k(3))],'FontSize',12);

        handle{2} = subplot(222);
        imHandles{2} = imagesc(squeeze(data(k(1),:,:,k(4)))',range);
        set(gca,'DataAspectRatio',[aspect(3) aspect(1) 1],'YDir','normal')
        axis off
        titleHandles{2} = title(['Slice ',num2str(k(1))],'FontSize',12);

        handle{3} = subplot(223);
        imHandles{3} = imagesc(squeeze(data(:,k(2),:,k(4)))',range);
        set(gca,'DataAspectRatio',[aspect(3) aspect(2) 1],'YDir','normal')
        axis off
        titleHandles{3} = title(['Slice ',num2str(k(2))],'FontSize',12);

        handle{4} = subplot(224);
        imHandles{4} = plot((1:dim(4)),squeeze(data(k(1),k(2),k(3),:)));
        hold on
        imHandles{5} = plot(k(4),data(k(1),k(2),k(3),k(4)),'r*','MarkerSize',8); hold off
        value = data(k(1),k(2),k(3)); if value>10^5;value=num2str(value,'%10.4e\n');else value=num2str(value);end
        titleHandles{4} = title({['Timeseries at point [',num2str(k(1)),' ',num2str(k(2)),' ',num2str(k(3)), ' ', num2str(k(4)),']. Value: ',value],''}, 'FontSize', 12);
        
        for i = 1:3
            set(titleHandles{i}, 'String', [sprintf('%s%d',titleLines{i}, k(offsliceCoord(i))),' of ', num2str(dim(offsliceCoord(i)))]);
        end
    end
    
    %initialize crosshair and hide it
    x = zeros(2,2);
    y = zeros(2,2);
    subplot(221);
    crossHandle{1} = line(x,y);
    subplot(222);
    crossHandle{2} = line(x,y);
    subplot(223);
    crossHandle{3} = line(x,y);
    for i=1:3
        set(crossHandle{i}, 'Color','red');
        set(crossHandle{i}, 'HandleVisibility', 'off');
    end

%% Click function
    function click(src,evnt)
        p = get(gca, 'CurrentPoint');
        p = round(p);
        s = get(gcf, 'SelectionType');
        lastPoint = [p(1); p(3)];
        
        % Determine in which view was clicked using the lastPoint parameter
        temp=gca;
        if (strfind(temp.Title.String,'Transversal')==1)
            whichView = 1;
        elseif (strfind(temp.Title.String,'Coronal')==1)
            whichView = 2;
        elseif (strfind(temp.Title.String,'Sagittal')==1)
            whichView = 3;
        else
            whichView = 4;
        end
        
        %old cold, still works with older versions, where axes handles
        %and/or cell2mat were different
        %whichView = find(cell2mat(handle) == gca); 
        
        xlim = get(gca, 'XLim');
        ylim = get(gca, 'YLim');
        % If you click outside a figure, nothing will be updated (i.e.
        % the figure you clicked last, will change)
        if lastPoint(1) >= xlim(1) && lastPoint(1) <= xlim(2) && ...
                lastPoint(2) >= ylim(1) && lastPoint(2) <= ylim(2) && whichView ~= 4
          
            %If it's a left click activate window, scaling and scrolling
            if strcmp(s,'normal')
                set(f1, 'WindowButtonMotionFcn', @dragCallback);
                set(f1, 'WindowScrollWheelFcn', @scroller);
                set(f1, 'WindowKeyPressFcn',@scale);
                set(f1, 'WindowButtonUpFcn', @stopdrag);
            
            %If it's a right click activate the crosshair
            elseif strcmp(s,'alt')
                border = [get(gca, 'xlim') get(gca, 'ylim')];
                x = [ border(1) p(1)
                      border(2) p(1) ];
                y = [ p(3)    border(3)
                      p(3)    border(4) ];
                
                set(crossHandle{whichView}(1),'xdata',x(:,1));
                set(crossHandle{whichView}(1),'ydata',y(:,1));
                set(crossHandle{whichView}(2),'xdata',x(:,2));
                set(crossHandle{whichView}(2),'ydata',y(:,2));
                
                if whichView == 1
                    set(crossHandle{1}, 'Visible', 'on');
                    set(crossHandle{2}, 'Visible', 'off');
                    set(crossHandle{3}, 'Visible', 'off');
                    updateTitle(p(3),p(1),k(3),k(4));
                    updateTimeSeries(p(3),p(1),k(3),k(4));
                    crossLoc=[p(3),p(1),k(3)];
                elseif whichView == 2
                    set(crossHandle{2}, 'Visible', 'on');
                    set(crossHandle{1}, 'Visible', 'off');
                    set(crossHandle{3}, 'Visible', 'off');
                    updateTitle(k(1),p(1),p(3),k(4));
                    updateTimeSeries(k(1),p(1),p(3),k(4));
                    crossLoc=[k(1),p(1),p(3)];
                elseif whichView == 3
                    set(crossHandle{3}, 'Visible', 'on');
                    set(crossHandle{1}, 'Visible', 'off');
                    set(crossHandle{2}, 'Visible', 'off');
                    updateTitle(p(1),k(2),p(3),k(4));
                    updateTimeSeries(p(1),k(2),p(3),k(4));
                    crossLoc=[p(1),k(2),p(3)];
                else
                    return %do nothing
                end      
            end
        end
    end

%% Drag function
    function dragCallback(varargin)
        if ndim ==4
            p = get(gca, 'CurrentPoint');
            p = round(p);

            motionV = round([p(1); p(3)] - lastPoint);
            if abs(motionV(2)) < 2
                return
            end
            lastPoint = [p(1); p(3)];
            
            % Update the last dimension of k, the time dimension
            k(4) = k(4)+round(motionV(2)/2);
            if k(4) > size(data,4);
                k(4) =1;
            elseif k(4)<1
                k(4)=size(data,4);
            end;
            
            % REMARK, update the title name with the dynamic name
            set(imHandles{1}, 'CData', squeeze(data(:,:,k(3),k(4)))); %XY view (transversal)
            set(imHandles{2}, 'CData', squeeze(data(k(1),:,:,k(4)))'); %YZ view (coronal)
            set(imHandles{3}, 'CData', squeeze(data(:,k(2),:,k(4)))'); %XZ view (sagittal)
            %Set asterisk
            old_Ydat = get(imHandles{4},'Ydata');
            set(imHandles{5},'YData',old_Ydat(k(4)),'XData',k(4));
            updateTitle(crossLoc(1),crossLoc(2),crossLoc(3),k(4));
        else
            return %dragging only does something with 4D datasets
        end;
    end

%% Stop drag function
% Will execute when mousebutton is released: 'buttonUp'
    function stopdrag(varargin)      
        set(f1,'WindowButtonMotionFcn','');
        p = get(gca, 'CurrentPoint');
        p=round(p);
        s = get(gcf, 'SelectionType');
        if strcmp(s,'alt')
            lastPoint = [p(1); p(3)];
            
            temp=gca;
            if (strfind(temp.Title.String,'Transversal')==1)
                whichView = 1;
            elseif (strfind(temp.Title.String,'Coronal')==1)
                whichView = 2;
            elseif (strfind(temp.Title.String,'Sagittal')==1)
                whichView = 3;
            else
                whichView = 4;
            end
            %whichView = find(cell2mat(handle) == gca);
            
            xlim = get(gca, 'XLim');
            ylim = get(gca, 'YLim');
            % If you click outside a figure, nothing will be updated (i.e.
            % the figure you clicked last, will change)
            if lastPoint(1) >= xlim(1) && lastPoint(1) <= xlim(2) && ...
                    lastPoint(2) >= ylim(1) && lastPoint(2) <= ylim(2)
                if ndim==4
                    if whichView == 1
                        updateTimeSeries(p(3),p(1),k(3),k(4));
                        updateTitle(p(3),p(1),k(3),k(4));
                    elseif whichView == 2
                        updateTimeSeries(k(1),p(1),p(3),k(4));
                        updateTitle(k(1),p(1),p(3),k(4));
                    elseif whichView == 3
                        updateTimeSeries(p(1),k(2),p(3),k(4));
                        updateTitle(p(1),k(2),p(3),k(4));
                    end
                    if whichView == 1 && p(1) == 18 && p(3) == 17
                        figure('Name','Such Wow'); spy
                    end
                else %dim=3
                    if whichView == 1
                        updateTitle(p(3),p(1),k(3),k(4));
                    elseif whichView == 2
                        updateTitle(k(1),p(1),p(3),k(4));
                    elseif whichView == 3
                        updateTitle(p(1),k(2),p(3),k(4));
                    end
                end
            end
        end
    end   

%% Scroll function
    function scroller(src,evnt)
        % Callback function to scroll through the images, update the
        % coordinates within k
        if evnt.VerticalScrollCount>0;
            newslice = k(offsliceCoord(whichView)) - 1;
        else
            newslice = k(offsliceCoord(whichView)) + 1;
        end
        upDateSlice(newslice)
    end

%% Function
    function upDateSlice(newslice)
        % Update the slice.
        % If you are moving in the xy plane, the update should be in the z
        % direction, etc.        
        if newslice > 0 && newslice <= dim(offsliceCoord(whichView))
            k(offsliceCoord(whichView)) = newslice;
        end
        subplot(handle{whichView});
        if ndim==3
            if whichView == 1
                set(imHandles{1}, 'CData', squeeze(data(:,:,k(3))));
                updateTitle(p(3),p(1),k(3),1);
                
            elseif whichView == 2
                set(imHandles{2}, 'CData', squeeze(data(k(1),:,:))');
                updateTitle(k(1),p(1),p(3),1);
            else
                set(imHandles{3}, 'CData', squeeze(data(:,k(2),:))');
                updateTitle(p(1),k(2),p(3),1);
            end
        else
            if whichView == 1
                set(imHandles{1}, 'CData', squeeze(data(:,:,k(3),k(4))));
                updateTitle(p(3),p(1),k(3),k(4));
                updateTimeSeries(p(3),p(1),k(3),k(4));
            elseif whichView == 2
                set(imHandles{2}, 'CData', squeeze(data(k(1),:,:,k(4)))');
                updateTitle(k(1),p(1),p(3),k(4));
                updateTimeSeries(k(1),p(1),p(3),k(4));
            else
                set(imHandles{3}, 'CData', squeeze(data(:,k(2),:,k(4)))');
                updateTitle(p(3),k(2),p(1),k(4));
                updateTimeSeries(p(1),k(2),p(3),k(4));
            end
        end
        set(titleHandles{whichView}, 'String', ...
            [sprintf('%s%d', titleLines{whichView}, k(offsliceCoord(whichView))),' of ', num2str(dim(offsliceCoord(whichView)))]);
    end

    function updateTitle(k1,k2,k3,k4)
        if ndim==3
            value=data(k1,k2,k3); 
            if value>10^5; %set precision for large numbers
                value=num2str(value,'%10.4e\n');
            else
                value=num2str(value);
            end
            set(titleHandles{4}, 'String', {['Crosshair at point [',num2str(k1),' ',num2str(k2),' ',num2str(k3),']. Value: ',value],''});
            
        else
            value=data(k1,k2,k3,k4); 
            if value>10^5;
                value=num2str(value,'%10.4e\n');
            else
                value=num2str(value);
            end
            set(titleHandles{4}, 'String', {['Timeseries at point [',num2str(k1),' ',num2str(k2),' ',num2str(k3), ' ', num2str(k4),']. Value: ',value],''});
        end
    end

    function updateTimeSeries(k1,k2,k3,k4)
        if ndim==4
            set(imHandles{4}, 'YData',squeeze(data(k1,k2,k3,:)));
            set(imHandles{5}, 'YData',squeeze(data(k1,k2,k3,k4)),'XData',k4);
        end
    end

%% Keyboard functions
    function scale(src,evnt)
        % Scaling function
        if strcmp(evnt.Key,'downarrow');
            range(1)=range(1)-step;            
        elseif strcmp(evnt.Key,'uparrow');
            range(1)=range(1)+step;
            if range(1)>range(2)
                range(1)=range(2)-1;
            end
        elseif strcmp(evnt.Key,'leftarrow');
            range(2)=range(2)-step;
            if range(2)<range(1)
                range(2)=range(1)+1;
            end
        elseif strcmp(evnt.Key,'rightarrow');
            range(2)=range(2)+step;
        else
            %donothing
        end
            
        % To be able to update CLim, one has to grab the subplots, and
        % update the CLim range
        for c = get(f1,'Children')
            try
                set(c,'CLim',range)
%                 save('CLimRange.mat','range'); %save the CLim to file for later use
            catch exception
                continue
            end
        end
    end

end