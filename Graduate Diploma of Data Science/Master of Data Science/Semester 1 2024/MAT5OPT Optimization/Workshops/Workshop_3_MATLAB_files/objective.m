function f = objective(a)
 a0 = a(1);
 a1 = a(2);
 f = (-1 + 4*a1- a0)^2 + (2*a1- a0)^2 + (2-2*a1- a0)^2 + (3-5*a1-a0)^2;
end


%fminsearch(@objective,[0 0])
%ans =
%   0.8872   0.4513