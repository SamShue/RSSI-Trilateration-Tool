function [ d ] = getRSSIDistance( rssi, n, A )
% Log-distance path loss model for estimating distance from RSSI value.

% n = 2.0;    % Path Loss Variable (either 1.8 or 2)
% A = 35;%40;     % Reference RSSI value in -dBm (usually RSSI at 1m away)

d = 10.^((rssi - A)./(10.0.*n));

end

