%MAT5OPT Constrained and Unconstrained optimisation Workshop 1
% Q5.
func = @ ( x1 , x2 ) ( x1 .^2 + x2 - 11).^2 + ( x1 + x2 .^2 - 7).^2;
[X , Y ] = meshgrid ( -6:1/10:6 , -6:1/10:6);
Z = func (X , Y );
surf (X ,Y , Z )

%Tutor comment:  The surface plot should make the 
% local minimisers stand out a little more, and it
% still appears that there are
% four local minimisers.


% Q6.
% fminsearch requires a function of a particular form .
% NOTE: CAN ADJUST THE COORDINATES for the function f
% inside the fminsearch function. 
func = @ ( x1 , x2 ) ( x1 .^2 + x2 - 11).^2 + ( x1 + x2 .^2 - 7).^2;
f = @ ( x ) func ( x (1) , x (2));
fminsearch (f , [0 ,0])

%Refer the four coordinates from the solutions. To pinpoint 
%the four local minima. 

% Q7. ASK TUTOR for the code in Q7-10
%(a)
X = randi([-5,5], 1, randi([10,20], 1, 1));
%(b)
sum(X)
%(c)
X(1) * X(end);
%(d)
sum(X(mod(X,3) == 0));
%(e)
X(X ~= max(X));
%(f)
X(X >= mean(X));
%(g)
size = 2* length ( X );
duplicates = zeros (1 , size );
duplicates (1:2: size ) = X ;
duplicates (2:2: size ) = X ;


% Q8. 
function [ roots , discriminant ] = solveQuadratic(a , b , c )
% Multiplying the equation ax ^2+ bx + c = 0 by -1 will give
% the same solutions .
% If a > 0 , then arranging roots with - sqrt (...) 
% first and + sqrt (...) second
% will ensure the conditions are met.
if a < 0
    a = a * -1;
    b = b * -1;
    c = c * -1;
end
discriminant = b ^2 - 4* a * c ;
roots = [( -b - sqrt ( discriminant ))/(2* a ) , ( - b + sqrt ( discriminant ))/(2* a )];
end

% Q9. 
function [ roots , discriminant ] = solveQuadratic( coefficients )
a = coefficients (1);
b = coefficients (2);
c = coefficients (3);
if a < 0
    a = a * -1;
    b = b * -1;
    c = c * -1;
end
discriminant = b ^2 - 4* a * c ;
roots = [( -b - sqrt ( discriminant ))/(2* a ) , ( - b + sqrt ( discriminant ))/(2* a )];
end

% Q10.
%(a) 

A1 = randi ([ -5 ,5] , 1 , size);
A2 = randi ([ -5 ,5] , 1 , size);
size = randi([5,10],1,1);
%(b) 
A = [A1 A2];
%(c) 
C = zeros (1 , 2* size );
C(1:2:2* size ) = A1 ;
C(2:2:2* size ) = A2 ;
%(d)
doubles = [];
for i = A
    doubles = [ doubles sum( A == i ) == 2];
end

%(e)
uniques = [];
for i = A
    if ~ ismember (i , uniques )
        uniques = [ uniques i ]
    end
end
%(f) 
counts = [];
for i = A
    counts = [ counts sum ( A == i )];
end
%(g) 
doubles = A ( counts == 2);
uniques = A ( counts == 1);

%(h).
% Comparing A with its transpose A' will construct a square
% matrix where the entry in row i, column j is
% the result of comparing A(i) with A(j). Summing
% together row i of this matrix will count the number of
% times A(i) appears in A. So the following code will do the job:

counts = sum ( A == A );

%This approach tends to be faster than using a loop,
% but this is at the cost of using more space in memory.

