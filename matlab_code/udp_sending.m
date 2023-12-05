% Creating a UDP object
u1 = udpport("LocalPort",8844);

write(u1,"Ready for data transfer.","string","127.0.0.1",8867)

clear u1