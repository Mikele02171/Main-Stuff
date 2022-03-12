function [output] = Lab10ExB2
% Suitably modified this program will generate nreps observations on 
% Y=psi(X) and produce estimates for E(Y) and V(Y).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Set number of repetitions
nreps=10000 ;

% You will need to add code here which generates the nreps observations on psi(X).
% Store the results in the vector 'observations'.
% Remember that you can generate vectors of nreps observations on a uniform
% distribution using the command rand(nreps,1). You can generate nreps
% observations on a normal distribution with mean mu and variance sigma^2
% using mu+sigma*randn(nreps,1).


%%%%%%%%%%%%%%%%Estimates for mean and variance are calculated.

meanobs=mean(observations)
Varobs=std(observations)^2




