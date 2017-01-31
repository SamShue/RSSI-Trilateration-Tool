function [w] = polifiters(input)
% clc;
% clf;
% clear;

% hold on;
files = {'EPIC Classroom 1249 v2 Horizontal.xlsx','EPIC Classroom 1249 v2 Vertical.xlsx'};%,'EPIC Cafeteria.xlsx','EPIC Classroom 1249.xlsx','EPIC Classroom G256 Front.xlsx','EPIC Foyer.xlsx','EPIC G256 Classroom Sloped.xlsx','EPIC Hallway 1.xlsx','EPIC Hallway 2.xlsx','EPIC Lab 2124.xlsx','EPIC Lab 2236.xlsx','Denny Hallway.xlsx','Denny Lecture Hall 200.xlsx','EPIC Foyer PL2.xlsx','EPIC Hallway 1 PL2.xlsx'};
for ii = 1:length(files)
    data = xlsread(char(files(ii)));
    distances = data(2:40,1);
    if(~exist('measurements'))
        measurements = data(2:40,2:end);
    else
        measurements = [measurements,data(2:40,2:end)];
    end
end
avg_vals = mean(measurements');
% plot(distances,avg_vals,'red');
[len wid] = size(measurements);
% for ii = 1:wid
%     scatter(distances,measurements(:,ii),'.','blue');
% end
n = 2.0;
A = avg_vals(4);

minerr = inf;
for n = 0:0.1:3
    RSSI = 10*n*log10(distances) + A;
    error = mean((avg_vals' - RSSI))^2;
    if(error < minerr)
        minerr = error;
        bestn = n;
    end
end

RSSI = 10*bestn*log10(distances) + A;
% plot(distances,RSSI,'black');


rows = zeros(40,1);
[len, ~] = size(measurements);
for jj = 1:len
    row = measurements(jj,:);
    rows(jj,1) = var(row);
end
% 
% clf;
% clc;
uu = .25:.25:10;
yy = rows;
% bar(uu,yy);

% hold on
n2 = 15;
varval = rows;
[p,S,mu] = polyfit(uu',varval,n2);
x1 = input;
 y1 = polyval(p,uu,S,mu);
 normalizer = max(y1);
% plot(x1,y1,'red')
wb = polyval(p,x1,S,mu);
w = abs(wb)/normalizer;
