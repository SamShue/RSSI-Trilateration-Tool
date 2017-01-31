function [ x, y ] = Triangulate( x0, y0, r0, x1, y1, r1, x2, y2, r2 )
%TRIANGULATE Summary of this function goes here
%   Detailed explanation goes here

    [x_points(1:2), y_points(1:2)] = circcirc( x0, y0, r0, x1, y1, r1 );
    [x_points(3:4), y_points(3:4)] = circcirc( x0, y0, r0, x2, y2, r2 );
    [x_points(5:6), y_points(5:6)] = circcirc( x2, y2, r2, x1, y1, r1 );
    x = NaN;
    y = NaN;
    min = inf;
    for ii=1:2
        for jj=3:4
            for kk=5:6
              x_center = (x_points(ii) + x_points(jj) + x_points(kk))/3;
              y_center = (y_points(ii) + y_points(jj) + y_points(kk))/3;
%               dist = pdist2([x_points(ii) x_center],[y_points(ii) y_center],'euclidean');
%               dist = dist + pdist2([x_points(jj) x_center],[y_points(jj) y_center],'euclidean');
%               dist = dist + pdist2([x_points(kk) x_center],[y_points(kk) y_center],'euclidean');
              dist = pdist2([x_points(ii) x_points(jj)],[y_points(ii) y_points(jj)],'euclidean');
              dist = dist + pdist2([x_points(jj) x_points(kk)],[y_points(jj) y_points(kk)],'euclidean');
              dist = dist + pdist2([x_points(kk) x_points(ii)],[y_points(kk) y_points(ii)],'euclidean')
              % Test Junk
              clf;
              hold on;
              axis square;
              axis([-8 8 -8 8]);
              scatter(x_center, y_center, 'black','.');
              scatter(x_points(ii),y_points(ii),'black','x')
              scatter(x_points(jj),y_points(jj),'black','x')
              scatter(x_points(kk),y_points(kk),'black','x')
              %area = tri_area([x_points(ii),y_points(ii)],[x_points(jj),y_points(jj)],[x_points(kk),y_points(kk)]);
              if( dist < min )
                  min = dist;
                  x = (x_points(ii) + x_points(jj) + x_points(kk))/3;
                  y = (y_points(ii) + y_points(jj) + y_points(kk))/3;
              end
            end
        end
    end    

end

