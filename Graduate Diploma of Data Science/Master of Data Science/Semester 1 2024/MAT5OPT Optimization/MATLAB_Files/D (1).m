function y = D(x)
    n = length(x);  % Get the length of array x
    y = zeros(1, n-1);  % Preallocate array y with length n-1

    for i = 1:n-1
        y(i) = x(i+1) - x(i);  % Compute the first difference
    end
end

%x = [1, 3, 6, 10, 15];  % Example array
%y = D(x);  % Compute first difference
%disp(y);   % Display the result