% RANDEXPO(a,n)
%   This function creates an exponentially distributed random variable
%   with parameter 'a'.  If a second argument is used, a vector of
%   'n' exponential variables is created.
%
% See also RAND, RANDN, RANDUNIFC, RANDGEO, RANDPOIS, RANDGAUSS

function out = randexpo(a, n)

if nargin == 1
    out = -log(rand) / a;
end

if nargin == 2
    randvec = rand(1,n);
    out = -log(randvec) ./ a;
end