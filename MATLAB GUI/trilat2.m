function [b] = trilat2( X, d, R )
% X: matrix with APs coordinates
% d: distance estimation vector
warning('off','all');
%p = [];
tbl = table(X, d);
% 
% d2 = d.^2;
% weights = d2.^(-1);  %inversly proportional
weights = rssiPDF(d,R)
%weights = ones(size(d))/length(d); %uniformly proportional

weights = transpose(weights);
beta0 = [5, 5];
modelfun = @(b,X)(abs(b(1)-X(:,1)).^2+abs(b(2)-X(:,2)).^2).^(1/2);
mdl = fitnlm(tbl,modelfun,beta0,'Weights',weights);
b = mdl.Coefficients{1:2,{'Estimate'}};
% warning('on','all');

