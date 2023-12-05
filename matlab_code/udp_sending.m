Local_port = 8844;
Remote_host = "127.0.0.1";
Remote_port = 8867;

% Creating a UDP object
u1 = udpport("LocalPort",Local_port);

% write(u1,"Ready for data transfer.","string","127.0.0.1",8867)
write(u1,sprintf('%05d',1),"string",Remote_host,Remote_port)

clear u1