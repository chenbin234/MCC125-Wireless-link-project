clear all;clc;
% Input parameters -–––––––––––––––––––––––––––––––––––––––––––––––––––––––
Rb = 10*1e6;             % Bit rate [bit/sec] %Rb = fsymb*bpsymb; % Bit rate [bit/s]
% N = length(message_bits);% Number of bits to transmit
fc = 2.4*1e9;            % Carrier frequency [Hz]

M = 64;               % Number of symbols in the constellation
bpsymb = log2(M);     % Number of bits per symbol,bpsymb=6 in 64QAM 
fsymb = Rb/bpsymb;    % Symbol rate [symb/s] Rs = 1.67 MBaud/s
Tsymb = 1/fsymb;      % Symbol time
fs = 10*fsymb;        % Sampling frequency [Hz]
Tsamp = 1/fs;         % Sampling time
fsfd = fs/fsymb;      % Number of samples per symbol [samples/symb], fsfd=10

alpha = 0.8;          % Roll off factor / Excess bandwidth factor (a_RC=0.35;a_RRC=0.8)
tau = 1/fsymb;        % Nyquist period or symbol time 
span = 6;             % Pulse width (symbol times of pulse)

message_string = 'cdegfhqwerty';

% message_lines = readlines("message.txt");
% message_string = strjoin(message_lines, ' '); % Combine the lines into a single string
message_bits = str2bits(message_string);

m = buffer(message_bits, bpsymb)';            % Group bits into bits per symbol
m_idx = bi2de(m, 'left-msb')';              % Bits to symbol index
x = qammod(m_idx, M);  % Look up symbols using the indices

x = [x 0 0 0 0 0 0 0 0]


received_message_bits = qamdemod(0.95*x,M,'OutputType','bit');
received_message_bits = received_message_bits(:)';
received_message_string = bits2str(received_message_bits)

% a = (message_bits == received_message_bits)
