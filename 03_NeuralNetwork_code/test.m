%% 5. call the pretrained neural network
% a = py.numpy.array([1+2i,2+3i])
% b = py.numpy.array([3+4i,5+6i])
% 
% result = py.add.add(a,b)
% 
% convert_result = double(result)

% Set the length of the vector
vector_length = 150;

% Generate random complex numbers
real_part = randn(1, vector_length);
imaginary_part = randn(1, vector_length);

% Combine real and imaginary parts to create complex numbers
complex_vector = complex(real_part, imaginary_part);

input_vector = py.numpy.array(complex_vector);
decoding_symbol = py.decoding_symbol.decoding_symbol(input_vector);

decoding_symbol = double(decoding_symbol)
