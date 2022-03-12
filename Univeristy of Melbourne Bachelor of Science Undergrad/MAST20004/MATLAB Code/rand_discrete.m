function result = rand_discrete(possvalues,probmasses,n)
% rand_discrete(possvalues,probmasses,n)
%   This function creates a vector of n observations on a discrete random variable.
%   The possible values (possvalues) and their respective probabilities (probmasses)are passed to
%   this function as arguments.
%   For example to generate three rolls of a fair die you would use
%   rand_discrete([1:6],(1/6)*[1,1,1,1,1,1],3)
%   The third argument 'n' is optional and if omitted is assumed to be 1.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%An input check
if length(possvalues) ~= length(probmasses)
    display('Error in theoretical pmf')
    error('Number of possible values differs from number of probability masses')
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Third argument omitted
if nargin == 2  % 'nargin' is simply a count of the number of input arguments 
    R=rand(1); % remember this sets R to a random number continuously distributed in (0,1)
    distributionfunction=0; 
    index=0;
    while distributionfunction<R
        index=index+1;
        distributionfunction=distributionfunction+probmasses(index);
    end
    result=possvalues(index);
 end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Third argument included
if nargin == 3
    for i=1:n
        R=rand(1);
        distributionfunction=0;
        index=0;
        while distributionfunction<R
            index=index+1;
            distributionfunction=distributionfunction+probmasses(index);
        end
    result(i)=possvalues(index);
    end   
end