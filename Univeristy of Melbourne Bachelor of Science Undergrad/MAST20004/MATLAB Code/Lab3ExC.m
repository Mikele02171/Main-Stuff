function [output] = Lab3ExC
% This program simulates 'nrep' throws of a two fair die
% and calculates empiricial estimates for the first and second moments for any 
% random variable (RV) of your choice.  You need to type in
% the formula for calculating your chosen random variable.
% This formula is typed into the function 'myrv' at the end of this
% program.
% The output appears in the Matlab command window.

%%%%%%%%%%%%%%%%%%%%%%%%%%%No of repetitions
nreps=10000;

%%%%%%%%%%%%%%%%%%%%%%%%%%Empirical moments
% This section calculates the empirical moments for your chosen random variable
% using 'nreps' repetitions of the experiment.
sum=0;
sum2=0;
for i=1:nreps
    dicethrows=randunifd(1,6,2);
    RV=myrv(dicethrows(1),dicethrows(2)); %type your defintion into myrv function below
    sum=sum+RV;
    sum2=sum2+RV^2;
 end
EstERV=sum/nreps;
EstERV2=sum2/nreps;
display(sprintf('Estimated E(RV) is %8.3f',EstERV));
display(sprintf('Estimated E(RV^2) is %8.3f',EstERV2));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function RV=myrv(die1,die2)
% Change the following line to calculate your RV
% using the variables die1 and die2.
% Program defaults to using the sum of the two die.
RV=die1+die2;
