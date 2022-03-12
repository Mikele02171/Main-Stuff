% RANDUNIFD(a,b,n)
%   This function creates a uniformly distributed discrete random variable
%   between 'a' and 'b'.  If a third argument is used, a vector of 'n'
%   random varibles is created.
%
% See also RAND, RANDN, RANDUNIFC, RANDEXPO, RANDPOIS, RANDGAUSS, RANDGEO

function out = randunifd(a,b,n)

if nargin == 2
    x = floor((b - a + 1) * rand);
    out = (x + a);
end

if nargin == 3
    randvec = rand(1,n);
    x = floor((b - a + 1) * randvec);
    out = (x + a);
end