%WORKSHOP 12 MAT5OPT

syms w [2 1] real
syms b real
Df = [w' 0];
p = [2 3 1 3; 4 3 2 1];
l = [1 1 -1 -1]';

Dg = [-l.*p' -l];
syms mu [4 1] real
DL = Df + mu'*Dg;


g = 1- l.*(w'*p + b)';
mug = mu'.*g';


KKT = [DL mug];


vars = [w' b mu'];
sol = solve(KKT, vars);


subs(KKT, sol);


subs(mu', sol);


subs(g', sol);


r1 = all(subs(g', sol) <= 0, 2);
r2 = all(subs(mu', sol) >= 0, 2);


find(r1 & r2)

vals = subs([w' b], sol);
result = vals(6,:);


w = result(1:2);
b = result(3);
q = [1/2 2 7/2; 3 3 2];
sign(w*q + b)

