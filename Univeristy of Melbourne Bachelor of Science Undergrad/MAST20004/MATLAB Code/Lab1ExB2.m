% This program simulates exactly the same experiment
% as Lab1ExB1.m but instead of plotting the result of
% one day's simulation it simulates nreps days and
% calculates estimates of the average waiting times for
% the three waiting times of interest.

% In addition it offers a choice between exponentially or uniformly distributed
% times between buses both of mean 1 hour.

Busph=1;
nreps=4000;
distribution='exponential'; % type 'uniform' to change distribution
W_1_2count=0;
clear workspace;
for i=1:nreps
time=0;
nbuses=0;
Rob_arrives=11+rand;
clear arrival
   while time<Rob_arrives
        nbuses=nbuses+1;
        if strcmp(distribution,'exponential')
            wait=randexpo(Busph);
        else 
            wait=(2/Busph)*rand;
        end
        arrival(nbuses)=time+wait;
        time=arrival(nbuses);
   end
W_Rob(i)=time-Rob_arrives;
if nbuses>1
    W_1_2count=W_1_2count+1;
    W_1_2(W_1_2count)=arrival(2)-arrival(1);
end
if nbuses==1
    W_B_A(i)=arrival(1);
else
    W_B_A(i)=arrival(nbuses)-arrival(nbuses-1);
end  
end
Mean_W_1_2=mean(W_1_2)
Mean_W_B_A=mean(W_B_A)
Mean_W_Rob=mean(W_Rob)
