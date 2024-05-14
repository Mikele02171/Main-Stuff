 function [g1, g2] = grosenbrock(x1,x2)
 % Gradient of the Rosenbrock function
 g1 =-400*x1.*(x2-x1.^2)- 2*(1-x1);
 g2 = 200*(x2- x1.^2);
 end

 %Make sure Q14c and 14d must run on the Command Window in order.
 %For Q14c.
% [X,Y] = meshgrid(-2:1/10:2,-1:1/10:3);
% Z = rosenbrock(X,Y);
% surf(X,Y,Z)

%Q14d.
%[X,Y] = meshgrid(-2:1/100:2,-1:1/100:3);
%Z = rosenbrock(X,Y);
%contour(X,Y,Z,[.7,7,70,200,700],'ShowText','on')

%Q14e.
% [X,Y] = meshgrid(-2:1/100:2,-1:1/100:3);
%Z = rosenbrock(X,Y);
%contour(X,Y,Z,[.7,7,70,200,700],'ShowText','on');
%hold on;
%[X,Y] = meshgrid(-1.5:1/2:1.5,-.5:1/2:2.5);
%[A,B] = grosenbrock(X,Y);
%quiver(X,Y,A,B);
%hold off;

%Q14f.
%[X,Y] = meshgrid(0.1:1/1000:0.2,-0.01:1/1000:0.07);
%Z = rosenbrock(X,Y);
%contour(X,Y,Z,[0.7, 0.75, 0.8],'ShowText','on')
%hold on;
%[X,Y] = meshgrid(0.1:0.01:0.2,0:0.01:0.06);
%[A,B] = grosenbrock(X,Y);
%quiver(X,Y,A,B)
%hold off;

%Q14g.
%[X,Y]=meshgrid(0.95:1/1000:1.05,0.9:1/1000:1.1);
%Z=rosenbrock(X,Y);
%contour(X,Y,Z,[0.0010 .050 .7],'ShowText','on')
%hold on;
%[X,Y]=meshgrid(0.96:0.01:1.04,0.91:0.01:1.09);
%[A,B]=grosenbrock(X,Y);
%quiver(X ,Y,A,B)
%hold off;