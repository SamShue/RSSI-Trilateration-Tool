function [probability] = rssiPDF(dist, RSSI)

% Open File containing collected data
% % data = xlsread('EPIC Classroom 1249 v2 Horizontal.xlsx');
% % distances = data(2:40,1);
% % measurements = data(2:40,2:end);
files = {'EPIC Classroom 1249 v2 Horizontal.xlsx','EPIC Classroom 1249 v2 Vertical.xlsx'};
for ii = 1:length(files)
    data = xlsread(char(files(ii)));
    distances = data(2:end,1);
    if(~exist('measurements'))
        measurements = data(2:40,2:end);
    else
        measurements = [measurements,data(2:40,2:end)];
    end
end


for ii = 1:length(dist)
    % Find closest values if not passed discrete values
    %==========================================================================
    % Distance
    [c index] = min(abs(distances-dist(ii)));
    dist(ii) = distances(index); % Finds first one only!
    % RSSI
    M = unique(measurements(:));
    [c index] = min(abs(M-RSSI(ii)));
    RSSI(ii) = M(index); % Finds first one only!
    %==========================================================================
    
    % Get PDF for RSSI value from collected data
    [idxRows, idxCols] = find(measurements == RSSI(ii));
    instances = histc(distances(idxRows),unique(distances(idxRows)));
    pdf = instances./sum(instances);
    labels = unique(distances(idxRows));
    
    probability(ii) = 0.001;    % default value

    % find label index associated with passed distance value
    idx = find(labels == dist(ii));
    if(~isempty(idx))
        probability(ii) = pdf(idx);
    end
end