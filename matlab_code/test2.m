segment_size =960;  % Number of bits in each message segmentation
random_number = 0; % choose to send different messages
%% call the Tx_64QAM function
message_lines = readlines("message.txt");
message_string = strjoin(message_lines, ' '); % Combine the lines into a single string
message_bits = str2bits(message_string);
% message_bits = message_bits(random_number*segment_size+1:(1+random_number)*segment_size);

disp(['The message transmitted :  ', bits2str(message_bits)])
