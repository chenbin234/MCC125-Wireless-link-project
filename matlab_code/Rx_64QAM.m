function [received_message_bits, received_message_symbols]= Rx_64QAM(received_signal)
% This function is to decode the received signal.

%% ###### Basic parameter ######
Rb = 10*1e6;          % Bit rate [bit/sec] %Rb = fsymb*bpsymb; % Bit rate [bit/s]
fc = 2.4*1e9;         % Carrier frequency [Hz]

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
segment_size = 3000;  % Number of bits in each message segmentation


received_signal = received_signal./max(abs(received_signal));  % normalise received_signal

% Lowpass filter:
% [a,b]=butter(2,0.05);
% received_signal=filtfilt(a,b,received_signal);

preamble = [1 1 1 1 1 -1 -1 1 1 -1 1 -1 1];     % 13 bits from Barker code
preamble = repmat(preamble,1,4);
%% 1. Coarse frequency correction
dc_offset_value = 1;
received_signal_with_dc_offset = received_signal + dc_offset_value;

[pxx, f] = pwelch(received_signal_with_dc_offset.',[],[],[],fs,'centered','power');
index = find(pxx == max(pxx));
freq_shift_coarse = f(index);

% first coarse frequency correction
rx_freq_correction = received_signal.*exp(2*-1i*pi*(freq_shift_coarse)*(0:length(received_signal)-1)*1/fs); 

figure(2);
subplot(2,1,1), pwelch(received_signal,[],[],[],fs,'centered','power');
title('Power spetrum of received signal (raw)'); 
subplot(2,1,2), pwelch(rx_freq_correction,[],[],[],fs,'centered','power');
title('Power spetrum of received signal (after coarse frequency correction)');

% figure(4);
% plot(pxx);
%% 2. Detection of frame start
[pulse,~] = rtrcpuls(alpha,tau,fs,span);      % Create rrc pulse: rtrcpuls(alpha,tau,fs,span)

preamble_upsample = upsample(preamble, fsfd);         % upsample preamble  
conv_preamble_pulse = conv(pulse, preamble_upsample); % pulse shaping the upsampled preamble

corr = conv(rx_freq_correction,fliplr(conv_preamble_pulse));% correlate the recorded signal(maybe have the message) with processed preamble
% corr = xcorr(conv_preamble_pulse,rx_freq_correction);
% corr = xcorr(rx_freq_correction,conv_preamble_pulse);
disp('correlate the recorded signal with conv_preamble_pulse')

corr = corr./length(preamble);                                      % normalize corr 
figure(3); clf;plot(abs(corr));


Threshold = 0.8;                                      % if corr has a peak over 0.8, there are messages in transmitter
[tmp,Tmax] = max(abs(corr));                          % value and location of the peak of corr

if (tmp > Threshold)

    disp('find the preamble!')
    Tx_hat = Tmax - length(conv_preamble_pulse);      % find delay, Tx_hat+1 is the location of the start(preamble) of the message
    display(['The Tmax is ',num2str(Tmax)])
    display(['The length of conv_preamble_pulse is ',num2str(length(conv_preamble_pulse))])
    display(['The Tx_hat is ',num2str(Tx_hat)]) % Tx_hat+1 is the location of the start(preamble) of the message
 
    length_signal = (fsfd*(length(preamble)+(segment_size./bpsymb))+length(pulse)-1); %length of preamble+message in y
    % length_signal = (N+length(pulse)-1);
    disp(['The theoretical length of signal we should capture is',num2str(length_signal)])

    y = rx_freq_correction((Tx_hat+1):(Tx_hat+length_signal));    % get the segment of y we want - which is preamble+message
    disp(['Try to capture the whole signal (preamble+message), the length we captured is:',num2str(length(y))])
    disp('The message (preamble+frame_message) is located')

%% 3. Matched Filtering
    MF = fliplr(conj(pulse));                             % Create matched filter impulse response
    MF_output = conv(MF, y);                              % Run through matched filter

    %Filter with MF
    %MF_output = filter(MF, 1, y);

    % MF_output = MF_output/max(abs(MF_output));            % normalize
    disp('The signal is filtered')

%% 4. Down Sampling
    MF_output_cut = MF_output(2*span*fsfd-1:end-2*span*fsfd+1);  % cut the beginning and end of match filter output
    MF_output_cut_without_premable = MF_output(2*span*fsfd-1+length(preamble)*fsfd:end-2*span*fsfd+1); % cut the preamble part
    rx_preamble_message = MF_output_cut(1:fsfd:end);      % dowmsampling, get the preamble+message                 
    rx_vec = rx_preamble_message(1+length(preamble):end); % get the message
      
%      MF_output_downsample = downsample(MF_output(:), fsfd);
%      rx_vec = MF_output_downsample(1+length(preamble):end); % get the message
    
%% 5. Frequency and phase correction

%     % Phase synchronization & Frequency synchronization
%     rx_preamble = rx_preamble_message(1:length(preamble));% extract the recieved preamble symbols
%     rx_preamble = rx_preamble./mean(abs(rx_preamble));    % normalize the preamle symbols 
%        
%     phase = (angle(rx_preamble) - angle(preamble)); % calculated the difference in angle between known preamble and received preamble  
%     disp('Phase offset before mod:')   
%     disp(phase)
%     phase = mod(phase, 2*pi); % Get offset  
%     
%     % angle(rx_preamble) - angle(preamble) = phase_offset + 2*pi*frequency_offset 
%     % polyfit(x,phase), the intercept is phase offset, the slope is 2*pi*frequency_offset
%     % we can got the phase offset and frequency_offset
%     x = Tsamp*[1:1:length(preamble)];
%     P = polyfit(x,phase,1);
%     slope = P(1);
%     fdelta = slope./(2*pi);
%     intercept = P(2);
%     disp(['intercept is:',num2str(intercept* 180/pi)])
%     disp(['fdelta:',num2str(fdelta)])
%     disp('Phase offset after mod:')
%     disp(phase)
%     
%     % another way to get phase offset
%     avg_phase = mean(phase); 
%     disp(['The signal is Phase Shifted with ', num2str(avg_phase * 180/pi), ' degrees'])
% 
%     %rx_vec = rx_vec * exp(-1j*avg_phase); % phase syncronization
%     rx_vec = rx_vec * exp(-1j*intercept); % phase syncronization
%     disp(['The length of rx_vec is', num2str(length(rx_vec))])
%     
%     % Frequency synchronization
%     for i =1:1:length(rx_vec)
%         rx_vec(i) = rx_vec(i) * exp(-1j*2*pi*fdelta*Tsamp);
%     end
% 
%     % MF_output_cut_without_premable = MF_output_cut_without_premable * exp(-1j*avg_phase); % Match_filter with time sync and phase sync
%     rx_vec = rx_vec./abs(rx_vec); % normalise re_vec
%     
%     disp('Symbols acquired!')
%     rx_vec = rx_vec./max(abs(rx_vec)); % normalise re_vec
    rx_vec = zscore(rx_vec);

    received_message_symbols = rx_vec;
    received_message_bits = qamdemod(rx_vec,M,'OutputType','bit',UnitAveragePower=true);
%     received_message_bits = qamdemod(rx_vec,M,'OutputType','bit');
    received_message_bits = received_message_bits(:)';


    % Plot constellation diagram
    figure(5);
    scatterplot(received_message_symbols);
    title('QAM Constellation Diagram');

end
end
