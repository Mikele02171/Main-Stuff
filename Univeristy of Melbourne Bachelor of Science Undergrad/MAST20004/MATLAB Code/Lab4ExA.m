function [output] = Lab4ExA
% This program simulates nreps repetitions of the following two stage random experiment.
% Firstly we choose a coin at random from an urn containing a mixture of
% different types of biased coins. Initially there are three types of coins present in equal numbers
% with respective probabilities of coming up heads of 0.05, 0.5 and
% 0.95.
% Secondly we toss the selected coin 'ntosses' times (initially 100) and count the number (X) of
% heads obtained.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Set repetitions
nreps=10000;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Set experiment parameters
% Here we set up the urn. The vector 'possvalues' contains the actual probability
% of tossing a head for each of the various types of coins in the urn.
% The vector 'probmasses' contains the respective proportions of coins in
% the urn of the various types.
possvalues=[0.05,0.5,0.95]; 
probmasses=(1/3)*ones(1,3);
% Here we set the number of tosses conducted in stage 2 (initially 100).
ntosses=100;
possnoheads=[0:ntosses];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Simulate experiment
% Here we simulate the experiment and calculate and plot the empirical
% probability mass function ('epmf')for the distribution of X over 'nreps' trials.
% Note that the possible no of heads varies from 0 to ntosses but the corresponding index
% in 'epmf' varies from 1 to ntosses+1 (as an array index cannot take the
% value zero).
epmf=zeros(1,length(possnoheads));
increment=(1/nreps);
for i=1:nreps
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Stage 1
    random_prob_of_head=rand_discrete(possvalues,probmasses,1);
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Stage 2
    numheads=sum(rand(ntosses,1)<random_prob_of_head);
    epmf(numheads+1)=epmf(numheads+1)+increment;  
end
bar(possnoheads, epmf');
figure(1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
