function tx_signal = Tx_64QAM(message_bits)
% This function is to send message in 64QAM.
% message_bits = message to be transmitted.
% fc = carrier frequency

% Input parameters -–––––––––––––––––––––––––––––––––––––––––––––––––––––––
Rb = 0.1*1e6;             % Bit rate [bit/sec] %Rb = fsymb*bpsymb; % Bit rate [bit/s]
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
% segment_size = 3000;  % Number of bits in each message segmentation


% concolutional encoding
trellis = poly2trellis([5 4],[23 35 0; 0 5 13]);
traceBack = 28;
codeRate = 2/3;
message_bits = convenc(message_bits,trellis);


% Calculate the number of segments needed
% num_segments = ceil(length(message_bits) / segment_size);


% Bit to symbol mapping & spacing: -–––––––––––––––––––––––––––––––––––––––
m = buffer(message_bits, bpsymb)';            % Group bits into bits per symbol
m_idx = bi2de(m, 'left-msb')';              % Bits to symbol index
x = qammod(m_idx, M, UnitAveragePower=true);  % Look up symbols using the indices


% Add preamble: -––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
% preamble = [1 1 1 1 1 -1 -1 1 1 -1 1 -1 1];     % 13 bits from Barker code
% preamble = repmat(preamble,1,10);

preamble = [-1	-1	-1	-1	1	-1	-1	-1	-1	-1	-1	1	-1	-1	1	1	-1	-1 1 1 1 -1 -1 1 1 1 -1 -1 -1 -1 1 -1	-1	-1	1	-1	1	1	-1	-1	-1	-1	-1	1	-1	-1	1	-1	1	1	-1	1	1 -1 -1 1 1 1 -1	-1	1	1	1	-1	-1	1	1	-1	-1	1	-1	1	1	1	-1	-1	-1	1	-1	1	-1	1	-1	1	1	1	1	-1	1	-1	-1	1	1	-1	1	1	1	1	1	1	-1	-1	1	-1	-1	-1	1	1	1	-1	-1	1	-1	-1	1	-1	1	1	1	-1	1	1	1	1	1	-1	-1	1	-1	-1	-1	-1	1	1	-1	-1	1	-1	1	1	-1	-1	-1	1	-1	-1	-1	-1	-1	-1];
% pilot = zeros(1,100);
% x = [pilot, preamb, x]; 
% x = [preamb, x]; 

% Initialize the output vector
message_symbol = [preamble x];

% % Loop through segments
% for i = 1:num_segments
%     % Extract the current segment
%     start_index = (i - 1) * (segment_size./bpsymb) + 1;
%     end_index = min(i * (segment_size./bpsymb), length(x));
%     current_symbol_segment = x(start_index:end_index);
%     
%     % If the total number of bits is not exactly divisible by segment_size(3000), add zeros at the end
%     if mod(length(current_symbol_segment), (segment_size./bpsymb)) ~= 0
%         num_zeros_to_add = (segment_size./bpsymb) - mod(length(current_symbol_segment), (segment_size./bpsymb));
%         current_symbol_segment = [current_symbol_segment, zeros(1, num_zeros_to_add)];
%     end
% 
%     % Add preamble before the segment
%     symbol_segment_with_preamble = [preamble, current_symbol_segment];
% 
%     % Append the current segment to the output vector
%     message_symbol = [message_symbol, symbol_segment_with_preamble];
% end

scatterplot(message_symbol(length(preamble)+1:end));
title('QAM Constellation Diagram transmitted signal');

x_upsample = upsample(message_symbol, fsfd);               % Space the symbols fsfd apart, to enable pulse shaping using conv.

% Pulse shaping - Convert symbols to baseband signal: -––––––––––––––––––––
[pulse,~] = rtrcpuls(alpha,tau,fs,span);      % Create rrc pulse: rtrcpuls(alpha,tau,fs,span)
tx_signal = conv(pulse,x_upsample);           % Create baseband signal (convolve symbol with pulse)

% Add carrier - Convert into passband signal: -––––––––––––––––––––––––––––
% tx_signal = s.*exp(-1i*2*pi*fc*(0:length(s)-1)*Tsamp); % Put the baseband signal on a carrier signal

% Modulation/Upconversion: -–––––––––––––––––––––––––––––––––––––––––––––––
% tx_signal = real(tx_signal);                  % Send real part, information is in amplitude and phase
tx_signal = tx_signal/max(abs(tx_signal));    % Limit the max amplitude to 1 to prevent clipping of waveforms
disp(['the length of transmitter signal is ',num2str(length(tx_signal))])


dc_offset_value = 2;
tx_signal = [tx_signal ,0.5*dc_offset_value*ones(1,30000)];
figure(10);
subplot(1,1,1), pwelch(tx_signal,[],[],[],fs,'centered','power');
title('Power spetrum of transmitted signal'); 

end