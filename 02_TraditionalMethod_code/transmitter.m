
%% An example of how to set up and run the USRP in Matlab
%  The example show how to transmit and receive a harmonic signal in "real" time.
clear all;close all;
%% This is the sampling rate for the digital mixer, do not change
MasterClock_Rate=100000000;

%% Interpolation factor for the Transmitter
Interp_Factor=4;

%% Decimation factor for the Receiver
Decimation_Factor=Interp_Factor;

%% Sampling rate and time
fs=MasterClock_Rate/Interp_Factor;%sampling rate
dt=1/fs;%Sampling time
N=20000;%Numbr of samples in a frame
frame_time=N/fs;% Time for 1 frame
time=(0:dt:dt*(N-1))';
% s_tx=(0.2*exp(1i*2*pi*100000*time));
RBW=1/frame_time;
NFFT = 2^nextpow2(N); % Next power of 2 from length of y

segment_size =960;  % Number of bits in each message segmentation
random_number = 0; % choose to send different messages
%% call the Tx_64QAM function
message_lines = readlines("message.txt");
message_string = strjoin(message_lines, ' '); % Combine the lines into a single string
message_bits = str2bits(message_string);
message_bits = message_bits(random_number*segment_size+1:(1+random_number)*segment_size);

disp(['The message transmitted :  ', bits2str(message_bits)])

% transmitter
s_tx = 0.2*Tx_64QAM(message_bits);
%subplot(1,1,1), pwelch(tx_signal,[],[],[],fs,'centered','power');
%% Setup the Tx
tx = comm.SDRuTransmitter(... 
'Platform','N200/N210/USRP2',...
'IPAddress','192.168.10.8',...
'CenterFrequency',20e6,...
'EnableBurstMode',0,...
'InterpolationFactor',Interp_Factor,...
'MasterClockRate',MasterClock_Rate,...
'TransportDataType','int16');
  
currentTime = 0;
for k=1:1000000 % a loop 
%   pause(3);
  tx(s_tx') % transmitting the signal s_tx
  currentTime=currentTime+frame_time;
end
% After the loop,release system resources associated with the transmitter object.
release(tx);
    