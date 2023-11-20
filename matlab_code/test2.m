% % Example vector with complex numbers
% complex_vector = [2 + 3i, -1 - 4i, 5 + 1i, 0 - 2i];
% 
% % Extract real and imaginary parts
% real_part = real(complex_vector);
% imag_part = imag(complex_vector);
% 
% % Display the results
% disp('Original Complex Vector:');
% disp(complex_vector);
% 
% disp('Real Part:');
% disp(real_part);
% 
% disp('Imaginary Part:');
% disp(imag_part);

% Example 3D matrix
rows = 3;
cols = 4;
depth = 5;
threeD_matrix = rand(rows, cols, depth);

% Write the 3D matrix to a CSV file
writematrix(threeD_matrix, 'output.csv');
