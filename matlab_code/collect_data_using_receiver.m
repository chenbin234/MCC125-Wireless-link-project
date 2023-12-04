clear all;close all;

segmentation_size = 100; %length of training message(bits)
number_data = 50000;


%% This is the sampling rate for the digital mixer, do not change
MasterClock_Rate=100000000;

%% Interpolation factor for the Transmitter
Interp_Factor=1;

%% Decimation factor for the Receiver
Decimation_Factor=Interp_Factor;

%% Sampling rate and time
fs=MasterClock_Rate/Interp_Factor;%sampling rate
dt=1/fs;%Sampling time
N=50000;%Numbr of samples in a frame
frame_time=N/fs;% Time for 1 frame
time=(0:dt:dt*(N-1))';
% s_tx=(0.2*exp(1i*2*pi*100000*time));
% resolution bandwidth
RBW=1/frame_time;
NFFT = 2^nextpow2(N); % Next power of 2 from length of y

for i = 1:number_data

    %% Setup the Rx
    % for k=1:500 % a loop 
    rx = comm.SDRuReceiver(...
        'Platform','N200/N210/USRP2',...
        'IPAddress','192.168.10.4',...
        'CenterFrequency',10e6,...
        'EnableBurstMode',0,...
        'DecimationFactor',Decimation_Factor,...
        'SamplesPerFrame',N,...
        'MasterClockRate',MasterClock_Rate,...
        'TransportDataType','int16');
    
    currentTime = 0;
    for k=1:1000 % a loop 
      %% Start the Rx
        % pause(1);
        [rx_data] = rx();
        rx_data=double(rx_data)/(2^16);
    
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


end

