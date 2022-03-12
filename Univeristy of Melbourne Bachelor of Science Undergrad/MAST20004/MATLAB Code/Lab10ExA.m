function [output] = Lab10ExA
% Suitably modified this program will generate observations on the
% total claims T on an insurance company in one day.
% You will need to type in the code to generate the individual claims as
% explained in the lab sheet.
% The number of claims N in one day is Poisson (10) and independent of the
% claim sizes.

% This program produces estimates for E(T) and V(T) and also plots the
% empirical pdf for T.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Set number of repetitions
nreps=10000 ;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Initialise
lambda=0.5;
%%%%%%%%%%%Generate observations on T and estimate E(T),V(T) and empirical
%%%%%%%%%%%pdf

for i=1:nreps
   
%%%%%%%%%%%%%Generate N
N=randpois(10,1);
%%%%%%%%%%%%%Generate and sum N claims

% You will need to add one line of code here which generates and sum N claims.
% To generate observations on the exponentially distributed claims use the inverse
% transformation method.  Remember that you can generate vectors of N observations on a uniform
% distribution using the command rand(N,1).  You need to store the
% observed total claims in T(i) for each repetition i so that the mean and
% variance can be calculated later.

end
Tmean=mean(T)
VarT=std(T)^2
hist(T,50);
figure(1)


