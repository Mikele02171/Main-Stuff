function [output] = Lab11ExA

% Suitably modified this program will generate estimates of the dfs F_n for
% the standardised random variables Z_n as defined on lecture slide 433.
% Z_n standardises the sample sum S_n = X_1+...+X_n for a sample of size n.
% The Central Limit Theorem tells us that the dfs F_n should tend to the df
% for a standard normal distribution whatever the distribution of the X_i.
 
% For your selected values of n the sequence of df's F_n is plotted on a graph together with the df for a
% standard normal to illustrate this convergence in distribution.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Initialisation section
n=[3, 5, 10, 50];
lambda=0.1;
mu=0.5;
sigma=0.5;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Generate F_n dfs
N=100000;
hold all;
for i=1:length(n)
plot(sort((sum(Finverse(rand(n(i),N),lambda))-n(i)*mu)./(sigma*sqrt(n(i)))),[1/N:1/N:1],'LineWidth',2);
end
x=[-4:0.001:4];
plot(x,0.5*erfc(-x/sqrt(2)),'--k','LineWidth',2);
figure(1);
legend(int2str(n(1)),int2str(n(2)),int2str(n(3)),int2str(n(4)),'Normal');
%%%%%%%%%%%%%%%%%Function RM generates matrix of observations
% on X using the inverse transformation method.

function RM=Finverse(A,lambda)
RM=1*(A<0.5);      
%RM=A;
%RM=(-1/lambda)*log(A);