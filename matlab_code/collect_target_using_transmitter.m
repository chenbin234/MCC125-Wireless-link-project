clear all;close all;
%% parameter used in UDP connection
Local_port = 8844;
Remote_host = "127.0.0.1";
Remote_port = 8867;

% generate random message
Rb = 1*1e6;          % Bit rate [bit/sec] %Rb = fsymb*bpsymb; % Bit rate [bit/s]
M = 1024;             % Number of symbols in the constellation
bpsymb = log2(M);     % Number of bits per symbol,bpsymb=6 in 64QAM 
fsymb = Rb/bpsymb;    % Symbol rate [symb/s] Rs = 1.67 MBaud/s
Tsymb = 1/fsymb;      % Symbol time
fs = 10*fsymb;         % Sampling frequency [Hz]
Tsamp = 1/fs;         % Sampling time
fsfd = fs/fsymb;      % Number of samples per symbol [samples/symb], fsfd=10

segmentation_size = 100; %length of training message(bits)
number_data = 3000;

% Generate #number_data random numbers between [0, 1]
random_bits = randi([0, 1], number_data, segmentation_size);

% collect the target and feature for model training
target_symbol = zeros(number_data,(segmentation_size./bpsymb)*1.5);

% Specify the Excel file name
target_file = 'target_symbol_dataset.csv';

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
RBW=1/frame_time;
NFFT = 2^nextpow2(N); % Next power of 2 from length of y


for i = 1:number_data 
    
    % send a UDP message to receiver to notify the coming of the ith
    % message
    clear u1;
    u1 = udpport("LocalPort",Local_port);
    write(u1,sprintf('%05d',i),"string",Remote_host,Remote_port);
    disp(["Ready to send No.", num2str(i), " message"]);
    clear u1;

    % concolutional encoding
    trellis = poly2trellis([5 4],[23 35 0; 0 5 13]);
    traceBack = 28;
    codeRate = 2/3;
    message_bits = convenc(random_bits(i,:),trellis);

    % Bit to symbol mapping & spacing: -–––––––––––––––––––––––––––––––––––––––
    m = buffer(message_bits, bpsymb)';            % Group bits into bits per symbol
    m_idx = bi2de(m, 'left-msb')';              % Bits to symbol index
    target_symbol(i,:) = qammod(m_idx, M, UnitAveragePower=true);  % Look up symbols using the indices
    
    % send random_bits(i,:) 
    s_tx = 0.1*Tx_1024QAM(random_bits(i,:));

    %% Setup the Tx
    tx = comm.SDRuTransmitter(... 
    'Platform','N200/N210/USRP2',...
    'IPAddress','192.168.10.8',...
    'CenterFrequency',10e6,...
    'EnableBurstMode',0,...
    'InterpolationFactor',Interp_Factor,...
    'MasterClockRate',MasterClock_Rate,...
    'TransportDataType','int8');
    

    currentTime = 0;
    for k=1:500 % a loop 
    %   pause(2);
      tx(s_tx') % transmitting the signal s_tx
      currentTime=currentTime+frame_time
    end

    disp(["Send the No.",num2str(i), "message 200 times successfully !"]);

    % After the loop,release system resources associated with the transmitter object.
    release(tx);

    disp('Sleep for 10 seconds!');
    pause(10);
    
    if mod(i,50) == 0
        writematrix(target_symbol, target_file);
    end
        
end



% Write the random numbers to the Excel file
writematrix(target_symbol, target_file);

disp(['Target symbols have been written to ',target_file]);