% u2 = udpport("LocalPort",8866,"LocalHost","127.0.0.1");
u2 = udpport("LocalPort",8867);

% read(u2,u2.NumBytesAvailable,"string")
read(u2,10,"string")

clear u2


disp("ok")