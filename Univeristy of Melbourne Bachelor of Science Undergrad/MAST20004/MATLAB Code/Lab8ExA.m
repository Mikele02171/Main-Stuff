function [output] = Lab8ExA
% This program generates observations on a standard bivariate normal
% distribution (X,Y) with population correlation zero using the method
% outlined on lecture slides 299-301. 

% The program plots the 'npts' observations and also plots empirical marginal pdf's for both X and Y.
% From lectures we know that these marginal distributions should be
% standard normal.

% You can see another set of observations simply by hitting any key.  You must hold down
% the 'Control' key and hit 'C' to terminate the program.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Set number of points

npts=500;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Start indefinte plot loop

while (1) 
    
%%%%%%%%%%%Generate the bivariate observations
% We use polar coordinates as explained on lecture slide 344.

%%%%%%%%%%%First generate npts observations on Theta (uniform on [0,2pi])
theta=2*pi*rand(npts,1);

%%%%%%%%%%%Then generate npts observations on R 

% You will need to add program statements in here which generate npts
% observations on R using the inverse transformation method as explained on
% the lab sheet.  Note you generate npts observations on a uniform distribution 
% between 0 and 1 by using the command u=rand(npts,1).
 

%%%%%%%%%%% Now we convert back to cartesian coordinates

x=r.*cos(theta);
y=r.*sin(theta);
 
%%%%%%%%%%% Calculate percentage between -1 and 1 for X and Y
% Uncomment these lines to test if the proportion of observed values for X and Y are
% close to the figure expected for a standard normal distribution.  The
% values are printed in the Command Window.

% xpercent=100*sum((-1<x)&(x<1))/npts
% ypercent=100*sum((-1<y)&(y<1))/npts


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Plot observations and marginal distributions

X=cat(2,x,y);
[n1,ctr1] = hist(X(:,1),20);
[n2,ctr2] = hist(X(:,2),20);
subplot(2,2,2); plot(X(:,1),X(:,2),'.'); axis([-3 3 -3 3]); h1 = gca;
axis equal;
title('Simulated standard bivariate normal');
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