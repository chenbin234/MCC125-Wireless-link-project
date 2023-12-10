function received_message_string = bits2str(received_message_bits)

%This function decode the received_message_bits to received_message_string.

 received_message_string = (char(bin2dec(reshape(char(received_message_bits+'0'), 8,[]).'))).';

end

