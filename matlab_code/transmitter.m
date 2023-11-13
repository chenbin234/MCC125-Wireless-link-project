
%% An example of how to set up and run the USRP in Matlab
%  The example show how to transmit and receive a harmonic signal in "real" time.
clear all;close all;
%% This is the sampling rate for the digital mixer, do not change
MasterClock_Rate=100000000;

%% Interpolation factor for the Transmitter
Interp_Factor=64;

%% Decimation factor for the Receiver
Decimation_Factor=Interp_Factor;

%% Sampling rate and time
fs=MasterClock_Rate/Interp_Factor;%sampling rate
dt=1/fs;%Sampling time
N=10000;%Numbr of samples in a frame
frame_time=N/fs;% Time for 1 frame
time=(0:dt:dt*(N-1))';
% s_tx=(0.2*exp(1i*2*pi*100000*time));
RBW=1/frame_time;
NFFT = 2^nextpow2(N); % Next power of 2 from length of y


%% call the Tx_64QAM function
message_string = "Hello, Bingcheng, Gray code, named after the American physicist and mathematician Frank Gray, " + ...
    "is a binary numeral system where two successive values differ in only one bit. " + ...
    "In Gray code, also known as reflected binary code or unit distance code, " + ...
    "each decimal digit is represented by a binary code, and adjacent codes differ in only one bit.";
message_bits = str2bits(message_string);

fc = 2.4e9; %carrier frequency
s_tx = Tx_64QAM(message_bits);

%% Setup the Tx
tx = comm.SDRuTransmitter(... 
'Platform','N200/N210/USRP2',...
'IPAddress','192.168.10.6',...
'CenterFrequency',0,...
'EnableBurstMode',1,...
'NumFramesInBurst',1,...
'InterpolationFactor',Interp_Factor,...
'MasterClockRate',MasterClock_Rate,...
'TransportDataType','int16');
  
currentTime = 0;
for k=1:2 % a loop 
  tx(s_tx)
  currentTime=currentTime+frame_time
end
release(tx);
    