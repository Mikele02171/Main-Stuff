 function [output] = Lab3ExB
% This program simulates 'nrep' throws of a two fair die
% and plots the empiricial and theoretical probabiity mass functions (pmf's) for any 
% random variable (RV) of your choice.  You need to type in
% the formula for calculating your chosen random variable and the theoretical pmf.
% The RV formula is typed into the function 'myrv' at the end of this
% program.

% The program also calculates the exact first and second moments
% of your random variable using the theoretical pmf for use in Exercise C.
% The output appears in the Matlab command window.

%%%%%%%%%%%%%%%%%%%%%%%%%%%No of repetitions
nreps=1000;

%%%%%%%%%%%%%%%%%%%%%%%%%%Theoretical pmf 
% The following lines define the theoretical pmf for the default RV = sum of the two
% die. Please change the appropriate vectors to input the theoretical pmf
% for your chosen RV. Put the possible values in increasing order.
possiblevalues=[2:12];
probabilitymasses=(1/36)*[1,2,3,4,5,6,5,4,3,2,1];

%%%%%%%%%%%%%%%%%%%%%%%%%%Theoretical moments
% This section calculates the first and second moments of RV using the
% theoretical pmf.
if length(possiblevalues) ~= length(probabilitymasses)
    display('Error in theoretical pmf')
    error('Number of possible values differs from number of probability masses')
else
    sum=0;
    sum2=0;
    for i=1:length(possiblevalues)
        sum=sum+possiblevalues(i)*probabilitymasses(i);
        sum2=sum2+(possiblevalues(i)^2)*probabilitymasses(i);
    end
    display(sprintf('Theoretical E(RV) is %8.3f',sum));
    display(sprintf('Theoretical E(RV^2) is %8.3f',sum2));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%Empirical pmf
% This section simulates the empirical pmf for your chosen random variable
% using 'nreps' repetitions of the experiment and plots it in a bar chart
% together with the theoretical pmf.
epmf=zeros(1,length(possiblevalues));
increment=(1/nreps);
for i=1:nreps
    dicethrows=randunifd(1,6,2);
    RV=myrv(dicethrows(1),dicethrows(2)); %type your defintion into myrv function below
    for j=1:length(possiblevalues)
        if possiblevalues(j)==RV
            epmf(j)=epmf(j)+increment;
        end
    end
 end
M=cat(2,probabilitymasses',epmf');
bar(possiblevalues, M);
legend('Theoretical','Simulation');
figure(1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function RV=myrv(die1,die2)
% Change the following line to calculate your RV
% using the variables die1 and die2.
% Program defaults to using the sum of the two die.
RV=die1+die2;
