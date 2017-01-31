clc;
clear;
clf;

node1 = [0,2,5];
node2 = [2,2,5];
node3 = [0,3,5];

hold on;
% [x,y] = Triangulate(node1(1),node1(2),node1(3), ...
%     node2(1),node2(2),node2(3), ...
%     node3(1),node3(2),node3(3));
% 
scatter(node1(1),node1(2),'red')
scatter(node2(1),node2(2),'blue')
scatter(node3(1),node3(2),'green')

ang = 0:0.01:2*pi;
xp = node1(3)*cos(ang);
yp = node1(3)*sin(ang);        
plot(node1(1)+xp, node1(2)+yp,'red')

xp = node2(3)*cos(ang);
yp = node2(3)*sin(ang);        
plot(node2(1)+xp, node2(2)+yp,'blue')

xp = node3(3)*cos(ang);
yp = node3(3)*sin(ang);        
plot(node3(1)+xp, node3(2)+yp,'green')


X = [node1(1:2);node2(1:2);node3(1:2)];
d = [node1(3);node2(3);node3(3)];
b = trilat(X,d)

scatter(b(1),b(2),'black')
