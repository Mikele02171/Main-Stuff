%W3 Q11
%a. Ensure you have workshop3_data excel file into the files window.
dat = readmatrix('workshop3_data');

%b. Extract the first row
%dat = dat(1,:);

%Answer: Yes, (eh.. what?!), worked for me?!

%c. Define variables x,y and z. 
x = dat(:,1);
y = dat(:,2);
z = dat(:,3);

%d. Use the scatter function to create a scatter plot with x on the 
% horizontal axis and z on the vertical axis.
%scatter(x,z);

%e. Define suitable matrices and apply suitable operations in MATLAB 
% to find the coefficients that best fit the linear 
% model z = a_0 +a_1x.

%A = [ones([length(x),1]) x];
%a = inv(A'*A)*A'*z;

%a = [3.5370; 2.3264];
%z = 3.5370 + 2.3264*x; 

%f. In the same figure as part (d), plot the line a0 +a1x.
%hold on

%plot(x,z);

%hold off

%12. NOTE: Comment everything on Q11
%Using your answer to Question 10(c), define suitable matrices 
% and apply suitable operations in MATLAB to find the 
% coefficients that best fit the linear model 
% z = a0 +a1*x+a2*y to the data in workshop3_data.csv.

A1 = [ones(size(x)) x y];
a1 = inv(A1'*A1)*A1'*z;

%Gives us, a0 ≈ 3.9680, a1 ≈ 2.2517 and a2 ≈ −0.3092.