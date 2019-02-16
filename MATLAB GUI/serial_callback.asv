function serial_callback(serialObject,event,hObject,handles)
handles = guidata(hObject);

[data count msg] = fread(serialObject,1);

if(numel(data))
    if(data(1)==hex2dec('F0'))
        %fprintf(data(1));
        %feval(s{1}, event, eventStruct, s{2:end});
        len = fread(serialObject, 1);   % Get length of packet delivered
        bufS = fread(serialObject, len);
        
        mobileAddr = sprintf('%X',bufS(1:4)); % Transmitting mobile node address
        % Parse bufS into rssi values and anchor addresses
        jj = 1;
        addrs = {};
        rssi = [];
        for ii = 5:5:len
            rssi(jj) = bufS(ii);
            addrs(jj) = {sprintf('%X',bufS((ii+1):(ii + 4)))};
            jj = jj + 1;
        end
        
        % Loop through all mobile nodes until a match is found
        mobileIdx = [];
        if(isempty(handles.mobileData(1).addr)) % If first time, initialize data structure
            handles.mobileData(1).addr = mobileAddr;
            % Add mobile node to mobile node list
            nodeString = {mobileAddr}; 
            set(handles.mobileNodeList, 'string', nodeString);
            for ii = 1:length(rssi) % add rssi and anchor addr
                handles.mobileData(1).anchorData(ii).addr = char(addrs(ii));
                handles.mobileData(1).anchorData(ii).rssi = rssi(ii);
                handles.mobileData(1).anchorData(ii).dist = getRSSIDistance(rssi(ii), handles.n, handles.A);
                handles.mobileData(1).anchorData(ii).rssiAvg = [];
                handles.mobileData(1).anchorData(ii).freshness = 1;
% %                 handles.mobileData(1).anchorData(ii).weight = 1;
            end
            % Find anchor positions and add them to anchorData
            for jj = 1:length(handles.mobileData(1).anchorData)
                for kk = 1:length(handles.nodeData)
                    if(strcmp(handles.nodeData(kk).addr,handles.mobileData(1).anchorData(jj).addr))
                        handles.mobileData(1).anchorData(jj).pos = handles.nodeData(kk).pos;
                    end
                end
            end
        else
            % Find existing match for mobile node address
            for ii = 1:length(handles.mobileData)
                if(strcmp(handles.mobileData(ii).addr,mobileAddr))
                    mobileIdx = ii;
                end
            end
            if(isempty(mobileIdx))  % mobile address not found, append new mobile node
                handles.mobileData(ii+1).addr = mobileAddr;
                % add mobile node to mobile node list
                nodeString = get(handles.mobileNodeList,'string');
                nodeString = [nodeString;{sprintf('%X',mobileAddr)}]; 
                set(handles.mobileNodeList, 'string', nodeString);
                for jj = 1:length(rssi) % add rssi and anchor addr
                    handles.mobileData(ii+1).anchorData(jj).addr = char(addrs(jj));
                    handles.mobileData(ii+1).anchorData(jj).rssi = rssi(jj);
                    handles.mobileData(ii+1).anchorData(jj).dist = getRSSIDistance(rssi(jj), handles.n, handles.A);
                    handles.mobileData(ii+1).anchorData(jj).rssiAvg = [];
                    handles.mobileData(ii+1).anchorData(jj).freshness = 1;
% %                     handles.mobileData(ii+1).anchorData(ii).weight = 1;
                end
                % Find anchor positions and add them to anchorData
                for ii = 1:length(handles.mobileData)
                    for jj = 1:length(handles.mobileData(ii).anchorData)
                        for kk = 1:length(handles.nodeData)
                            if(strcmp(handles.nodeData(kk).addr,handles.mobileData(ii).anchorData(jj).addr))
                                handles.mobileData(ii).anchorData(jj).pos = handles.nodeData(kk).pos;
                            end
                        end
                    end
                end
            else % mobile node address match found
                % Update matching mobile node structure
                for ii = 1:length(rssi) % loop through all stored anchorData addresses
                    hit = 0;
                    for jj = 1:length(handles.mobileData(mobileIdx).anchorData)
                        if(strcmp(char(handles.mobileData(mobileIdx).anchorData(jj).addr),char(addrs(ii))))
                            if(length(handles.mobileData(mobileIdx).anchorData(jj).rssi) >= handles.histlen)
                                % if filter length is filled, shift and average
                                handles.mobileData(mobileIdx).anchorData(jj).rssi = circshift(handles.mobileData(mobileIdx).anchorData(jj).rssi,1);
                                handles.mobileData(mobileIdx).anchorData(jj).rssi(end) = rssi(ii);
                                if(get(handles.avgfiltbutton,'Value'))  % if averaging filter is on
                                    if(length(handles.mobileData(mobileIdx).anchorData(jj).rssi) >= handles.avgfiltlen) % if filter length hasn't been filled
                                        handles.mobileData(mobileIdx).anchorData(jj).rssiAvg = mean(handles.mobileData(mobileIdx).anchorData(jj).rssi((end - handles.avgfiltlen):end));
                                        handles.mobileData(mobileIdx).anchorData(jj).dist = getRSSIDistance(handles.mobileData(mobileIdx).anchorData(jj).rssiAvg, handles.n, handles.A);
                                    else
                                        handles.mobileData(mobileIdx).anchorData(jj).dist = getRSSIDistance(mean(handles.mobileData(mobileIdx).anchorData(jj).rssi), handles.n, handles.A);
                                    end
                                    else
                                    handles.mobileData(mobileIdx).anchorData(jj).dist = getRSSIDistance(handles.mobileData(mobileIdx).anchorData(jj).rssi(end), handles.n, handles.A);
                                end
                            else
                                % if history len not yet reached, append
                                handles.mobileData(mobileIdx).anchorData(jj).rssi = [handles.mobileData(mobileIdx).anchorData(jj).rssi; rssi(ii)];
                                if(get(handles.avgfiltbutton,'Value'))  % if averaging filter is on
                                    if(length(handles.mobileData(mobileIdx).anchorData(jj).rssi) > handles.avgfiltlen) % if filter length hasn't been filled
                                        handles.mobileData(mobileIdx).anchorData(jj).rssiAvg = mean(handles.mobileData(mobileIdx).anchorData(jj).rssi((end - handles.avgfiltlen):end));
                                        handles.mobileData(mobileIdx).anchorData(jj).dist = getRSSIDistance(handles.mobileData(mobileIdx).anchorData(jj).rssiAvg, handles.n, handles.A);
                                    else
                                        handles.mobileData(mobileIdx).anchorData(jj).dist = getRSSIDistance(mean(handles.mobileData(mobileIdx).anchorData(jj).rssi), handles.n, handles.A);
                                    end
                                else
                                    handles.mobileData(mobileIdx).anchorData(jj).dist = getRSSIDistance(handles.mobileData(mobileIdx).anchorData(jj).rssi(end), handles.n, handles.A);
                                end
                            end
                            hit = 1;
                            handles.mobileData(mobileIdx).anchorData(jj).freshness = 1;
                        end
                    end
                    if(hit == 0)    % Anchor address not previously associated with this mobile node
                        % add anchor info
                        handles.mobileData(mobileIdx).anchorData(jj+1).addr = char(addrs(ii));
                        handles.mobileData(mobileIdx).anchorData(jj+1).rssi = rssi(ii);
                        handles.mobileData(mobileIdx).anchorData(jj+1).dist = getRSSIDistance(rssi(ii), handles.n, handles.A);
                        handles.mobileData(mobileIdx).anchorData(jj+1).rssiAvg = [];
                        handles.mobileData(mobileIdx).anchorData(jj+1).freshness = 1;
                    end
                end
            end
        end
    end % end F0 search


    % Get Trilaterated position if possible
    %==========================================================================
    for ii = 1:length(handles.mobileData)
        % Position (X) and distance (d) vectors for trilateration
        X = []; d = []; idxList = []; R = [];
        for jj = 1:length(handles.mobileData(ii).anchorData)
            % find anchor node in anchor list to retrive position
            for kk = 1:length(handles.nodeData)
                % If a listed anchor is found, record position and distance in
                % vectors
                if(strcmp(handles.nodeData(kk).addr,handles.mobileData(ii).anchorData(jj).addr))
    %                 handles.mobileData(ii).anchorData(jj).pos = handles.nodeData(kk).pos;
                    % Expired data will be set empty, only use valid data
                    %if(~isempty(handles.mobileData(ii).anchorData(jj).dist))
                    if(handles.mobileData(ii).anchorData(jj).freshness) % Only use the freshest data
                        X = [X;handles.nodeData(kk).pos];
                        d = [d;handles.mobileData(ii).anchorData(jj).dist];
                        R = [R;handles.mobileData(ii).anchorData(jj).rssi(end)];
                        handles.mobileData(ii).anchorData(jj).freshness = 0;
    % %                     idxList = [idxList;jj];
                    end
                end
            end
        end
        % Trilaterate mobile(ii)'s position
    %     handles.mobileData(ii).pos = trilat(X,d);
        if(length(d) > 1)   % Safety check
            handles.mobileData(ii).pos = trilat2(X,d,R);
        end

        % Store position history
        if(~isfield(handles.mobileData(ii),'posHist'))  % Create variable
            handles.mobileData(ii).posHist(1,:) = handles.mobileData(ii).pos;
        else
            if(length(handles.mobileData(ii).posHist) >= 10)
                handles.mobileData(ii).posHist = circshift(handles.mobileData(ii).posHist,[-1 0]);
                handles.mobileData(ii).posHist(10,:) = handles.mobileData(ii).pos;
            else
                [len,~] = size(handles.mobileData(ii).posHist);
                handles.mobileData(ii).posHist(len+1,:) = handles.mobileData(ii).pos;
            end
        end

    end
    %--------------------------------------------------------------------------

    plotNodes(hObject,handles)
    drawnow;

    guidata(hObject, handles);

    % Update handles structure
    guidata(hObject, handles);
end %end numel(data)