clear all;close all;

% generate random message
Rb = 333*1e6;          % Bit rate [bit/sec] %Rb = fsymb*bpsymb; % Bit rate [bit/s]
M = 1024;             % Number of symbols in the constellation
bpsymb = log2(M);     % Number of bits per symbol,bpsymb=6 in 64QAM 
fsymb = Rb/bpsymb;    % Symbol rate [symb/s] Rs = 1.67 MBaud/s
Tsymb = 1/fsymb;      % Symbol time
fs = 3*fsymb;         % Sampling frequency [Hz]
Tsamp = 1/fs;         % Sampling time
fsfd = fs/fsymb;      % Number of samples per symbol [samples/symb], fsfd=10

segmentation_size = 100; %length of training message(bits)
number_data = 50000;

% Generate #number_data random numbers between [0, 1]
random_bits = randi([0, 1], number_data, segmentation_size);

% collect the target and feature for model training
target_symbol = zeros(number_data,(segmentation_size./bpsymb)*1.5);


%% This is the sampling rate for the digital mixer, do not change
MasterClock_Rate=100000000;

%% Interpolation factor for the Transmitter
Interp_Factor=1;

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
    % Bit to symbol mapping & spacing: -–––––––––––––––––––––––––––––––––––––––

    % concolutional encoding
    trellis = poly2trellis([5 4],[23 35 0; 0 5 13]);
    traceBack = 28;
    codeRate = 2/3;
    message_bits = convenc(random_bits(i,:),trellis);

    m = buffer(message_bits, bpsymb)';            % Group bits into bits per symbol
    m_idx = bi2de(m, 'left-msb')';              % Bits to symbol index
    target_symbol(i,:) = qammod(m_idx, M, UnitAveragePower=true);  % Look up symbols using the indices
    
    % send random_bits(i,:) 
    s_tx = Tx_64QAM(random_bits(i,:));

    %% Setup the Tx
    tx = comm.SDRuTransmitter(... 
    'Platform','N200/N210/USRP2',...
    'IPAddress','192.168.10.5',...
    'CenterFrequency',10e6,...
    'EnableBurstMode',0,...
    'InterpolationFactor',Interp_Factor,...
    'MasterClockRate',MasterClock_Rate,...
    'TransportDataType','int16');
      
    currentTime = 0;
    for k=1:100 % a loop 
    %   pause(2);
      tx(s_tx') % transmitting the signal s_tx
      currentTime=currentTime+frame_time
    end

    disp(['Send the No.',num2str(i), 'message 200 times successfully !']);

    % After the loop,release system resources associated with the transmitter object.
    release(tx);

    disp('Sleep for 5 seconds!');
    pause(5);

end

% Specify the Excel file name
target_file = 'target_symbol_dataset.csv';

% Write the random numbers to the Excel file
writematrix(target, target_file);

disp(['Target symbols have been written to ',target_file]);