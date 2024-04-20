function output_array= F(input_array)
odd = input_array(1:2:end);
even = input_array(2:2:end).^2 + 1;

%This works for input_array lengths are even.
if mod(length(input_array),2) == 0
     new_array = horzcat(odd,even);
     new_array = reshape(new_array,length(input_array)/2,2);
     new_array = transpose(new_array);
     output_array = reshape(new_array,1,length(input_array));
 

%This works for input_array lengths are odd.
else
    new_array = horzcat(odd,even,NaN);
    new_array = reshape(new_array,(length(input_array)+1)/2,2);
    new_array = transpose(new_array);
    output_array = reshape(new_array,1,length(input_array)+1);
    output_array =  rmmissing(output_array);

end


