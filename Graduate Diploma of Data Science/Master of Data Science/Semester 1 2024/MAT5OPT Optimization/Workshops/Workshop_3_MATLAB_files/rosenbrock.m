%Q1 W3 MAT5OPT
function f = rosenbrock(x)
 f = 100*(x(2)- x(1)^2)^2 + (1-x(1))^2;
end

%Then, run fminsearch(@rosebrock,[0 0]) onto the script
%to return x = ( 1 1 )^T.

%Q2 W3. Perform each of the following using a single line of code, 
% updating the matrix M as you go. (Next two questions must write in the 
% scripts down below.

%a. Create a matrix M with the numbers 2, 5, 8, ..., 50 in the first row 
%and 101, 98, ..., 53 in the second row.

%M=[2:3:50;101:-3:53];

%b. Add 1 to every element in M and then divide every element by 3.
%M = (M + 1)/3;

%c. Delete the first two columns of M.
%M(:,1:2) = [];

%d.Assign the number of rows and number of columns of M to the
% variables nrow and ncol.
% size(M); returns 2 rows and 15 columns
% nrow = length(M(:,1));
% ncol = length(M(1,:));

% Alternative solution (single line of code):
%[nrow,ncol]=size(M);

%e. Delete a random column of M (using the randi function).
% returns a scalar.
% M(:,randi(ncol,1,1)) = [];

% Alternative solution, also returns a scalar!
% M(:,randi(ncol)) = [];

%f. Swap both rows of M.
%. Example we want to swap rows 1 and 2 from the M matrix.
% M([1 2],:)= M([2 1],:);

%Alternative solution
% M=[M(2,:);M(1,:)];

%g. Swap columns 7 and 9 of M.
% M(:,[7 9])= M(:,[9 7]);

%h. Apply the map x → (x^2 −x)/2 to the elements in M.
%Answer:
% M=(M.^2-M)/2;

%i.Replace each element in the second row of M with a
% random number between −7 and 7.
%Answer: 
%M([1 2],:)= vertcat(M(1,:),randi([-7 7],1,ncol));

%Solution:
%M(2,:)=randi([-7 7],[1 ncol-1]);

%M(2,:)=randi([-7 7],[1 ncol-1]);

%j. Replace each element in columns 3–6 with a random number between −10 and 10.
%M(:,[3:6])= randi([-10 10],[nrow length([3:6])]);

%k. Replace all positive elements of M with their square root,
% rounded down to the nearest integer. 
% You will need the floor function.
% M(M>0)= floor(sqrt(M(M>0)));

%l.Replace all negative elements of M with the result of 
% applying the map x → (x^2 − x)/2 to those elements.
% M(M<0) = (M(M<0).^2-M(M<0))/2;


%Q7 (Type line by line into the script!
%For Q4,
%A = [-1 3;3 -5];
%B = [4; 2];
%inv(A)*B

%Answer: 
%ans =

    %6.5000
    %3.5000

%For Q5,
% G = [-1 3 4; 3 -5 2];

% G(1,:) = 3*G(1,:);
% G(2,:) = G(1,:)+G(2,:);

% G(1,:) = G(1,:)/-3;
% G(2,:) = G(2,:)/2;

% G(1,:) = G(1,:)*2;
% G(2,:) = G(2,:)*3;

% G(1,:) = G(1,:) +  G(2,:);


% G(1,:) = G(1,:)/2;
% G(2,:) = G(2,:)/6;
%Should get the same answers for Q4

%For Q6,
%G1 = [1 2 3 4 0; 0 1 2 3 0; 2 1 0 0 0];
%G1(1,:) = 2*G1(1,:);
%G1(1,:) = G1(1,:) - G1(3,:);
%G1(1,:) = G1(1,:) - 3*G1(2,:);

%G1([1 3],:) = G1([3 1],:)
%Should get x_4 = 0, x_1 = x_3 = t and x_2 = -2t, where t is any real
%number. 


%Q8. 
%For Q5
% G = [-1 3 4; 3 -5 2];
% rref(G)

%For Q6
% G1 = [1 2 3 4 0; 0 1 2 3 0; 2 1 0 0 0];
% rref(G1)
% Regardless of the output it should still give the same result.

%Q9b
