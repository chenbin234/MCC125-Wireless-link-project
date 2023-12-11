clear all;close all;
%% parameter used in UDP connection
Local_port = 8867;
Remote_port = 8844;

segmentation_size = 100; %length of training message(bits)
number_data = 3000;
codeRate = 2/3;

M = 1024;               % Number of symbols in the constellation
bpsymb = log2(M);     % Number of bits per symbol,bpsymb=6 in 64QAM 

% Specify the Excel file name
feature_file = 'feature_symbol_dataset.csv';

%% This is the sampling rate for the digital mixer, do not change
MasterClock_Rate=100000000;

%% Interpolation factor for the Transmitter
Interp_Factor=10;

%% Decimation factor for the Receiver
Decimation_Factor=Interp_Factor;

%% Sampling rate and time
fs=MasterClock_Rate/Interp_Factor;%sampling rate
dt=1/fs;%Sampling time
N=20000;%Numbr of samples in a frame
frame_time=N/fs;% Time for 1 frame
time=(0:dt:dt*(N-1))';
% s_tx=(0.2*exp(1i*2*pi*100000*time));
% resolution bandwidth
RBW=1/frame_time;
NFFT = 2^nextpow2(N); % Next power of 2 from length of y

fsfd = 10;
% collect the feature for model training
feature_symbol = zeros(number_data,(segmentation_size./bpsymb)*1.5*fsfd);


for i = 1:number_data
    
    %% Setup the Rx
    % for k=1:500 % a loop 
    rx = comm.SDRuReceiver(...
        'Platform','N200/N210/USRP2',...
        'IPAddress','192.168.10.4',...
        'CenterFrequency',10e6,...
        'EnableBurstMode',1,...
        'NumFramesInBurst',1,...
        'DecimationFactor',Decimation_Factor,...
        'SamplesPerFrame',N,...
        'MasterClockRate',MasterClock_Rate,...
        'TransportDataType','int16');
    
    % UDP connection, waiting a message from transmitter
    clear u2;
    u2 = udpport("LocalPort",Local_port, Timeout=40);
    notification_message = read(u2,5,"string");
    disp(["Got the notification,  N0.", notification_message, " message is coming!"]);
    clear u2
    
    message_number_received = str2double(notification_message);
    
    pause(5);
    
    currentTime = 0;
    
    for k=1:1000 % a loop 
      %% Start the Rx
        [rx_data] = rx();
        rx_data=double(rx_data)/(2^16);
        
        % check if the rx-data contains NaN values
        isNanpresent = any(isnan(rx_data));
        
        if isNanpresent
            continue;
        end
        
        [received_message_bits, received_message_symbols, feature_symbols, detect_preamble]= Rx_1024QAM(rx_data', segmentation_size./codeRate);
        
        if detect_preamble == 1
        
            % convert the received_message_bits to strings
            %received_message_string = bits2str(received_message_bits(:));
            %disp(['The message received    :  ', received_message_string])
            
            feature_symbol(message_number_received,:) = feature_symbols;

            break;
        end
    %     currentTime=currentTime+frame_time
    % release(rx);
    
    end
    release(rx);
    
    if mod(i,50) == 0
        writematrix(feature_symbol, feature_file);
    end

end

% Write the random numbers to the Excel file
writematrix(feature_symbol, feature_file);

disp(['Feature symbols have been written to ',feature_file]);
