function [x_old, P] = Kfilter2(x_old,P,F,Q,H,z,R,B,u,dt)  
   % Prediction
    x_new = F*x_old;% + B*u;
    P = F*P*F' + Q;

    % Measurement Update
    y = z - (H*x_new);
    S = H*P*H' + R;
    K = P*H'*(S\eye(size(S)));
    x_old = x_new + K*y;
    P = (eye(size(K*H)) - K*H)*P;
end
