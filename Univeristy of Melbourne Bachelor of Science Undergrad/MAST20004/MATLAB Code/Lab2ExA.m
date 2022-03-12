% This program simulates Peter's sophisticated game in which
% he first he rolls a fair die once and notes the score X on it. 
% Then he rolls the die X times and notes all the scores.
% The program calculates the relative frequency of events A, B and (A intersect B),
% You need to add the appropriate sections of code to determine if A, B or
% (A intersect B)occur in any one repetition.

nreps=10000;
Event_A=0;
Event_B=0;
AintersectB=0;
for i=1:nreps
    first_throw=randunifd(1,6,1);  %This line make the first throw.
	
	% Now you need to add in a line which throws the die first_throw times 
	
	    
    % Insert here any lines you need to calculate quantities of 
    % interest which determine your events A and B.    
    
	
	
    %Following code counts no of times Event A occurs:
    if  %Add condition to test if A has occurred
        Event_A=Event_A+1;
    end
    %Following code counts no of times Event B occurs:
    if  %Add condition to test if B has occurred
        Event_B=Event_B+1;
    end
    %Following code counts no of times Event (A intersect B) occurs:
    if % Event A condition  then "&" then Event B condition 
        AintersectB=AintersectB+1;
    end
end
% Following code calculates empirical frequencies and outputs them to the 
% Command window.
RelFreq_A=Event_A/nreps
RelFreq_B=Event_B/nreps
RelFreq_AintersectB=AintersectB/nreps
