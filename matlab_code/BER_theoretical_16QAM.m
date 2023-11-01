% Parameters
M = 16;          % 16-QAM modulation
m = log2(M);
EbN0dB = 0:0.01:20; % Eb/N0 values in dB
EbN0 = 10.^(EbN0dB/10); % Convert Eb/N0 from dB to linear scale

% Theoretical BER calculation
% ber_theoretical = 2 * (1 - 1/sqrt(M)) * qfunc(sqrt(3 * log2(M) * EbN0));
ber_theoretical = 2/m * (1 - 1/sqrt(2^m)) * erfc(sqrt(1.5 * EbN0 * m / (2^m - 1)));



% Plot the theoretical BER vs. Eb/N0
semilogy(EbN0dB, ber_theoretical, '-o');
grid on;
xlabel('Eb/N0 (dB)');
ylabel('Bit Error Rate (BER)');
title('Theoretical 16-QAM Modulation BER');
