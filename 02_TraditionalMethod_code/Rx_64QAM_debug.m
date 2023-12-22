function [received_message_bits, received_message_symbols, raw_message_symbol]= Rx_64QAM_debug(received_signal, segment_size)
% This function is to decode the received signal.

%% ###### Basic parameter ######
Rb = 0.1*1e6;           % Bit rate [bit/sec] %Rb = fsymb*bpsymb; % Bit rate [bit/s]
fc = 2.4*1e9;         % Carrier frequency [Hz]
N=50000;              % Numbr of samples in a frame

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

%received_signal = lowpass(received_signal,25e6);

received_signal = received_signal./max(abs(received_signal));  % normalise received_signal

% Lowpass filter:
% [a,b]=butter(2,0.05);
% received_signal=filtfilt(a,b,received_signal);

% preamble = [1 1 1 1 1 -1 -1 1 1 -1 1 -1 1];     % 13 bits from Barker code
% preamble = repmat(preamble,1,10);

preamble = [-1	-1	-1	-1	1	-1	-1	-1	-1	-1	-1	1	-1	-1	1	1	-1	-1 1 1 1 -1 -1 1 1 1 -1 -1 -1 -1 1 -1	-1	-1	1	-1	1	1	-1	-1	-1	-1	-1	1	-1	-1	1	-1	1	1	-1	1	1 -1 -1 1 1 1 -1	-1	1	1	1	-1	-1	1	1	-1	-1	1	-1	1	1	1	-1	-1	-1	1	-1	1	-1	1	-1	1	1	1	1	-1	1	-1	-1	1	1	-1	1	1	1	1	1	1	-1	-1	1	-1	-1	-1	1	1	1	-1	-1	1	-1	-1	1	-1	1	1	1	-1	1	1	1	1	1	-1	-1	1	-1	-1	-1	-1	1	1	-1	-1	1	-1	1	1	-1	-1	-1	1	-1	-1	-1	-1	-1	-1];
%% 1. Coarse frequency correction

% dc_offset_real = 10;  % Real part of the DC offset
% dc_offset_imag = 10;  % Imaginary part of the DC offset
% received_signal_with_dc_offset = received_signal + (dc_offset_real + 1i * dc_offset_imag);

% dc_offset_value = 10;
% received_signal_with_dc_offset = received_signal + dc_offset_value;

[pxx, f] = pwelch(received_signal.',[],[],[],fs,'centered','power');
index = find(pxx == max(pxx));
freq_shift_coarse = f(index);
disp(['The estimated coarse frequency offset is',num2str(freq_shift_coarse)])
% first coarse frequency correction
rx_freq_correction = received_signal.*exp(2*-1i*pi*(freq_shift_coarse)*(0:length(received_signal)-1)*1/fs); 
% disp('Coarse frequency correction done!')

% figure(2);
% subplot(2,1,1), pwelch(received_signal,[],[],[],fs,'centered','power');
% title('Power spetrum of received signal (raw)'); 
% subplot(2,1,2), pwelch(rx_freq_correction,[],[],[],fs,'centered','power');
% title('Power spetrum of received signal (after coarse frequency correction)');

% figure(4);
% plot(pxx);
%% 2. Detection of frame start
[pulse,~] = rtrcpuls(alpha,tau,fs,span);      % Create rrc pulse: rtrcpuls(alpha,tau,fs,span)

preamble_upsample = upsample(preamble, fsfd);         % upsample preamble  
conv_preamble_pulse = conv(pulse, preamble_upsample); % pulse shaping the upsampled preamble
% conv_preamble_pulse = rescale(conv_preamble_pulse, -1, 1);  % normalise conv_preamble_pulse

corr = conv(rx_freq_correction,fliplr(conv_preamble_pulse));% correlate the recorded signal(maybe have the message) with processed preamble
% corr = xcorr(conv_preamble_pulse,rx_freq_correction);
% corr = xcorr(rx_freq_correction,conv_preamble_pulse);
% disp('correlate the recorded signal with conv_preamble_pulse')

corr = corr./length(preamble);                                      % normalize corr 

figure(3);plot(abs(corr));


Threshold = 0.2;                                      % if corr has a peak over 0.8, there are messages in transmitter
[tmp,Tmax] = max(abs(corr));                          % value and location of the peak of corr
Tx_hat = Tmax - length(conv_preamble_pulse);          % find delay, Tx_hat+1 is the location of the start(preamble) of the message
length_signal = (fsfd*(length(preamble)+(segment_size./bpsymb))+length(pulse)-1); %length of preamble+message in y


if (tmp < Threshold)
    disp('find nothing !')
    %figure(2);plot(abs(corr));
    received_message_bits = 0;
    received_message_symbols=0;
    raw_message_symbol = 0;

elseif (Tx_hat + length_signal > N || Tx_hat < 0)
    disp('find the preamble, but the message is invalid (truncated), try to detect other valid frames.')
    received_message_bits = 0;
    received_message_symbols=0;
    raw_message_symbol = 0;
    
else
    figure(2);
    plot(abs(corr));
    title('Preamble detected'); 

    figure(4);
    subplot(2,1,1), pwelch(received_signal,[],[],[],fs,'centered','power');
    title('Power spetrum of received signal (raw)'); 
    subplot(2,1,2), pwelch(rx_freq_correction,[],[],[],fs,'centered','power');
    title('Power spetrum of received signal (after coarse frequency correction)');


    disp('find the preamble, and the message is valid !')
    % Tx_hat = Tmax - length(conv_preamble_pulse);      % find delay, Tx_hat+1 is the location of the start(preamble) of the message
    display(['The Tmax is ',num2str(Tmax)])
    display(['The length of conv_preamble_pulse is ',num2str(length(conv_preamble_pulse))])
    display(['The Tx_hat is ',num2str(Tx_hat)]) % Tx_hat+1 is the location of the start(preamble) of the message
 
    % length_signal = (fsfd*(length(preamble)+(segment_size./bpsymb))+length(pulse)-1); %length of preamble+message in y
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

%     MF_output = MF_output/max(abs(MF_output));            % normalize
    disp('Matched Filtering done!')

%% 4. Down Sampling
    MF_output_cut = MF_output(2*span*fsfd-1:end-2*span*fsfd+2);  % cut the beginning and end of match filter output
    symb = MF_output_cut;
    e = zeros(size(MF_output_cut));
    for k = 2:1:length(symb)-1
        eI(k) = abs(real(symb(k-1)) - real(symb(k+1)));
        eQ(k) = abs(imag(symb(k-1)) - imag(symb(k+1)));
        e(k) = eI(k) + eQ(k);  % 1 x all samples
    end
    
    error = reshape(e, fsfd, []);  % [s_per_symb length(symb)/s_per_symb]
    error_sum = sum(error, 2);  % [samples_per_symbol 1]
    figure(15);
    plot(error_sum);
    title('sum of error');
    
    % find the index minimum value of error
    [~, k] = min(error_sum);
    disp(['The k value is: ',num2str(k)])

%     MF_output_cut = MF_output(2*span*fsfd-1:end-2*span*fsfd+1);  % cut the beginning and end of match filter output
%     MF_output_cut_without_premable = MF_output(2*span*fsfd-1+length(preamble)*fsfd:end-2*span*fsfd+1); % cut the preamble part
%     rx_preamble_message = MF_output_cut(1:fsfd:end);      % dowmsampling, get the preamble+message                 
    
    rx_preamble_message = MF_output_cut(k:fsfd:end);      % dowmsampling, get the preamble+message
    rx_vec = rx_preamble_message(1+length(preamble):end); % get the message
    
    rx_vec = rx_vec - mean(rx_vec);
    rx_preamble_message = rx_preamble_message - mean(rx_preamble_message);
    
    %MF_output_downsample = downsample(MF_output(:), fsfd);
    %rx_vec = MF_output_downsample(1+length(preamble):end); % get the message
    raw_message_symbol = rx_vec;

    scatterplot(rx_vec);
    title('Downsampling');


    

%% 5. Frequency and phase correction

    % Phase synchronization & Frequency synchronization
    rx_preamble = rx_preamble_message(1:length(preamble));% extract the recieved preamble symbols
    rx_preamble_for_freq_sync = rx_preamble./max(abs(rx_preamble));    % normalize the preamle symbols 
    rx_signal_downsampled = rx_preamble_message;

    % Calculate phase difference between transmitted preamble and received preamble
    diff_angle_preamble=unwrap(angle(preamble)-angle(rx_preamble_for_freq_sync));
    
    % Find coefficients to polyfit line
    c = polyfit(1:length(diff_angle_preamble),diff_angle_preamble,1);
    % Find coefficients to polyfit line
    polyfit_line = polyval(c,1:length(diff_angle_preamble));
    
    % Frequency offset is the slope of the fitted line
    freq_grad=(polyfit_line(1)-polyfit_line(end))/length(polyfit_line);
    
    % Calculate frequency shift
    freq_shifts=freq_grad*(1:length(rx_signal_downsampled));
    
    % Correct for frequency shift
    rx_preamble_message_freq=rx_signal_downsampled.*exp(-1i*freq_shifts);

        
    % phase_slope = unwrap(angle(rx_preamble) - angle(preamble)); % calculated the difference in angle between known preamble and received preamble  
    % 
    % % unwrap(angle(rx_preamble) - angle(preamble)) = phase_offset + 2*pi*frequency_offset 
    % % polyfit(x,phase), the intercept is phase offset, the slope is 2*pi*frequency_offset
    % % we can got the phase offset and frequency_offset
    % 
    % time_symb_synk = (0:length(preamble)-1)*Tsymb;
    % p1 = polyfit(time_symb_synk,phase_slope,1);
    % phase_slope_fit = polyval(p1,time_symb_synk);
    % 
    % %freq_offset_estimated=p1(1)/(2*pi);% In Hz
    % %phase_offset_estimated_deg=360*(p(2))/(2*pi);
    % freq_offset_estimated = (phase_slope_fit(1)-phase_slope_fit(end))/length(phase_slope_fit);
    % freq_offset_estimated = freq_offset_estimated * (1: length(rx_preamble_message));
    % 
    % 
    % disp(['Frequency offset estimated: ',num2str(freq_offset_estimated), 'Hz'])
    % %disp(['Phase offset estimated: ',num2str(phase_offset_estimated_deg), 'degree'])
    % 
    % 
    % % Frequency correction after down-sampling
    % time_ds = (0:length(rx_preamble_message)-1)*Tsymb;
    % % rx_preamble_message_freq=rx_preamble_message.* exp(-1i * 2 * pi * freq_offset_estimated * time_ds);% Correcting freq offset
    % rx_preamble_message_freq=rx_preamble_message.* exp(-1i * freq_offset_estimated);
    % disp('Frequency correction done!')


    time_symb_synk = (0:length(preamble)-1)*Tsymb;
    phase_slope2 = unwrap(angle(rx_preamble_message_freq(1:length(preamble))) - angle(preamble));
    p2 = polyfit(time_symb_synk,phase_slope2,1);

    phase_offset_estimated_deg=360*(p2(2))/(2*pi);
    disp(['Phase offset estimated: ',num2str(phase_offset_estimated_deg), 'degree'])
    
    % Phase correction after down-sampling
    rx_preamble_message_phase=rx_preamble_message_freq*exp(-1i*p2(2));% subtracting phase offset
    disp('Phase correction done!')

    preamble_correction = rx_preamble_message_phase(1:length(preamble));
    message_correction = rx_preamble_message_phase(1+length(preamble):end);

%     figure(4);
%     scatterplot(message_correction);
%     title('QAM Constellation Diagram before rescale');

    % scale parameter, scale the symbol besed on the changes on preamble
    b = mean(abs(preamble_correction));
    message_correction_scale = message_correction./b;


    % the received_message_symbols got here is 1./codeRate size of the
    % sending message symbol (because of convolution encoding).
    received_message_symbols = message_correction_scale;

    % demodulate
    received_message_bits = qamdemod(message_correction_scale,M,'OutputType','bit',UnitAveragePower=true);
    received_message_bits = received_message_bits(:)';
    % disp(['length of decoded message', num2str(length(received_message_bits))]);
    
    % Viterbi decode the demodulated data
    trellis = poly2trellis([5 4],[23 35 0; 0 5 13]);
    traceBack = 28;
    codeRate = 2/3;
    received_message_bits = vitdec(received_message_bits,trellis,traceBack,'trunc','hard');
    disp(['length of decoded message', num2str(length(received_message_bits))]);
    
    % Plot constellation diagram after Frequency and phase correction
    scatterplot(received_message_symbols);
    title('QAM Constellation Diagram after Frequency and phase correction');

end
end
