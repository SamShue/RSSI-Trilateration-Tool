function drawCirc(ax_h,x,y,r)
% x and y are the coordinates of the center of the circle
% r is the radius of the circle
% 0.01 is the angle step, bigger values will draw the circle faster but
% you may notice inmperfections (not very smooth)
ang = 0:0.01:2*pi;
xp = r*cos(ang);
yp = r*sin(ang);
plot(ax_h,x+xp, y+yp)
end