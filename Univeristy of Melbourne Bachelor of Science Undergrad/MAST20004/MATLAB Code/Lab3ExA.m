function [output] = Lab3ExA
% For the random experiment of throwing two fair die, this program illustrates
% the partition of the sample space 'generated' by any random variable RV
% of your choice (you must type in the formula for calculating RV)
% As in lecture slide 84 for the random variable RV=X we define the
% events A_x as the subset of outcomes for which X takes the value x.
% The set of events A_x as x varies over all possible
% values of X is the partition of the sample space 'generated' by X.

num=0;
pvalues=[];
colordef black;
for die1=1:6
    for die2=1:6
        % Change the following line to calculate value of any random variable
        % (RV)of your choice. The program defaults to calculating
        % the sum of the two die (RV=die1+die2)
        RV=myrv(die1,die2);
        num=num+1;
        x(num)=die1;
        y(num)=die2;
        z(num)=RV; 
        present=0;
        for i=1:length(pvalues)
            if RV==pvalues(i) 
                present=1;
            end
        end
     if present==0
         pvalues(length(pvalues)+1)=RV;
     end
    end
end
if length(pvalues)<=6
M=[  1.0000    1.0000         0
         0    1.0000    1.0000
    1.0000         0    1.0000
    1.0000         0         0
         0    0.5020    1.0000
         0    1.0000         0];
     colormap(M);
else 
    if length(pvalues)<=11
 M=[  1.0000    1.0000         0
         0    1.0000    1.0000
    1.0000         0    1.0000
    1.0000         0         0
         0    0.5020    1.0000
         0    1.0000         0
         0         0    1.0000
    1.0000    0.5000         0
    1.0000    0.5020    0.7529
    0.5020         0    1.0000
    0.5020    0.5020         0];
     colormap(M);

else colormap(hsv(length(pvalues)));
end
end
scatter(x,y,200,z,'filled');
axis([0,6,0,6]);
set(gca,'YTick',[1,2,3,4,5,6]);
set(gca,'XTick',[1,2,3,4,5,6]);
figure(1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function RV=myrv(die1,die2)
% Change the following line to calculate your RV
% using the variables die1 and die2.
% Program defaults to using the sum of the two die.
RV=max(die1,die2);
