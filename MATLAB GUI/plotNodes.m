function plotNodes(hObject,handles)
cla(handles.nodes_axes);
hold(handles.nodes_axes, 'on');
axes(handles.nodes_axes);
axis(handles.nodes_axes,'square');
% set(,'WindowStyle','modal')
% Find minimum and maximum x and y values in node positions and set plot
% limits
for ii = 1:length(handles.nodeData)
    xpoints(ii) = double(handles.nodeData(ii).pos(1));
    ypoints(ii) = double(handles.nodeData(ii).pos(2));
end
% include mobile node positions in setting x and y boundries of graph
if(~isempty(handles.mobileData(1).pos))
    for jj = 1:length(handles.mobileData)
        ii = ii + 1;
        xpoints(ii) = double(handles.mobileData(jj).pos(1));
        ypoints(ii) = double(handles.mobileData(jj).pos(2));
    end
end
% include user points in setting x and y boundries of graph
if(isfield(handles,'points'))
    [len,~] = size(handles.points);
    for jj = 1:len
        ii = ii + 1;
        xpoints(ii) = handles.points(jj,1);
        ypoints(ii) = handles.points(jj,2);
    end
end
pts = max([xpoints, ypoints]);
scale = 1.1;
axis(handles.nodes_axes,[-pts pts -pts pts].*scale);
for ii = 1:length(handles.nodeData)
    % Plot node location if location exists
    if(~isempty(handles.nodeData(ii).pos))
        scatter(handles.nodes_axes,[handles.nodeData(ii).pos(1)],[handles.nodeData(ii).pos(2)],'black')
        text([handles.nodeData(ii).pos(1)],[handles.nodeData(ii).pos(2)],num2str([handles.nodeData(ii).addr]), ...
            'VerticalAlignment', 'bottom', 'Parent', handles.nodes_axes);
    end
end
% if draw circles checkbox is checked
if(get(handles.drawCirclesCheck,'Value'))
    idx = get(handles.mobileNodeList,'Value');
    if(~isempty(handles.mobileData(idx).addr))
        for ii = 1:length(handles.mobileData(idx).anchorData)
            ang = 0:0.01:2*pi;
            xp = handles.mobileData(idx).anchorData(ii).dist*cos(ang);
            yp = handles.mobileData(idx).anchorData(ii).dist*sin(ang);        
            plot(handles.nodes_axes, handles.mobileData(idx).anchorData(ii).pos(1)+xp, handles.mobileData(idx).anchorData(ii).pos(2)+yp);
        end
    end
end
            
            
% Plot user added points if they exist
if(isfield(handles,'points'))
    [len, ~] = size(handles.points);
    for jj = 1:len
        scatter(handles.nodes_axes,handles.points(jj,1),handles.points(jj,2),'red','x');
        text([handles.points(jj,1)],[handles.points(jj,2)],char([handles.pointslabel(jj)]), ...
            'VerticalAlignment', 'bottom', 'Parent', handles.nodes_axes);
    end
end

% Plot Trilaterated Position
for ii = 1:length(handles.mobileData)
    if(~isempty(handles.mobileData(ii).pos))
        scatter(handles.nodes_axes, handles.mobileData(ii).pos(1),handles.mobileData(ii).pos(2));
        text([handles.mobileData(ii).pos(1)],[handles.mobileData(ii).pos(2)],sprintf('Mobile Node\n[%0.2f,%0.2f]',handles.mobileData(ii).pos(1),handles.mobileData(ii).pos(2)), ...
            'VerticalAlignment', 'bottom', 'Parent', handles.nodes_axes);
        text([handles.mobileData(ii).pos(1)],[handles.mobileData(ii).pos(2)],handles.mobileData(ii).addr, ...
            'VerticalAlignment', 'top', 'Parent', handles.nodes_axes);
    end
end

% Plot Position History
if(get(handles.posHistCheckbox,'Value'))
    idx = get(handles.mobileNodeList,'Value');
    if(isfield(handles.mobileData(idx),'posHist'))
        [len,~] = size(handles.mobileData(idx).posHist);
        for ii = 1:len
            scatter(handles.nodes_axes, handles.mobileData(idx).posHist(ii,1),handles.mobileData(idx).posHist(ii,2),'blue','x');
        end
    end
end

guidata(hObject, handles);