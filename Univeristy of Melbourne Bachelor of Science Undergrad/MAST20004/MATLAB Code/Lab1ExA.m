%This program simulates 'nrep' throws of a two fair die
%and calculates the relative frequency of the events
% (A intersect B) and (A union B) where the events A and B are defined as
% A = first die shows a 1.
% B = sum of the scores is 7.

nreps=500;
AintersectB=0;
AunionB=0;
for i=1:nreps
    dicethrows=randunifd(1,6,2);
    sum=dicethrows(1)+dicethrows(2);
    if dicethrows(1)== 1 & sum==7
        AintersectB=AintersectB+1;
    end
    if dicethrows(1)== 1 | sum==7
        AunionB=AunionB+1;
    end
end
RelFreq_AintersectB=AintersectB/nreps
RelFreq_AunionB=AunionB/nreps



