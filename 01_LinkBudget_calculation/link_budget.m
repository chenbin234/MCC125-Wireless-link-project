Ebn0=18.8;
EbN0dB = 10^(1.88);
SNR_in = 10*log10(EbN0dB*6);


P_1dB_n = 10^(1.95);
G_n = 10^(1.86);

P_1dB_n_1 = 10^(0.8);
G_n_1 = 10^(-1);

P_1dB_n_2 = 10^(2);
G_n_2 = 10^(-1);


% calculate the 1-dB compression point of the transmitter
P_1dB_transmitter = -10 * log10(1/(P_1dB_n)+ 1/(P_1dB_n_1*G_n) + 1/(P_1dB_n_2*G_n_1*G_n));

% calculate the noise level
NF1 = 10^(0.06);
G1 = 10^(-0.06);

NF2 = 10^(0.35);
G2 = 10^(2);

NF3 = 10^(0.35);
G3 = 10^(2);

NF4 = 10^(0.06);
G4 = 10^(-0.06);

NF5 = 10^(1);
G5 = 10^(-1);

NF6 = 10^(0.2);
G6 = 10^(1.86);


NF_total = 10* log10(NF1 + (NF2-1)/G1 + (NF3-1)/(G1*G2) + (NF4-1)/(G1*G2*G3) + (NF5-1)/(G1*G2*G3*G4) + (NF6-1)/(G1*G2*G3*G4*G5));


%calculate the p_n
P_n = -174 + 10*log10(1.67e6) + NF_total

%calculate P_r
P_r = P_n + SNR_in


% calculate P_t
G_t = 3;
G_r = 3;
FSPL = 80
P_t = P_r + FSPL - G_t - G_r


