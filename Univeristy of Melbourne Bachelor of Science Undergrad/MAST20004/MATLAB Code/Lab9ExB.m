function [output] = Lab9ExB
% This program initially generates observations on a
% point uniformly distributed in the unit square. 
% You will need to modify this program appropriately to answer questions in
% Exercise B as explained in the lab sheet.

% The program plots the 'npts' observations and also plots empirical marginal pdf's for both X and Y.

% You can see another set of observations simply by hitting any key.  You must hold down
% the 'Control' key and hit 'C' to terminate the program.

% You can use this program to check your answer 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Set number of points

npts=500;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Start indefinite plot loop

while (1) 
    

%%%%%%%%%%%Then generate npts observations on X and Y 

% You will add some lines to this section to generate npts
% bivariate observations on U and V as explained in the lab sheet.
% Later you will also need to modify this section to generate observations
% from the marginals assuming independence.

x=rand(npts,1);
y=rand(npts,1);

 
%%%%%%%%%%% Calculate estimates of P(U<0.5) and P(V<0.5)

% Uncomment the following lines to test if the proportion of times U and V are less than
% 0.5 are close to the figures expected from your theoretical marginals.  The calculated
% values are printed in the Command Window.

% u_percent=100*sum(x<0.5)/npts
% v_percent=100*sum(y<0.5)/npts


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Plot observations and marginal distributions

X=cat(2,x,y);
[n1,ctr1] = hist(X(:,1),20);
[n2,ctr2] = hist(X(:,2),20);
subplot(2,2,2); plot(X(:,1),X(:,2),'.'); axis([0 1 0 1]); h1 = gca;
    
title('Exercise B - various distributions within the unit square');
xlabel('Empirical marginal pdf'); ylabel('Empirical marginal pdf');
subplot(2,2,4); bar(ctr1,-n1,1); axis([0 1 -max(n1)*1 0]); axis('off'); h2 = gca;
subplot(2,2,1); barh(ctr2,-n2,1); axis([-max(n2)*1 0 0 1]); axis('off'); h3 = gca;
set(h1,'Position',[0.35 0.35 0.55 0.55]);
set(h2,'Position',[.35 .1 .55 .15]);
set(h3,'Position',[.1 .35 .15 .55]);
colormap([.8 .8 1]);
figure(1);
pause;
end