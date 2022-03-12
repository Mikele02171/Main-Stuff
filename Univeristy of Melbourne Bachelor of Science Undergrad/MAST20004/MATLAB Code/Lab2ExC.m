% This program simulates the HIV testing experiment discussed on lecture
% slides 70-73 for 'nreps' repetitions.
% p is the probability that a randomly chosen person has HIV.
% H is the event that the person actually is HIV positive. 
% A is the event that their test says they are HIV positive.
% You can use this program to check the result given on Slide 72 for the
% conditional probability that the person has the disease given that 
% they tested positive.

nreps=1000000;
p=0.0001;
Event_A=0;
Event_H=0;
AintersectH=0;
for i=1:nreps 
    Aoccurs=0;
    Hoccurs=0;
    if  rand < p
        Hoccurs=1;
        if rand < 0.9
            Aoccurs=1;
        end
    else
       if rand < 0.05
          Aoccurs=1;
       end
   end
    if Aoccurs
        Event_A=Event_A+1;
    end 
    if Hoccurs
        Event_H=Event_H+1;
    end
    if Aoccurs & Hoccurs 
        AintersectH=AintersectH+1;
    end
end
RelFreq_A=Event_A/nreps
RelFreq_AintersectH=AintersectH/nreps
Con_prob=RelFreq_AintersectH/RelFreq_A




