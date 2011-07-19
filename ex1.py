import numpy as np
import pylab as pb
from scipy import signal, kron

print 'Machine Learning by Python'
N = 1000
sigma = 0.3
source = 2*np.random.randint(2,size=N)-1
tx = kron(source, [1,1,1,1])
noise = sigma * np.random.randn( tx.size)
print np.mean(noise)
rx = tx + noise 
pb.scatter(rx.real, rx.imag, marker = '+')
pb.scatter(tx.real, rx.imag, marker = 'o')
pb.grid(True)
pb.show()
