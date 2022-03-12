 function [output] = Lab5ExA
% This program calculates and plots the probabiity mass function (pmf) for a 
% negative binomial random variable X ie Nb(r,p) (where r>0 is any real number) and 
% 0<p<=1.
% When you run the program from the command window you will be prompted for
% your chosen values of r and p. 

%%%%%%%%%%%%%%%%%%%%%%%%%%Input parameters
r=input('Please input the value of r (r must be positive)');
if r <= 0
    error('Value of r must be positive')
end
p=input('Please input the value of p (0<p<=1)');
if  not((p>0)&(p<=1))
    error('Value of p outside permitted range')
end
%%%%%%%%%%%%%%%%%%%%%%%%%%Most likely values
% The negative binomial takes the countable number of values 0,1,2,...
% As we can only plot a finite number of these we need to determine the
% range of the most likely values.  Here we use the mean plus or minus four
% standard deviations, truncated at zero if the lower limit is negative.
mean=r*(1-p)/p;
sd=sqrt(mean/p);
lowlimit=max(0,floor(mean-4*sd)+1);
highlimit=floor(mean+4*sd)+1;  %check meaning of floor function using Matlab help
mostlikelyvalues=[lowlimit:highlimit];
%%%%%%%%%%%%%%%%%%%%%%%%%%Calculate probability masses
% Now we calculate the probability masses for each of the 'mostlikelyvalues'.
% We use the general form of the pmf (see lecture slide 173).
for z=lowlimit:highlimit
   % Calculate negative binomial coefficient 'coeff' ie (-r choose z)
   if z==0
      coeff=1;
   else
    num=-1*r;
    denom=z;
    coeff=num/denom;
      for j=1:(z-1)
          num=num-1;
          denom=denom-1;
          factor=num/denom;
          coeff=coeff*factor;
      end
   end
   probabilitymasses(z+1-lowlimit)=coeff*(p^r)*(p-1)^z;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%Empirical pmf
% This section plots the theoretical pmf in a bar chart
bar(mostlikelyvalues, probabilitymasses);
% legend('Theoretical','Simulation');
title(sprintf('Negative binomial pmf for Nb( r =%5.1f,p = %5.3f)',r,p));
figure(1);
