clear all;
clc;
block = 5e2; %simulation block
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

SNR = [0:3:9];
BER = [];
ERR = [];
THE = [];
LSNR = [];
SNR = [0];
for snr = SNR 
    snr
    source = randi([0,1],[K,block]);
    coding = mod (G * source, 2);

    tx = coding * 2 -1;
    lsnr = 10^(-snr/10);
    LSNR = [LSNR 1/lsnr];
    Ps = sum(sum(abs(tx).^2))/(K * block) ;
    N0 = lsnr * Ps;
    noise =  sqrt(N0/2) * (reshape( randn(1, N*block), N, block) + sqrt(-1)*randn(N,block));
    Pn = sum(sum(abs(noise).^2))/( N * block);
    rx = tx + noise ;
    decoding = rx > 0;

    S = mod( H * decoding, 2 ); %syndrome 
    %% Linear Block coding assume the error is limited, otherwise over the error
    %%   capacity. Actually, it is the most sparse error vector solution to induce
    %%   the error syndrome
    E = zeros(N, block);
    for b = 1 : block
        if norm(S(:,b)) ~= 0
            E(:, b) = l1(H, S(:,b));
        end
    end
    E = E > 0.1;
    %%
%%    for b = 1 : block
%%        idx = 0;
%%        for i = 1 : N
%%           if H(:, i) == S(:,b)
%%                idx = i;
%%            end
%%        end
%%        if idx ~= 0
%%            E(idx, b) = 1;
%%        end
%%    end
    
    correct = mod ( decoding + E, 2);
    sink = Rec * correct;

    error = nnz(source-sink);
    ber = error/ (block*K);
    ebn0 = 1/lsnr
    ecn0 = K * ebn0 / N
    pb = Q(sqrt(2 * ecn0));
    the = pb - pb*(1 - pb)^(N-1)
    BER =[BER ber];
    THE =[THE the];
end
[SNR; BER; THE]
bpske = Q(sqrt(2 * LSNR ));
semilogy(SNR, BER, '-', SNR, THE, '+', SNR, bpske, '-');
legend('Coding' , 'Theortical Coding', 'Theortical BPSK');
grid on
