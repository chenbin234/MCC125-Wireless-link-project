% Set the length of the vector
preambleLength = 130;  % You can change this to your desired length

% Generate a vector with random 1s and -1s
randomVector = randi([0, 1], 1, preambleLength)*2 - 1;

disp(randomVector);

preamble = [-1	-1	-1	-1	1	-1	-1	-1	-1	-1	-1	1	-1	-1	1	1	-1	-1	-1	-1	1	-1	1	1	-1	-1	-1	-1	-1	1	-1	-1	1	-1	1	1	-1	1	-1	-1	1	1	1	-1	-1	1	1	-1	-1	1	-1	1	1	1	-1	-1	-1	1	-1	1	-1	1	-1	1	1	1	1	-1	1	-1	-1	1	1	-1	1	1	1	1	1	1	-1	-1	1	-1	-1	-1	1	1	1	-1	-1	1	-1	-1	1	-1	1	1	1	-1	1	1	1	1	1	-1	-1	1	-1	-1	-1	-1	1	1	-1	-1	1	-1	1	1	-1	-1	-1	1	-1	-1	-1	-1	-1	-1];

length(preamble)