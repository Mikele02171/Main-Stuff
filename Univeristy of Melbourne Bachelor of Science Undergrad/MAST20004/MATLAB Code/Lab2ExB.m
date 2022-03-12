% This program simulates a multiple choice exam with 'nreps' questions
% and calculates the relative frequency of events B2 and A as defined on
% lecture slide 77.
% m is the number of choices of answer for each question 
% p is the probability that the student knows the correct answer
% You can use this program to check the formula given on Slide 78 for the
% conditional probability that the student was guessing given that 
% they gave the correct answer.  You can calculate values from the formula
% by hand using a calculator or if you wish add some code to the program so
% it calculates it for you.

nreps=10000;
m=4;
p=0.7;
Event_A=0;
Event_B2=0;
AintersectB2=0;
for i=1:nreps 
    Aoccurs=0;
    B2occurs=0;
    if  rand < p
        Aoccurs=1;
    else
        B2occurs=1;
        if randunifd(1,m)==1
        Aoccurs=1;
        end
    end
    if Aoccurs
        Event_A=Event_A+1;
    end
    if B2occurs
        Event_B2=Event_B2+1;
    end
    if Aoccurs & B2occurs 
        AintersectB2=AintersectB2+1;
    end
end
RelFreq_A=Event_A/nreps
RelFreq_AintersectB2=AintersectB2/nreps
Con_prob=RelFreq_AintersectB2/RelFreq_A




