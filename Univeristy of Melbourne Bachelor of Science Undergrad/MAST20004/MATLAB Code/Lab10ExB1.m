function [output] = Lab10ExB1
% Suitably modified this program will plot the function psi(x)
% together with its linear (l(x)) and quadratic (q(x)) Taylor series
% approximating functions over a specified domain ([L,U]=[0,1] by default).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Initialise
L=0;
U=1;
x=[L:0.001:U];

%%%%%%%%%%%%%Here you input the function psi
% This defaults to psi(x)=sqrt(x) for the first part of the exercise.
psi=sqrt(x);

%%%%%%%%%%%%%%Complete the following lines of code to set the values for mu (mean of X),
% psi_mu (psi evaluated at mu), psidash_mu (the first derviative of psi evaluated at mu)
% and psidash2_mu (the second derivative of psi evaluated at mu).  These
% values are then used to calculate the linear and quadratic
% functions approximating psi(x).

mu=	;
psi_mu=	;
psidash_mu=	;
psidash2_mu=	;

%%%%%%%%%%%%%%Here the approximating functions are calculated and plotted.

l=psi_mu+psidash_mu*(x-mu);
q=l+(1/2)*psidash2_mu*(x-mu).^2;
plot(x,psi,'-',x,l,'--',x,q,'--')
figure(1);
legend('psi(x)','linear approx','quadratic approx');
title('Plot of psi(x) and its Taylor series approximations','Fontsize',18);

