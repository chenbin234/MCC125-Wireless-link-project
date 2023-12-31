
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
s_tx=(0.2*exp(1i*2*pi*100000*time));
RBW=1/frame_time;
NFFT = 2^nextpow2(N); % Next power of 2 from length of y

%% Setup the Tx
tx = comm.SDRuTransmitter(... 
'Platform','N200/N210/USRP2',...
'IPAddress','192.168.10.5',...
'CenterFrequency',0,...
'EnableBurstMode',1,...
'NumFramesInBurst',1,...
'InterpolationFactor',Interp_Factor,...
'MasterClockRate',MasterClock_Rate,...
'TransportDataType','int16');
  
% rx = comm.SDRuReceiver(...
%     'Platform','N200/N210/USRP2',...
%     'IPAddress','192.168.10.4',...
%     'CenterFrequency',1000,...
%     'EnableBurstMode',1,...
%     'NumFramesInBurst',1,...
%     'DecimationFactor',Decimation_Factor,...
%     'SamplesPerFrame',N,...
%     'MasterClockRate',MasterClock_Rate,...
%     'TransportDataType','int16');
    currentTime = 0;
    for k=1:200 % a loop 
      tx(s_tx)
      %% Start the Rx
%       [rx_data] = step(rx);
%       rx_data=double(rx_data)/(2^16);
%       [rx_dsb,f]=periodogram(rx_data,hamming(length(rx_data)),NFFT,fs,'centered');
%       rx_dsb=10*log10(RBW*rx_dsb)+15;% In dBm
%       figure(1);subplot(2,1,1);plot(time,real(rx_data),'r',time,imag(rx_data),'b');%ylim([-1 1]);grid;ylabel('V');hold on;
%       figure(1);subplot(2,1,2);plot(f, rx_dsb);ylim([-120 10]);grid;ylabel('dBm');
     
      currentTime=currentTime+frame_time
  end
%  release(rx);
 release(tx);
    