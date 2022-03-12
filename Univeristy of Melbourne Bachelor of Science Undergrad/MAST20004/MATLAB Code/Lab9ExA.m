function [output] = Lab9ExA
% Suitably modified this program will generate observations on the
% bivariate distribution in Tutorial set 8, Question 4.
% You will need to type in the lines to generate the bivariate observations
% as explained in the lab sheet.

% The program plots the 'npts' observations and also plots empirical marginal pdf's for both X and Y.

% You can see another set of observations simply by hitting any key.  You must hold down
% the 'Control' key and hit 'C' to terminate the program.

% You can use this program to check your answer 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Set number of points

npts=400 ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Start indefinite plot loop

while (1) 
    

%%%%%%%%%%%Then generate npts observations on X and Y 

% You will need to add program statements in here which generate npts
% bivariate observations on X and Y as explained in the lab sheet.
% Note that you can generate vectors of npts observations on a uniform
% distribution using the command u=rand(npts,1).  When multiplying vectors 
% to obtain your observations you will need to use the 'elementwise'
% multiplication operator '.*' which is different to matrix
% multiplication '*'.


 
%%%%%%%%%%% Calculate estimate of P(Y<15)

% Uncomment following line to test if the proportion of times Y is less than
% 15 is close to the figure expected from your tutorial solution.  The calculated
% values are printed in the Command Window.

% percent_less_than_15=100*sum(y<15)/npts


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Plot observations and marginal distributions

X=cat(2,x,y);
[n1,ctr1] = hist(X(:,1),20);
[n2,ctr2] = hist(X(:,2),20);
subplot(2,2,2); plot(X(:,1),X(:,2),'.'); axis([0 25 0 25]); h1 = gca;
    
title('Simulated petrol station - Tutorial 8 question 4');
xlabel('Empirical pdf for X'); ylabel('Empirical pdf for Y');
subplot(2,2,4); bar(ctr1,-n1,1); axis([0 25 -max(n1)*1 0]); axis('off'); h2 = gca;
subplot(2,2,1); barh(ctr2,-n2,1); axis([-max(n2)*1 0 0 25]); axis('off'); h3 = gca;
set(h1,'Position',[0.35 0.35 0.55 0.55]);
set(h2,'Position',[.35 .1 .55 .15]);
set(h3,'Position',[.1 .35 .15 .55]);
colormap([.8 .8 1]);
figure(1);
pause;
end