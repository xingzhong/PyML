import numpy as np
from numpy import linalg as la
import pylab as pb
from scipy import kron
from scipy.special import erfc
from scipy.linalg import toeplitz, inv, pinv, norm
# y = x*h + v
class CE:
    def __init__(self, L=10, M=1, N=20, SNR=np.linspace(-5,20,20)):
        self.L = L  # #channel memory
        self.M = M  # #iteration time
        self.N = N  # #observation
        self.SNR = SNR # SNR 
        print self.L, self.N

    def channel(self):
        self.h = np.matrix (np.random.randn(self.L,1)) # now just norm sample


    def train(self): # training sample as input
        x = np.random.randint(2, size=(self.L+self.N-1 ,1)) *2 -1
        c = x[(self.L-1):]
        r = x[::-1][-self.L:]
        self.X = np.matrix (toeplitz (c,r))

    def noise(self):
        self.V = np.matrix (self.sigma * np.random.randn(self.N,1)+ self.mu)

    def error(self):
        Y = self.X * self.h + self.V
        self.hh = pinv(self.X) * Y
        return norm( self.h - self.hh ,2)

    def theory(self):
        self.the = np.trace( inv( self.X.H * self.X ) )
        self.the = self.sigma * self.the

    def work(self):
        self.ERR = []
        self.THE = []
        for snr in self.SNR:
            self.sigma = 10**(-snr/10.0)
            self.mu = 0
            err = []
            for m in range( self.M ):
                self.channel()
                self.train()
                self.noise()
                self.theory()
                err.append( self.error() )
            self.ERR.append(np.average(err)  )
            self.THE.append(self.the )

    def show(self):
        print self.ERR
        print self.THE
        pb.semilogy(self.SNR, self.ERR)
        pb.semilogy(self.SNR, self.THE, '+')
        pb.grid(True)

print 'Machine Learning by Python Channel Estimation'
L = np.arange(5,50,5)      #num of the channel memory 
N = np.arange(10,30,2)  # num of the observation
SNR = [-3.0, 3.0,10.0, 17.0]
#N = [20]
L = [15]
N = [20]
for n in N:
    for l in L:
        ex = CE(L=l, N=n, SNR = SNR)
        ex.work()
        ex.show()
pb.show()
