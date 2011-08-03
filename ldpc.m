clear all;
clc;
block = 5e5; %simulation block
N = 7;  %code length
K = 4;  %info length
R = N-K;    %check length
Rec = [
    0 0 1 0 0 0 0;
    0 0 0 0 1 0 0;
    0 0 0 0 0 1 0;
    0 0 0 0 0 0 1;
]
G = [
    1 1 0 1;
    1 0 1 1;
    1 0 0 0;
    0 1 1 1;
    0 1 0 0;
    0 0 1 0;
    0 0 0 1;
    ]
H = [
    1 0 1 0 1 0 1;
    0 1 1 0 0 1 1;
    0 0 0 1 1 1 1;
]

SNR = [-3:3:9];
BER = [];
ERR = [];
THE = [];
THEC = [];
%SNR = [3];
for snr = SNR 
    snr
    source = randi([0,1],[K,block]);
    coding = mod (G * source, 2);

    tx = coding * 2 -1;
    lsnr = 10^(-snr/10);
    N0 = lsnr;
    noise = sqrt(N0/2)  * randn(N, block) ;

    rx = tx + noise ;
    decoding = rx > 0;

    S = mod( H * decoding, 2 ); %syndrome 
%% Linear Block coding assume the error is limited, otherwise over the error
%   capacity. Actually, it is the most sparse error vector solution to induce
%   the error syndrome
    E = zeros(N, block);
    for b = 1 : block
        idx = 0;
        for i = 1 : N
            if H(:, i) == S(:,b)
                idx = i;
            end
        end
        if idx ~= 0
            E(idx, b) = 1;
        end
    end
    correct = mod ( decoding + E, 2);
    sink = Rec * correct;
    error = nnz(source-sink);
    ber = error/ (block*K);
    ebn0 = 1/lsnr
    ecn0 = K * ebn0 / N
    tber  = 1/2 * erfc(sqrt(ebn0));
    tberc = 1/2 * erfc(sqrt(ecn0));
    err = nnz(coding-decoding)/(N*block);
    terc = tberc - tberc*(1-tberc)^(N-1);
    ERR = [ERR err];
    BER =[BER ber];
    THE =[THE tber];
    THEC = [THEC terc];
end
SNR
ERR
THE
BER
THEC
semilogy(SNR, BER, '-', SNR, ERR, '--', SNR, THE, '+', SNR, THEC, '*');
legend('Coding', 'Un-Coding', 'Theortical Un-Coding', 'Theortical Coding');
