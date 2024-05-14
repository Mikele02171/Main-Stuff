%Q9e. Workshop 3
% Store x and y as column matrices
x = [-4 -2 2 5]';
y = [-1 0 2 3]';
% Initialise the matrix A (as a list of columns)
A = [ones([length(x),1]) x];
a = inv(A'*A)*A'*y;

%Ans: [0.8872; 0.4513]

%9d. 
%inv([1 4;49 1])*[4;23]