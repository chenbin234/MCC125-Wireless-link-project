clear u2
% u2 = udpport("LocalPort",8866,"LocalHost","127.0.0.1");
time1 = datetime
u2 = udpport("LocalPort",8867, Timeout=5);

% % read(u2,u2.NumBytesAvailable,"string")
notification_message = read(u2,5,"string")
% read(u2,5,"uint8")

clear u2


disp("ok")
disp(notification_message)
