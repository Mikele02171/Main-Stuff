function [output] = Lab8ExC
% Suitably modified this program will generate observations on the
% bivariate distribution in Homework 8, Question 3.
% You will need to type in the lines to generate the independent
% observations on X and Y as explained in the lab sheet.

% The program plots the 'npts' observations and also plots empirical marginal pdf's for both X and Y.

% You can see another set of observations simply by hitting any key.  You must hold down
% the 'Control' key and hit 'C' to terminate the program.

% You can use this program to check your answer to the homework question by
% computing the probability that X+Y exceeds 1 and comparing it with the
% answer produced by this simulation.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Set number of points

npts=500;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Start indefinite plot loop

while (1) 
    

%%%%%%%%%%%Then generate npts observations on X and Y 

% You will need to add program statements in here which generate npts
% observations on X and Y as explained in the lab sheet.
% Note that you can generate a vector of npts observations on a uniform
% distribution using the command u=rand(npts,1).  For each random variable X and Y
% you will need to generate a vector of uniformly distributed observations and then 
% apply the correct transformations to get observations on X or Y.

 
%%%%%%%%%%% Calculate percentage between 1 and 2 for X+Y

% Uncomment this section to test if the proportion of observed values for X and Y are
% close to the figure expected from your homework solution.  The calculated
% values are printed in the Command Window.
% total=x+y;
% percent_1_2=100*sum((1<total)&(total<2))/npts


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Plot observations and marginal distributions

X=cat(2,x,y);
[n1,ctr1] = hist(X(:,1),20);
[n2,ctr2] = hist(X(:,2),20);
subplot(2,2,2); plot(X(:,1),X(:,2),'.'); axis([0 1 0 1]); h1 = gca;
    
title('Simulated Homework 8 question 3');
xlabel('Empirical pdf for X'); ylabel('Empirical pdf for Y');
subplot(2,2,4); bar(ctr1,-n1,1); axis([0 1 -max(n1)*1 0]); axis('off'); h2 = gca;
subplot(2,2,1); barh(ctr2,-n2,1); axis([-max(n2)*1 0 0 1]); axis('off'); h3 = gca;
set(h1,'Position',[0.35 0.35 0.55 0.55]);
set(h2,'Position',[.35 .1 .55 .15]);
set(h3,'Position',[.1 .35 .15 .55]);
colormap([.8 .8 1]);
figure(1);
pause;
end