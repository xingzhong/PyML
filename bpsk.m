clear all;
clc;

SNR = [-3:3:9];
BER = [];
THE = [];
K = 10;
block = 10000;
for snr = SNR 
    snr
    source = randi([0,1],[K,block]);
    tx = source * 2 -1;
    lsnr = 10^(-snr/10);
    Ps = sum(sum(abs(tx).^2))/(K * block) ;
    N0 = lsnr * Ps;
    noise =  sqrt(N0/2) * (randn(K, block) + sqrt(-1) * randn(K, block)) ;
    Pn = sum(sum(abs(noise).^2))/(K * block);
    rx = tx + noise ;
    sink = rx > 0;

    error = nnz(source-sink);
    ber = error/ (block*K);
    ebn0 = 1/lsnr;
    pb = Q(sqrt(2 * ebn0));
    BER =[BER ber];
    THE =[THE pb];
end
[SNR; BER; THE]
semilogy(SNR, BER, '-', SNR, THE, '+');
legend('BPSK' , 'Theortical BPSK');

