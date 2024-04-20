%Assignment 1 MAT5OPT 
%Question 3. 
%Part a.
% This produces an error which has incorrect dimensions for raising a
% matrix. Since the operation is reserved for matrix powers.
%[1 2 3]^2 ;

%. This allows to square on each element of an array indidually.
%[1 2 3].^2;

%. Adding one as a constant to a vector adds one for each element of the 
%. vector. %
%[1 2 3] + 1;


%Part b. 
X = zeros(1, 9);  % Preallocate array X
for j = 1:9
    X(j) = 5 + 3*j;
end

%Part c. 
%See F.m file

%Part d.
%See D.m file

%Part e.
F = @(x) x.^2; % Define function F, for example, squaring each element
D = @(x) [0, diff(x)]; % Define function D to compute first difference
A = @(x) sum(x(mod(x, 12) == 0)); 
% Anonymous function A to sum 
% elements divisible by 12

X = [1, 4, 6, 12, 15, 18]; % Example array X

result = A(D(F(X))); % Apply A to D(F(X))

disp(result); % Display the result