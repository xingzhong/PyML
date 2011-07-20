import numpy as np
from numpy import linalg as la
import pylab as pb
from scipy import kron
from scipy.special import erfc

print 'Machine Learning by Python'
N = 1000000
SNR = np.linspace(-10,10,num = 11 )
#SNR = [0]
BER = []
TBER = []
for snr in SNR:
    print snr, 'dB'
    sigma = 10**(-snr/10)
    data = np.empty([4,N], dtype=np.cfloat)
    tx = data[0,:]
    noise = data[1,:]
    rx = data[2,:]
    sink = data[3,:]
    tx.real = 2*np.random.randint(2,size=N)-1
    tx.imag = np.zeros(N)
    noise.real = sigma/np.sqrt(2) * np.random.randn( N )
    noise.imag = sigma/np.sqrt(2) * np.random.randn( N )
    Pn = la.norm(noise)/np.sqrt(2*noise.size)
    Ps = la.norm(tx)/np.sqrt(2*tx.size)
    rx = tx + noise
    sink[np.where(rx<0)] = -1
    sink[np.where(rx>=0)] = 1
    err = np.float(np.nonzero(tx-sink)[0].size)
    theory = 0.5 * erfc(Ps/Pn)
    print err/N, theory
    BER = np.append(BER, err/N)
    TBER = np.append(TBER, theory)
pb.semilogy(SNR, BER, '+')
pb.semilogy(SNR, TBER)
pb.grid(True)
pb.show()
#rx1 = rx[np.where(sink==1)]
#rx2 = rx[np.where(sink==-1)]
#pb.scatter(rx1.real, rx1.imag, marker = '+', color = 'r')
#pb.scatter(rx2.real, rx2.imag, marker = '+', color = 'b')
#pb.scatter(tx.real, tx.imag, marker = 'o')
#pb.grid(True)
#pb.show()
