function z = rosenbrock(x1, x2)
 % The Rosenbrock function
 z = 100*(x2-x1.^2).^2 + (1-x1).^2;
 end