% Your string
myString = 'Hello, Bingcheng!';

% Convert each character to its ASCII value
binaryRepresentation = str2bits(myString);

disp(binaryRepresentation);

str = (char(bin2dec(reshape(char(binaryRepresentation+'0'), 8,[]).')))'