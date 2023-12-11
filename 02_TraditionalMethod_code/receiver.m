
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
N=40000;%Numbr of samples in a frame
frame_time=N/fs;% Time for 1 frame
time=(0:dt:dt*(N-1))';
% s_tx=(0.2*exp(1i*2*pi*100000*time));
% resolution bandwidth
RBW=1/frame_time;
NFFT = 2^nextpow2(N); % Next power of 2 from length of y

segment_size = 960;  % Number of bits in each message segmentation
codeRate = 2/3;
random_number = 0; % choose to send different messages
%% Setup the Rx
% for k=1:500 % a loop 
rx = comm.SDRuReceiver(...
    'Platform','N200/N210/USRP2',...
    'IPAddress','192.168.10.4',...
    'CenterFrequency',20e6,...
    'EnableBurstMode',1,...
    'NumFramesInBurst',1,...
    'DecimationFactor',Decimation_Factor,...
    'SamplesPerFrame',N,...
    'MasterClockRate',MasterClock_Rate,...
    'TransportDataType','int16');

currentTime = 0;
for k=1:5000 % a loop 
  %% Start the Rx
    [rx_data] = rx();
    rx_data=double(rx_data)/(2^16);
    rx_data = conj(rx_data);

    [received_message_bits, received_message_symbols, ~]= Rx_64QAM(rx_data', segment_size./codeRate);
    
    if length(received_message_bits)~=1

        % convert the received_message_bits to strings
        received_message_string = bits2str(received_message_bits(:));
        disp(['The message received    :  ', received_message_string])
        break;
    end
%     currentTime=currentTime+frame_time
% release(rx);
end
release(rx);

%% process the received signal
if length(received_message_bits)~=1

    %% calculate the BER
    
    % True transmitting message
    message_lines = readlines("message.txt");
    message_string = strjoin(message_lines, ' '); % Combine the lines into a single string
    message_bits = str2bits(message_string);
    message_bits = message_bits(random_number*segment_size+1:(1+random_number)*segment_size);
    
    % Calculate the number of bit errors
    nErrors = biterr(message_bits,received_message_bits);
    
    % Display the result
    disp(['The message transmitted :  ', bits2str(message_bits)])
    % disp(['The message received    :  ', received_message_string])
    disp(['Number of bit errors    :  ', num2str(nErrors)])
else
    disp('Did not detect message in this round.')

end

