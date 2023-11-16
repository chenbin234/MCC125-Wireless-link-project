clear all;clc;
preamb = [1 1 1 1 1 -1 -1 1 1 -1 1 -1 1];     % 13 bits from Barker code
preamb = repmat(preamb,1,10);

corr = conv(preamb,fliplr(preamb));
corr = corr./130;
figure(1); clf;plot(abs(corr));