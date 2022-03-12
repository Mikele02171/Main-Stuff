function [output] = Lab7ExA
% This program generates observations on a bivariate random variable
% (X,Y).  The default distribution is standard bivariate normal, 
% so E(X)=E(Y)=0 and V(X)=V(Y)=1.  The program prompts the user to input the population 
% correlation  'rho'.

% The program plots the 'npts' observations of the bivariate random
% variable and also plots empirical marginal pdf's for both X and Y.

% You can see another set of observations simply by hitting any key.  You must hold down
% the 'Control' key and hit 'C' to terminate the program.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Set number of points

npts=100;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Generate the bivariate observations
rhoset=0;
while (1)  
x=randn(npts,1);  % This generates npts observations on a standard normal.
clear y;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Choose one of the following alternative methods for generating Y

% Comment out all methods except the one you choose.  You can do this by
% highlighting the relevant text, then right clicking and choosing
% 'Comment' or 'Uncomment' as appropriate.

%%%%%%%%%%%%%%%%Method 1 - Bivariate normal(population correlation = rho)
if rhoset==0
    rho=input('Please input population correlation');
    if  not((rho>=-1)&(rho<=1))   
    error('Value of p outside permitted range')
    end
    rhoset=1;
end
y=rho*x+sqrt(1-rho^2)*randn(npts,1);

%%%%%%%%%%%%%%%%%Method 2 - 'Degenerate' distribution from Slide 287

% for i=1:npts
%     if rand(1,1) < 0.5
%         y(i)=x(i);
%     else 
%         y(i)=-x(i);
%     end
% end
% y=y';

%%%%%%%%%%%%%%%%%Method 3 - Bivariate point (X, X^2) with X standard normal

%y=x.^2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Plot observations and marginal distributions

X=cat(2,x,y);
[n1,ctr1] = hist(X(:,1),20);
[n2,ctr2] = hist(X(:,2),20);
subplot(2,2,2); plot(X(:,1),X(:,2),'.'); axis([-3 3 -3 3]); h1 = gca;
title('Simulated bivariate observations');
xlabel('Empirical pdf for X'); ylabel('Empirical pdf for Y');
subplot(2,2,4); bar(ctr1,-n1,1); axis([-3 3 -max(n1)*1.1 0]); axis('off'); h2 = gca;
subplot(2,2,1); barh(ctr2,-n2,1); axis([-max(n2)*1.1 0 -3 3]); axis('off'); h3 = gca;
set(h1,'Position',[0.35 0.35 0.55 0.55]);
set(h2,'Position',[.35 .1 .55 .15]);
set(h3,'Position',[.1 .35 .15 .55]);
colormap([.8 .8 1]);
figure(1);
pause;
end