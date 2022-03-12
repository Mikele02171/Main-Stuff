% This program simulates buses arriving randomly (exponentially
% distributed times between buses with mean 1). 
% Buses start at midnight (time=0) and arrive at an average rate
% of one per hour.
% Rob arrives at a time uniformly distributed between 11am and 12noon
% and waits for the next bus.
% The program simulates one possible day of this experiment and plots the
% arrival times of the buses, Rob's arrival time (as a vertical line) 
% and three waiting times:
% (a) W_1_2 - wait between first and second bus (provided there are two!)
% (b) W_B_A - wait from last bus before Rob's arrival to first bus after Rob's
% arrival
% (c) W_Rob - how long Rob waits for his bus.

while 1
Busph=1;
Rob_arrives=11+rand;
time=0;
nbuses=0;
clear arrival
    while time<Rob_arrives
        nbuses=nbuses+1;
        wait=randexpo(Busph);
        arrival(nbuses)=time+wait;
        time=arrival(nbuses);
    end
W_Rob=time-Rob_arrives;
if nbuses>1
    W_1_2=arrival(2)-arrival(1);
end
if nbuses==1
    W_B_A=arrival(1);
else
    W_B_A=arrival(nbuses)-arrival(nbuses-1);
end
h=plot(arrival,zeros(1,nbuses),'xr','MarkerSize',6);
Xmax=floor(Rob_arrives+(4/Busph));
axis([0,Xmax,-.1,.8])
set(gca,'YTick',[0,0.1,0.2,0.3])
set(gca,'XTick',[0:Xmax])
set(gca,'YTickLabel',{'Bus arrivals','W_Rob','W_B_A','W_1_2'})
hold on
plot([0,Xmax],[0.1,0.1],':k')
plot([0,Xmax],[0.2,0.2],':k')
plot([0,Xmax],[0.3,0.3],':k')
plot([Rob_arrives,time],[.1,.1],'-g','LineWidth',4);
if nbuses>1
    plot([arrival(1),arrival(2)],[.3,.3],'-b','LineWidth',4);
end
if nbuses==1
    plot([0,arrival(1)],[.2,.2],'-m','LineWidth',4);
else
    plot([arrival(nbuses-1),arrival(nbuses)],[.2,.2],'-m','LineWidth',4);
end
plot([Rob_arrives,Rob_arrives],[-.1,.8],'-.k')
hold off
pause
end