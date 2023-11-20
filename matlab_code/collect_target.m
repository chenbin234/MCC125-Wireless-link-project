
Rb = 10*1e6;             % Bit rate [bit/sec] %Rb = fsymb*bpsymb; % Bit rate [bit/s]
M = 64;               % Number of symbols in the constellation
bpsymb = log2(M);     % Number of bits per symbol,bpsymb=6 in 64QAM 
fsymb = Rb/bpsymb;    % Symbol rate [symb/s] Rs = 1.67 MBaud/s
Tsymb = 1/fsymb;      % Symbol time
fs = 10*fsymb;        % Sampling frequency [Hz]
Tsamp = 1/fs;         % Sampling time
fsfd = fs/fsymb;      % Number of samples per symbol [samples/symb], fsfd=10

segmentation_size = 384; %length of training message(bits)
number_data = 50000;

% Generate #number_data random numbers between [0, 1]
random_bits = randi([0, 1], number_data, segmentation_size);

% collect the target and feature for model training
target = zeros(number_data,segmentation_size./bpsymb);
feature = zeros(number_data,segmentation_size./bpsymb);

for i = 1:number_data 
    % Bit to symbol mapping & spacing: -–––––––––––––––––––––––––––––––––––––––
    m = buffer(random_bits(i,:), bpsymb)';            % Group bits into bits per symbol
    m_idx = bi2de(m, 'left-msb')';              % Bits to symbol index
    target(i,:) = qammod(m_idx, M, UnitAveragePower=true);  % Look up symbols using the indices
    
    % send random_bits(i,:) 
    s_tx = Tx_64QAM(random_bits(i,:), segmentation_size);

    % channel
    rxSig = awgn(s_tx,20,'measured');
    % add Frequency offset
    t = (0:length(rxSig)-1)/fs;  % Time vector
    frequency_offset = 200;  % Adjust as needed
    s_tx_frequency_offset = rxSig.* exp(1i * 2 * pi * frequency_offset * t);
    % add Phase offset
    phase_offset = -pi/8;  % Adjust as needed
    s_tx_phase_offset = s_tx_frequency_offset * exp(1i * phase_offset);

    % Receiver Part
    [~, ~, raw_message_symbol]= Rx_64QAM(s_tx_phase_offset, segmentation_size);
    feature(i,:) = raw_message_symbol;
end

% Specify the Excel file name
target_file = 'target_dataset.csv';
feature_file = 'feature_dataset.csv';

% Write the random numbers to the Excel file
writematrix(target, target_file);
writematrix(feature, feature_file);

disp(['target and feature symbols have been written to ',target_file ,' and ', feature_file]);