clear all;clc;
% Input parameters -–––––––––––––––––––––––––––––––––––––––––––––––––––––––
Rb = 1*1e6;             % Bit rate [bit/sec] %Rb = fsymb*bpsymb; % Bit rate [bit/s]
% N = length(message_bits);% Number of bits to transmit
fc = 2.4*1e9;            % Carrier frequency [Hz]

M = 16;               % Number of symbols in the constellation
bpsymb = log2(M);     % Number of bits per symbol,bpsymb=6 in 64QAM 
fsymb = Rb/bpsymb;    % Symbol rate [symb/s] Rs = 1.67 MBaud/s
Tsymb = 1/fsymb;      % Symbol time
fs = 10*fsymb;        % Sampling frequency [Hz]
Tsamp = 1/fs;         % Sampling time
fsfd = fs/fsymb;      % Number of samples per symbol [samples/symb], fsfd=10

alpha = 0.8;          % Roll off factor / Excess bandwidth factor (a_RC=0.35;a_RRC=0.8)
tau = 1/fsymb;        % Nyquist period or symbol time 
span = 6;             % Pulse width (symbol times of pulse)

segment_size = 4*960;  % Number of bits in each message segmentation
random_number = 0; % choose to send different messages


trellis = poly2trellis([5 4],[23 35 0; 0 5 13]);
traceBack = 28;
codeRate = 2/3;

% message
message_lines = readlines("message.txt");
message_string = strjoin(message_lines, ' '); % Combine the lines into a single string
message_bits = str2bits(message_string);
message_bits = message_bits(random_number*segment_size+1:(1+random_number)*segment_size);
% message_bits = randi([0, 1], 1, segment_size);

% transmitter
s_tx = Tx_64QAM(message_bits);

%channel
rxSig = awgn(s_tx,15,'measured');

% add Frequency offset
t = (0:length(rxSig)-1)/fs;  % Time vector
frequency_offset = -5;  % Adjust as needed
s_tx_frequency_offset = rxSig.* exp(1i * 2 * pi * frequency_offset * t);

% add Phase offset
phase_offset = -pi/8;  % Adjust as needed
s_tx_phase_offset = s_tx_frequency_offset * exp(1i * phase_offset);
 
% receiver

[received_message_bits, received_message_symbols, ~]= Rx_64QAM(s_tx_phase_offset, segment_size./codeRate);

% convert the received_message_bits to strings
received_message_string = bits2str(received_message_bits(:))


% Calculate the number of bit errors
nErrors = biterr(message_bits,received_message_bits);
% 
% Display the result
% disp(['The message transmitted :  ', message_string])
% disp(['The message received    :  ', received_message_string])
disp(['Number of bit errors    :  ', num2str(nErrors)])
disp(['BER    :  ', num2str(nErrors/length(message_bits))])
