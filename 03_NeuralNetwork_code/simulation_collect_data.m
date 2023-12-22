clear all;close all;

% generate random message
Rb = 1*1e6;          % Bit rate [bit/sec] %Rb = fsymb*bpsymb; % Bit rate [bit/s]
M = 1024;             % Number of symbols in the constellation
bpsymb = log2(M);     % Number of bits per symbol,bpsymb=6 in 64QAM 
fsymb = Rb/bpsymb;    % Symbol rate [symb/s] Rs = 1.67 MBaud/s
Tsymb = 1/fsymb;      % Symbol time
fs = 5*fsymb;         % Sampling frequency [Hz]
Tsamp = 1/fs;         % Sampling time
fsfd = fs/fsymb;      % Number of samples per symbol [samples/symb], fsfd=10

segmentation_size = 100; %length of training message(bits)
number_data = 30000;

% Generate #number_data random numbers between [0, 1]
random_bits = randi([0, 1], number_data, segmentation_size);

% collect the target and feature for model training
target_symbol = zeros(number_data,(segmentation_size./bpsymb)*1.5);
% Specify the Excel file name
target_file = 'simulation_target_dataset.csv';


% collect the feature for model training
feature_symbol = zeros(number_data,475);
% Specify the Excel file name
feature_file = 'simulation_feature_dataset.csv';


for i = 1:number_data 
    
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
    
    %channel
    rxSig = awgn(s_tx,30,'measured');
    
    % add Frequency offset
    t = (0:length(rxSig)-1)/fs;  % Time vector
    frequency_offset = rand * 20 - 10;  % Adjust as needed
    s_tx_frequency_offset = rxSig.* exp(1i * 2 * pi * frequency_offset * t);

    % add Phase offset
    phase_offset = rand * 6.28 - 3.14;  % Adjust as needed
    s_tx_phase_offset = s_tx_frequency_offset * exp(1i * phase_offset);
    
    % receiver
    [received_message_bits, received_message_symbols, feature_symbols_collected, detect_preamble]= Rx_1024QAM(s_tx_phase_offset, segmentation_size./codeRate);
    
    feature_symbol(i,:) = feature_symbols_collected;

    pause(0.01);

end

% Write the random numbers to the Excel file
writematrix(target_symbol, target_file);
disp(['Target symbols have been written to ',target_file]);

% Write the random numbers to the Excel file
writematrix(feature_symbol, feature_file);
disp(['Feature symbols have been written to ',feature_file]);



