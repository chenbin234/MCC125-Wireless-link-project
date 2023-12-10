function message_bits = str2bits(message_string)

%This function converts a string message to binary bits.

% Convert each character in the string to its ASCII code
asciiCodes = double(char(message_string));

% Convert ASCII codes to binary code 
binaryCodes = dec2bin(asciiCodes, 8); % 8 is the number of bits for each character

% reshape binaryCodes into a row vector
% The expression -'0' is a trick to convert the character array to a numerical array
message_bits = reshape(binaryCodes.'-'0',1,[]);

end

